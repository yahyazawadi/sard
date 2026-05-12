import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Boilerplate'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myWishlist.
  ///
  /// In en, this message translates to:
  /// **'My Wishlist'**
  String get myWishlist;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlistEmpty;

  /// No description provided for @movedToCart.
  ///
  /// In en, this message translates to:
  /// **'moved to cart'**
  String get movedToCart;

  /// No description provided for @removeFromWishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Wishlist?'**
  String get removeFromWishlistTitle;

  /// No description provided for @removeFromWishlistBody1.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \''**
  String get removeFromWishlistBody1;

  /// No description provided for @removeFromWishlistBody2.
  ///
  /// In en, this message translates to:
  /// **'\' from your heart list?'**
  String get removeFromWishlistBody2;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'KEEP'**
  String get keep;

  /// No description provided for @themeStyle.
  ///
  /// In en, this message translates to:
  /// **'Theme Style'**
  String get themeStyle;

  /// No description provided for @appearanceMode.
  ///
  /// In en, this message translates to:
  /// **'Appearance Mode'**
  String get appearanceMode;

  /// No description provided for @systemAuto.
  ///
  /// In en, this message translates to:
  /// **'System (auto)'**
  String get systemAuto;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @usingSystemSize.
  ///
  /// In en, this message translates to:
  /// **'Using system size'**
  String get usingSystemSize;

  /// No description provided for @resetToSystem.
  ///
  /// In en, this message translates to:
  /// **'Reset to System'**
  String get resetToSystem;

  /// No description provided for @themeMandyRed.
  ///
  /// In en, this message translates to:
  /// **'Mandy Red'**
  String get themeMandyRed;

  /// No description provided for @themeRedWine.
  ///
  /// In en, this message translates to:
  /// **'Red Wine'**
  String get themeRedWine;

  /// No description provided for @themeDeepPurple.
  ///
  /// In en, this message translates to:
  /// **'Deep Purple'**
  String get themeDeepPurple;

  /// No description provided for @themeSakura.
  ///
  /// In en, this message translates to:
  /// **'Sakura'**
  String get themeSakura;

  /// No description provided for @themePurpleBrown.
  ///
  /// In en, this message translates to:
  /// **'Purple Brown'**
  String get themePurpleBrown;

  /// No description provided for @themeJungle.
  ///
  /// In en, this message translates to:
  /// **'Jungle'**
  String get themeJungle;

  /// No description provided for @themeShadBlue.
  ///
  /// In en, this message translates to:
  /// **'Shad Blue'**
  String get themeShadBlue;

  /// No description provided for @themeSanJuanBlue.
  ///
  /// In en, this message translates to:
  /// **'San Juan Blue'**
  String get themeSanJuanBlue;

  /// No description provided for @themeIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get themeIndigo;

  /// No description provided for @themeBrandBlue.
  ///
  /// In en, this message translates to:
  /// **'Brand Blue'**
  String get themeBrandBlue;

  /// No description provided for @themePurpleM3.
  ///
  /// In en, this message translates to:
  /// **'Purple M3'**
  String get themePurpleM3;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'TRY NOW'**
  String get tryNow;

  /// No description provided for @popularProducts.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popularProducts;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select Size'**
  String get selectSize;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'added to cart'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'VIEW CART'**
  String get viewCart;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @exploreProducts.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE PRODUCTS'**
  String get exploreProducts;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'removed'**
  String get removed;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'undo'**
  String get undo;

  /// No description provided for @movedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'moved to wishlist'**
  String get movedToWishlist;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @goToPayment.
  ///
  /// In en, this message translates to:
  /// **'GO TO PAYMENT'**
  String get goToPayment;

  /// No description provided for @removeItemConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Item?'**
  String get removeItemConfirmTitle;

  /// No description provided for @removeItemConfirmBody1.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \''**
  String get removeItemConfirmBody1;

  /// No description provided for @removeItemConfirmBody2.
  ///
  /// In en, this message translates to:
  /// **'\' from your cart?'**
  String get removeItemConfirmBody2;

  /// No description provided for @dontAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get dontAskAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get remove;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'search for chocolate, truffle...'**
  String get searchHint;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFORMATION'**
  String get personalInformation;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default Address'**
  String get defaultAddress;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get app;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'ORDER HISTORY'**
  String get orderHistory;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switchAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @icons.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get icons;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @gifting.
  ///
  /// In en, this message translates to:
  /// **'Gifting'**
  String get gifting;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'PLACE ORDER'**
  String get placeOrder;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @enterCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your card details'**
  String get enterCardDetails;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get yourName;

  /// No description provided for @deliveryLocation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Location'**
  String get deliveryLocation;

  /// No description provided for @selectLocationMethod.
  ///
  /// In en, this message translates to:
  /// **'Select how you\'d like to set your address'**
  String get selectLocationMethod;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @typeAddressManually.
  ///
  /// In en, this message translates to:
  /// **'Type Address Manually'**
  String get typeAddressManually;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notNow;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enterAddress;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full delivery address...'**
  String get addressHint;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'SAVE ADDRESS'**
  String get saveAddress;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number for delivery updates'**
  String get phoneHint;

  /// No description provided for @confirmNumber.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM NUMBER'**
  String get confirmNumber;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable GPS.'**
  String get locationDisabled;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied'**
  String get locationDenied;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermanentlyDenied;

  /// No description provided for @errorFetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error fetching location'**
  String get errorFetchingLocation;

  /// No description provided for @applePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order #{id}'**
  String orderId(String id);

  /// No description provided for @selectGenderError.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender (Boy or Girl)'**
  String get selectGenderError;

  /// No description provided for @completeMixError.
  ///
  /// In en, this message translates to:
  /// **'Please complete your mix selection ({current}/{max} PCS)'**
  String completeMixError(int current, int max);

  /// No description provided for @completeRequirementsError.
  ///
  /// In en, this message translates to:
  /// **'Please complete all selection requirements'**
  String get completeRequirementsError;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSaved;

  /// No description provided for @addedToCartSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{product} added to cart'**
  String addedToCartSnackbar(String product);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART'**
  String get addToCart;

  /// No description provided for @addToCartWithDetails.
  ///
  /// In en, this message translates to:
  /// **'ADD TO CART ({details}₪ {price})'**
  String addToCartWithDetails(String details, String price);

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'{product} removed from wishlist'**
  String removedFromWishlist(String product);

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'{product} added to wishlist'**
  String addedToWishlist(String product);

  /// No description provided for @viewWishlist.
  ///
  /// In en, this message translates to:
  /// **'VIEW WISHLIST'**
  String get viewWishlist;

  /// No description provided for @productDescriptionDefault.
  ///
  /// In en, this message translates to:
  /// **'A luxurious collection, custom-built or pre-mixed with legendary fillings.'**
  String get productDescriptionDefault;

  /// No description provided for @changeSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Size?'**
  String get changeSizeTitle;

  /// No description provided for @changeSizeBody.
  ///
  /// In en, this message translates to:
  /// **'Changing the box size will reset your custom mix. Are you sure?'**
  String get changeSizeBody;

  /// No description provided for @yesReset.
  ///
  /// In en, this message translates to:
  /// **'YES, RESET'**
  String get yesReset;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'BOY'**
  String get boy;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'GIRL'**
  String get girl;

  /// No description provided for @selectedFillings.
  ///
  /// In en, this message translates to:
  /// **'SELECTED FILLINGS'**
  String get selectedFillings;

  /// No description provided for @editMix.
  ///
  /// In en, this message translates to:
  /// **'Edit Mix'**
  String get editMix;

  /// No description provided for @customizeMix.
  ///
  /// In en, this message translates to:
  /// **'Customize Mix'**
  String get customizeMix;

  /// No description provided for @swipeUpToExpand.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to expand...'**
  String get swipeUpToExpand;

  /// No description provided for @pcs.
  ///
  /// In en, this message translates to:
  /// **'PCS'**
  String get pcs;

  /// No description provided for @fillPistachio.
  ///
  /// In en, this message translates to:
  /// **'Pistachio Dream'**
  String get fillPistachio;

  /// No description provided for @fillNutella.
  ///
  /// In en, this message translates to:
  /// **'Nutella Swirl'**
  String get fillNutella;

  /// No description provided for @fillLotus.
  ///
  /// In en, this message translates to:
  /// **'Lotus Crunch'**
  String get fillLotus;

  /// No description provided for @fillDarkTruffle.
  ///
  /// In en, this message translates to:
  /// **'Dark Truffle'**
  String get fillDarkTruffle;

  /// No description provided for @fillHazelnut.
  ///
  /// In en, this message translates to:
  /// **'Hazelnut'**
  String get fillHazelnut;

  /// No description provided for @fillWhiteChocolate.
  ///
  /// In en, this message translates to:
  /// **'White Chocolate'**
  String get fillWhiteChocolate;

  /// No description provided for @fillCaramelSalt.
  ///
  /// In en, this message translates to:
  /// **'Caramel Salt'**
  String get fillCaramelSalt;

  /// No description provided for @fillBerryMix.
  ///
  /// In en, this message translates to:
  /// **'Berry Mix'**
  String get fillBerryMix;

  /// No description provided for @fillCoffeeBean.
  ///
  /// In en, this message translates to:
  /// **'Coffee Bean'**
  String get fillCoffeeBean;

  /// No description provided for @fillAlmondCrisp.
  ///
  /// In en, this message translates to:
  /// **'Almond Crisp'**
  String get fillAlmondCrisp;

  /// No description provided for @specialMix.
  ///
  /// In en, this message translates to:
  /// **'Special Mix'**
  String get specialMix;

  /// No description provided for @deleteCacheDebug.
  ///
  /// In en, this message translates to:
  /// **'Delete Cache (Debug)'**
  String get deleteCacheDebug;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get navWishlist;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @noProductsInCollection.
  ///
  /// In en, this message translates to:
  /// **'No products in this collection'**
  String get noProductsInCollection;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLoading(String error);

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'All your\nBest Chocolates'**
  String get onboardingTitle;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @welcomeSard.
  ///
  /// In en, this message translates to:
  /// **'Welcome Sard'**
  String get welcomeSard;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @completeRecovery.
  ///
  /// In en, this message translates to:
  /// **'Complete Recovery'**
  String get completeRecovery;

  /// No description provided for @chooseFavoriteMenu.
  ///
  /// In en, this message translates to:
  /// **'Choose your favorite menu and join us'**
  String get chooseFavoriteMenu;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Have an account? Sign In'**
  String get haveAccountSignIn;

  /// No description provided for @newHereCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create Account'**
  String get newHereCreateAccount;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with '**
  String get continueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @enterEmailPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password.'**
  String get enterEmailPasswordError;

  /// No description provided for @enterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get enterNameError;

  /// No description provided for @incorrectEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get incorrectEmailPassword;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please wait a few minutes and try again.'**
  String get tooManyAttempts;

  /// No description provided for @noAccountFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get noAccountFound;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get incorrectPassword;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get accountDisabled;

  /// No description provided for @verifyEmailCheckInbox.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before signing in. Check your inbox.'**
  String get verifyEmailCheckInbox;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Please sign in instead.'**
  String get accountAlreadyExists;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registrationFailed;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent'**
  String get emailSent;

  /// No description provided for @checkInboxResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox to reset your password.'**
  String get checkInboxResetPassword;

  /// No description provided for @selectContactDetailsReset.
  ///
  /// In en, this message translates to:
  /// **'select which contact details should we use to reset your password'**
  String get selectContactDetailsReset;

  /// No description provided for @sendToYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Send to your email'**
  String get sendToYourEmail;

  /// No description provided for @sendToYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Send to your Phone number'**
  String get sendToYourPhone;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get notConfigured;

  /// No description provided for @smsResetGatewayError.
  ///
  /// In en, this message translates to:
  /// **'SMS reset gateway not configured. Please use Email.'**
  String get smsResetGatewayError;

  /// No description provided for @errorText.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorText;

  /// No description provided for @createAccountChooseMenu.
  ///
  /// In en, this message translates to:
  /// **'Create account and choose favorite menu'**
  String get createAccountChooseMenu;

  /// No description provided for @registrationFailedDetail.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please check if \'Email Link\' is enabled in your Firebase Console and that you haven\'t exceeded email limits. Error: {error}'**
  String registrationFailedDetail(String error);

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// No description provided for @verificationLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email.\nClick the link to activate your account.'**
  String get verificationLinkSent;

  /// No description provided for @didntReceiveEmailTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email?\nTry again'**
  String get didntReceiveEmailTryAgain;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
