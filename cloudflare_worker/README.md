# Sard Cloudflare Worker

This Worker sits between the Flutter admin dashboard and Cloudflare services:

- Product JSON is stored in Workers KV through the `PRODUCTS_KV` binding.
- Product image uploads use Cloudflare R2 through the `PRODUCT_IMAGES` binding.
- Uploaded image URLs can be stored directly in `main_image`, `image`, and `images`.
- Cloudflare Images Direct Creator Upload is still available, but the R2 upload endpoint is preferred for the current dashboard flow.
- The Cloudflare Images API token stays in a Worker secret and is never exposed to Flutter.

## Files and secrets

- KV binding: `PRODUCTS_KV`
- R2 binding: `PRODUCT_IMAGES`
- Worker secret: `CF_IMAGES_API_TOKEN`
- Worker vars:
  - `CF_ACCOUNT_ID`
  - `CF_IMAGES_ACCOUNT_HASH`
  - `ALLOWED_ORIGIN`

## Setup

1. `npm install`
2. `npx wrangler login`
3. `npx wrangler kv namespace create PRODUCTS_KV`
4. `npx wrangler r2 bucket create sard-product-images`
5. Copy `wrangler.toml.example` to `wrangler.toml` and fill in the KV namespace id. Make sure the R2 binding is present:

```toml
[[r2_buckets]]
binding = "PRODUCT_IMAGES"
bucket_name = "sard-product-images"
```

6. `npx wrangler secret put CF_IMAGES_API_TOKEN`
7. `npx wrangler dev`
8. `npx wrangler deploy`
9. Test endpoints with the `curl` examples below.

## API behavior

- `OPTIONS /*`
  Returns CORS headers.
- `GET /products`
  Loads `product_index`, fetches each `product:<id>` entry, and returns an array of saved product JSON objects.
- `GET /products/:id`
  Returns one saved product JSON object or `404`.
- `POST /products`
  Requires `body.product.id`, stores the exact JSON body in `product:<id>`, updates `product_index`, and returns the saved body.
- `PUT /products/:id`
  Requires `body.product.id` and it must match `:id`, replaces `product:<id>`, keeps `product_index` updated, and returns the saved body.
- `DELETE /products/:id`
  Deletes `product:<id>`, removes the id from `product_index`, and returns `{ "ok": true }`.
- `POST /purchase`
  Accepts `{ "productId": "...", "variantId": "...", "quantity": 1 }`, decrements stock if available, saves the updated product, and returns the updated product JSON.
- `POST /images/upload`
  Accepts `multipart/form-data` with a required file field named `file`, stores the upload in R2, and returns a key plus a Worker-served image URL.
- `GET /images/*`
  Reads the image object from R2 and serves it back with its saved content type and cache headers.
- `POST /images/direct-upload`
  Calls Cloudflare Images Direct Creator Upload with the Worker secret token and returns the Cloudflare API response JSON. Keep this only if you still want Cloudflare Images integration; for this dashboard, `/images/upload` is preferred.

## Local curl examples

Assuming `npx wrangler dev` is running on `http://127.0.0.1:8787`.

Create a product:

```bash
curl -X POST http://127.0.0.1:8787/products \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:5000" \
  -d '{
    "product": {
      "id": "choco-box-1",
      "title": "Chocolate Box",
      "category": "bars",
      "description": "Sample product",
      "main_image": "https://example.com/main.jpg",
      "is_diet_friendly": false,
      "is_customizable": false,
      "options": [
        {
          "name": "Size",
          "values": ["Small", "Large"]
        }
      ],
      "variants": [
        {
          "id": "variant-small",
          "title": "Small Box",
          "price": 10,
          "weight_g": 100,
          "image": null,
          "images": [],
          "attributes": {
            "size": "Small"
          },
          "stock_quantity": 20
        }
      ],
      "bulk_config": null,
      "metadata": {
        "is_new_arrival": false,
        "calories_per_100g": 550
      }
    }
  }'
```

List all products:

```bash
curl http://127.0.0.1:8787/products \
  -H "Origin: http://localhost:5000"
```

Get one product:

```bash
curl http://127.0.0.1:8787/products/choco-box-1 \
  -H "Origin: http://localhost:5000"
```

Update a product:

```bash
curl -X PUT http://127.0.0.1:8787/products/choco-box-1 \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:5000" \
  -d '{
    "product": {
      "id": "choco-box-1",
      "title": "Chocolate Box Updated",
      "category": "bars",
      "description": "Updated product",
      "main_image": "https://example.com/main.jpg",
      "is_diet_friendly": false,
      "is_customizable": false,
      "options": [],
      "variants": [
        {
          "id": "variant-small",
          "title": "Small Box",
          "price": 10,
          "weight_g": 100,
          "image": null,
          "images": [],
          "attributes": {},
          "stock_quantity": 20
        }
      ],
      "bulk_config": null,
      "metadata": {
        "is_new_arrival": false,
        "calories_per_100g": 550
      }
    }
  }'
```

Purchase a variant:

```bash
curl -X POST http://127.0.0.1:8787/purchase \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:5000" \
  -d '{
    "productId": "choco-box-1",
    "variantId": "variant-small",
    "quantity": 1
  }'
```

Delete a product:

```bash
curl -X DELETE http://127.0.0.1:8787/products/choco-box-1 \
  -H "Origin: http://localhost:5000"
```

Create a direct upload URL:

```bash
curl -X POST http://127.0.0.1:8787/images/direct-upload \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:5000" \
  -d '{
    "requireSignedURLs": false,
    "metadata": {
      "source": "flutter-admin"
    }
  }'
```

Upload a product image to R2:

```bash
curl.exe -X POST "https://sard-products-api.s12219814.workers.dev/images/upload" -F "file=@C:\path\to\image.jpg"
```

Upload to a custom folder:

```bash
curl -X POST "http://127.0.0.1:8787/images/upload?folder=variants" \
  -H "Origin: http://localhost:5000" \
  -F "file=@C:\path\to\image.jpg"
```

## Notes

- Do not put Cloudflare API tokens into Flutter or commit them into source files.
- The Worker reads the Images token from the `CF_IMAGES_API_TOKEN` secret.
- The returned `url` from `/images/upload` should be saved into product `main_image`, variant `image`, or variant `images` fields.
- The current Flutter image flow remains URL-based. The Worker uploads the file to R2 and returns a URL that Flutter can store and reuse.
- Inventory writes use Workers KV for now. KV is eventually consistent, so high-concurrency stock protection should move to Durable Objects later.
