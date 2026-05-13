export interface Env {
  PRODUCTS_KV: KVNamespace;
  PRODUCT_IMAGES: R2Bucket;
  CF_ACCOUNT_ID: string;
  CF_IMAGES_API_TOKEN: string;
  CF_IMAGES_ACCOUNT_HASH?: string;
  ALLOWED_ORIGIN?: string;
}

type ProductEnvelope = {
  product: {
    id: string;
    variants?: Array<{
      id: string;
      stock_quantity?: number;
      [key: string]: unknown;
    }>;
    [key: string]: unknown;
  };
  [key: string]: unknown;
};

type PurchaseBody = {
  productId?: string;
  variantId?: string;
  quantity?: number;
};

const PRODUCT_INDEX_KEY = 'product_index';
const LOCAL_ALLOWED_ORIGIN = 'http://localhost:5000';
const DEFAULT_IMAGE_FOLDER = 'products';
const IMAGE_CACHE_CONTROL = 'public, max-age=31536000, immutable';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(request, env),
      });
    }

    const url = new URL(request.url);
    const segments = url.pathname.split('/').filter(Boolean);

    try {
      if (request.method === 'GET' && segments.length === 1 && segments[0] === 'products') {
        return handleListProducts(request, env);
      }

      if (request.method === 'GET' && segments.length === 2 && segments[0] === 'products') {
        return handleGetProduct(request, env, segments[1]);
      }

      if (request.method === 'POST' && segments.length === 1 && segments[0] === 'products') {
        return handleCreateProduct(request, env);
      }

      if (request.method === 'PUT' && segments.length === 2 && segments[0] === 'products') {
        return handleUpdateProduct(request, env, segments[1]);
      }

      if (request.method === 'DELETE' && segments.length === 2 && segments[0] === 'products') {
        return handleDeleteProduct(request, env, segments[1]);
      }

      if (request.method === 'POST' && segments.length === 1 && segments[0] === 'purchase') {
        return handlePurchase(request, env);
      }

      if (
        request.method === 'POST' &&
        segments.length === 2 &&
        segments[0] === 'images' &&
        segments[1] === 'upload'
      ) {
        return handleImageUpload(request, env);
      }

      if (
        request.method === 'POST' &&
        segments.length === 2 &&
        segments[0] === 'images' &&
        segments[1] === 'direct-upload'
      ) {
        return handleDirectUpload(request, env);
      }

      if (request.method === 'GET' && segments.length >= 2 && segments[0] === 'images') {
        return handleGetImage(request, env, segments.slice(1));
      }

      return jsonResponse(request, env, { error: 'Not found' }, 404);
    } catch (error) {
      if (error instanceof HttpError) {
        return jsonResponse(request, env, { error: error.message }, error.status);
      }

      console.error('Worker request failed', error);
      return jsonResponse(request, env, { error: 'Internal server error' }, 500);
    }
  },
};

async function handleListProducts(request: Request, env: Env): Promise<Response> {
  const productIds = await readProductIndex(env);
  const productValues = await Promise.all(
    productIds.map((id) => env.PRODUCTS_KV.get(productKey(id))),
  );

  const products = productValues
    .filter((value): value is string => value !== null)
    .map((value) => JSON.parse(value));

  return jsonResponse(request, env, products);
}

async function handleGetProduct(request: Request, env: Env, id: string): Promise<Response> {
  const stored = await env.PRODUCTS_KV.get(productKey(id));
  if (!stored) {
    return jsonResponse(request, env, { error: 'Product not found' }, 404);
  }

  return jsonResponse(request, env, JSON.parse(stored));
}

async function handleCreateProduct(request: Request, env: Env): Promise<Response> {
  const body = await readJsonBody<ProductEnvelope>(request);
  const id = body.product?.id?.trim();

  if (!id) {
    throw new HttpError(400, 'body.product.id is required');
  }

  await env.PRODUCTS_KV.put(productKey(id), JSON.stringify(body));
  await ensureProductIndexed(env, id);

  return jsonResponse(request, env, body, 201);
}

async function handleUpdateProduct(
  request: Request,
  env: Env,
  id: string,
): Promise<Response> {
  const body = await readJsonBody<ProductEnvelope>(request);
  const bodyId = body.product?.id?.trim();

  if (!bodyId) {
    throw new HttpError(400, 'body.product.id is required');
  }

  if (bodyId !== id) {
    throw new HttpError(400, 'body.product.id must match the URL id');
  }

  await env.PRODUCTS_KV.put(productKey(id), JSON.stringify(body));
  await ensureProductIndexed(env, id);

  return jsonResponse(request, env, body);
}

async function handleDeleteProduct(
  request: Request,
  env: Env,
  id: string,
): Promise<Response> {
  await env.PRODUCTS_KV.delete(productKey(id));

  const productIds = await readProductIndex(env);
  const nextIds = productIds.filter((item) => item !== id);
  await writeProductIndex(env, nextIds);

  return jsonResponse(request, env, { ok: true });
}

async function handlePurchase(request: Request, env: Env): Promise<Response> {
  const body = await readJsonBody<PurchaseBody>(request);
  const productId = body.productId?.trim();
  const variantId = body.variantId?.trim();
  const quantity = body.quantity ?? 1;

  if (!productId) {
    throw new HttpError(400, 'productId is required');
  }

  if (!variantId) {
    throw new HttpError(400, 'variantId is required');
  }

  if (!Number.isInteger(quantity) || quantity <= 0) {
    throw new HttpError(400, 'quantity must be a positive integer');
  }

  const stored = await env.PRODUCTS_KV.get(productKey(productId));
  if (!stored) {
    return jsonResponse(request, env, { error: 'Product not found' }, 404);
  }

  const productRecord = JSON.parse(stored) as ProductEnvelope;
  const variants = productRecord.product?.variants ?? [];
  const variant = variants.find((item) => item.id === variantId);

  if (!variant) {
    return jsonResponse(request, env, { error: 'Variant not found' }, 404);
  }

  const currentStock = Number(variant.stock_quantity ?? 0);
  if (currentStock < quantity) {
    return jsonResponse(request, env, { error: 'Insufficient stock' }, 409);
  }

  // Workers KV is eventually consistent. If inventory updates must be
  // strongly consistent under high concurrency, move this flow to Durable Objects.
  variant.stock_quantity = currentStock - quantity;

  await env.PRODUCTS_KV.put(productKey(productId), JSON.stringify(productRecord));
  await ensureProductIndexed(env, productId);

  return jsonResponse(request, env, productRecord);
}

async function handleImageUpload(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const folder = sanitizeFolder(url.searchParams.get('folder')) || DEFAULT_IMAGE_FOLDER;
  const formData = await request.formData();
  const file = formData.get('file');

  if (!(file instanceof File)) {
    throw new HttpError(400, 'Multipart form-data field "file" is required');
  }

  const sanitizedFilename = sanitizeFilename(file.name || 'upload.bin');
  const randomPart = crypto.randomUUID().split('-')[0];
  const objectKey = `${folder}/${Date.now()}-${randomPart}-${sanitizedFilename}`;

  await env.PRODUCT_IMAGES.put(objectKey, await file.arrayBuffer(), {
    httpMetadata: {
      contentType: file.type || 'application/octet-stream',
    },
  });

  return jsonResponse(request, env, {
    key: objectKey,
    url: buildImageUrl(request, objectKey),
  });
}

async function handleGetImage(
  request: Request,
  env: Env,
  keySegments: string[],
): Promise<Response> {
  const objectKey = keySegments.map((segment) => decodeURIComponent(segment)).join('/');

  if (!objectKey.trim()) {
    return jsonResponse(request, env, { error: 'Image key is required' }, 400);
  }

  const object = await env.PRODUCT_IMAGES.get(objectKey);
  if (!object) {
    return jsonResponse(request, env, { error: 'Image not found' }, 404);
  }

  const headers = new Headers(corsHeaders(request, env));
  headers.set(
    'Content-Type',
    object.httpMetadata?.contentType || 'application/octet-stream',
  );
  headers.set('Cache-Control', IMAGE_CACHE_CONTROL);

  return new Response(object.body, {
    status: 200,
    headers,
  });
}

async function handleDirectUpload(request: Request, env: Env): Promise<Response> {
  const payload = await readJsonBody<Record<string, unknown>>(request, {
    allowEmptyObject: true,
  });

  // Prefer the R2-based /images/upload endpoint for the current dashboard flow.
  // This direct-upload endpoint remains available for Cloudflare Images integrations.
  const response = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${env.CF_ACCOUNT_ID}/images/v2/direct_upload`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.CF_IMAGES_API_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    },
  );

  const responseText = await response.text();

  return new Response(responseText, {
    status: response.status,
    headers: {
      ...corsHeaders(request, env),
      'Content-Type': 'application/json',
    },
  });
}

function buildImageUrl(request: Request, objectKey: string): string {
  const url = new URL(request.url);
  const encodedKey = objectKey
    .split('/')
    .map((segment) => encodeURIComponent(segment))
    .join('/');

  return `${url.origin}/images/${encodedKey}`;
}

function productKey(id: string): string {
  return `product:${id}`;
}

async function ensureProductIndexed(env: Env, id: string): Promise<void> {
  const productIds = await readProductIndex(env);
  if (productIds.includes(id)) {
    return;
  }

  productIds.push(id);
  await writeProductIndex(env, productIds);
}

async function readProductIndex(env: Env): Promise<string[]> {
  const rawIndex = await env.PRODUCTS_KV.get(PRODUCT_INDEX_KEY);
  if (!rawIndex) {
    return [];
  }

  try {
    const parsed = JSON.parse(rawIndex);
    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed
      .map((item) => String(item).trim())
      .filter((item) => item.length > 0);
  } catch {
    return [];
  }
}

async function writeProductIndex(env: Env, ids: string[]): Promise<void> {
  const uniqueIds = Array.from(new Set(ids));
  await env.PRODUCTS_KV.put(PRODUCT_INDEX_KEY, JSON.stringify(uniqueIds));
}

function sanitizeFolder(folder: string | null): string {
  if (!folder || !folder.trim()) {
    return DEFAULT_IMAGE_FOLDER;
  }

  return folder
    .split('/')
    .map((segment) => sanitizePathSegment(segment))
    .filter((segment) => segment.length > 0)
    .join('/');
}

function sanitizeFilename(filename: string): string {
  const trimmed = filename.trim();
  if (!trimmed) {
    return 'upload.bin';
  }

  const sanitized = trimmed
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');

  return sanitized || 'upload.bin';
}

function sanitizePathSegment(segment: string): string {
  const sanitized = segment
    .trim()
    .replace(/[^a-zA-Z0-9_-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');

  return sanitized;
}

function allowedOrigins(env: Env): string[] {
  const configured = env.ALLOWED_ORIGIN?.trim();
  return configured && configured !== LOCAL_ALLOWED_ORIGIN
    ? [configured, LOCAL_ALLOWED_ORIGIN]
    : [LOCAL_ALLOWED_ORIGIN];
}

function resolveAllowedOrigin(request: Request, env: Env): string {
  const requestOrigin = request.headers.get('Origin')?.trim();
  const origins = allowedOrigins(env);

  if (requestOrigin && origins.includes(requestOrigin)) {
    return requestOrigin;
  }

  return env.ALLOWED_ORIGIN?.trim() || LOCAL_ALLOWED_ORIGIN;
}

function corsHeaders(request: Request, env: Env): Record<string, string> {
  return {
    'Access-Control-Allow-Origin': resolveAllowedOrigin(request, env),
    'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Vary': 'Origin',
  };
}

function jsonResponse(
  request: Request,
  env: Env,
  data: unknown,
  status = 200,
): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders(request, env),
      'Content-Type': 'application/json',
    },
  });
}

async function readJsonBody<T>(
  request: Request,
  options?: { allowEmptyObject?: boolean },
): Promise<T> {
  const text = await request.text();

  if (!text.trim()) {
    if (options?.allowEmptyObject) {
      return {} as T;
    }

    throw new HttpError(400, 'Request body is required');
  }

  try {
    return JSON.parse(text) as T;
  } catch {
    throw new HttpError(400, 'Invalid JSON body');
  }
}

class HttpError extends Error {
  readonly status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}
