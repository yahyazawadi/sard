// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Boilerplate';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get myWishlist => 'My Wishlist';

  @override
  String get wishlistEmpty => 'Your wishlist is empty';

  @override
  String get movedToCart => 'moved to cart';

  @override
  String get removeFromWishlistTitle => 'Remove from Wishlist?';

  @override
  String get removeFromWishlistBody1 => 'Are you sure you want to remove \'';

  @override
  String get removeFromWishlistBody2 => '\' from your heart list?';

  @override
  String get keep => 'KEEP';

  @override
  String get themeStyle => 'Theme Style';

  @override
  String get appearanceMode => 'Appearance Mode';

  @override
  String get systemAuto => 'System (auto)';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get textSize => 'Text Size';

  @override
  String get usingSystemSize => 'Using system size';

  @override
  String get resetToSystem => 'Reset to System';

  @override
  String get themeMandyRed => 'Mandy Red';

  @override
  String get themeRedWine => 'Red Wine';

  @override
  String get themeDeepPurple => 'Deep Purple';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themePurpleBrown => 'Purple Brown';

  @override
  String get themeJungle => 'Jungle';

  @override
  String get themeShadBlue => 'Shad Blue';

  @override
  String get themeSanJuanBlue => 'San Juan Blue';

  @override
  String get themeIndigo => 'Indigo';

  @override
  String get themeBrandBlue => 'Brand Blue';

  @override
  String get themePurpleM3 => 'Purple M3';

  @override
  String get search => 'Search';

  @override
  String get all => 'ALL';

  @override
  String get featured => 'Featured';

  @override
  String get tryNow => 'TRY NOW';

  @override
  String get popularProducts => 'Popular Products';

  @override
  String get selectSize => 'Select Size';

  @override
  String get addedToCart => 'added to cart';

  @override
  String get viewCart => 'VIEW CART';

  @override
  String get myCart => 'My Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get exploreProducts => 'EXPLORE PRODUCTS';

  @override
  String get item => 'Item';

  @override
  String get items => 'Items';

  @override
  String get removed => 'removed';

  @override
  String get undo => 'undo';

  @override
  String get movedToWishlist => 'moved to wishlist';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get total => 'Total';

  @override
  String get goToPayment => 'GO TO PAYMENT';

  @override
  String get removeItemConfirmTitle => 'Remove Item?';

  @override
  String get removeItemConfirmBody1 => 'Are you sure you want to remove \'';

  @override
  String get removeItemConfirmBody2 => '\' from your cart?';

  @override
  String get dontAskAgain => 'Don\'t ask again';

  @override
  String get cancel => 'CANCEL';

  @override
  String get remove => 'REMOVE';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get searchHint => 'search for chocolate, truffle...';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get personalInformation => 'PERSONAL INFORMATION';

  @override
  String get defaultAddress => 'Default Address';

  @override
  String get notSet => 'Not set';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get app => 'APP';

  @override
  String get appearance => 'Appearance';

  @override
  String get orderHistory => 'ORDER HISTORY';

  @override
  String get switchAccount => 'Switch Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get icons => 'Icons';

  @override
  String get daily => 'Daily';

  @override
  String get gifting => 'Gifting';

  @override
  String get specialty => 'Specialty';

  @override
  String get checkout => 'Checkout';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get placeOrder => 'PLACE ORDER';

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String get enterCardDetails => 'Enter your card details';

  @override
  String get payNow => 'Pay Now';

  @override
  String get yourName => 'YOUR NAME';

  @override
  String get deliveryLocation => 'Delivery Location';

  @override
  String get selectLocationMethod =>
      'Select how you\'d like to set your address';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get typeAddressManually => 'Type Address Manually';

  @override
  String get notNow => 'NOT NOW';

  @override
  String get enterAddress => 'Enter Address';

  @override
  String get addressHint => 'Enter your full delivery address...';

  @override
  String get saveAddress => 'SAVE ADDRESS';

  @override
  String get contactNumber => 'Contact Number';

  @override
  String get phoneHint => 'Enter your phone number for delivery updates';

  @override
  String get confirmNumber => 'CONFIRM NUMBER';

  @override
  String get locationDisabled =>
      'Location services are disabled. Please enable GPS.';

  @override
  String get locationDenied => 'Location permissions are denied';

  @override
  String get locationPermanentlyDenied =>
      'Location permissions are permanently denied.';

  @override
  String get errorFetchingLocation => 'Error fetching location';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get cash => 'Cash';

  @override
  String orderId(String id) {
    return 'Order #$id';
  }

  @override
  String get selectGenderError => 'Please select a gender (Boy or Girl)';

  @override
  String completeMixError(int current, int max) {
    return 'Please complete your mix selection ($current/$max PCS)';
  }

  @override
  String get completeRequirementsError =>
      'Please complete all selection requirements';

  @override
  String get changesSaved => 'Changes saved successfully';

  @override
  String addedToCartSnackbar(String product) {
    return '$product added to cart';
  }

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String addToCartWithDetails(String details, String price) {
    return 'ADD TO CART ($details₪ $price)';
  }

  @override
  String removedFromWishlist(String product) {
    return '$product removed from wishlist';
  }

  @override
  String addedToWishlist(String product) {
    return '$product added to wishlist';
  }

  @override
  String get viewWishlist => 'VIEW WISHLIST';

  @override
  String get productDescriptionDefault =>
      'A luxurious collection, custom-built or pre-mixed with legendary fillings.';

  @override
  String get changeSizeTitle => 'Change Size?';

  @override
  String get changeSizeBody =>
      'Changing the box size will reset your custom mix. Are you sure?';

  @override
  String get yesReset => 'YES, RESET';

  @override
  String get boy => 'BOY';

  @override
  String get girl => 'GIRL';

  @override
  String get selectedFillings => 'SELECTED FILLINGS';

  @override
  String get editMix => 'Edit Mix';

  @override
  String get customizeMix => 'Customize Mix';

  @override
  String get swipeUpToExpand => 'Swipe up to expand...';

  @override
  String get pcs => 'PCS';

  @override
  String get fillPistachio => 'Pistachio Dream';

  @override
  String get fillNutella => 'Nutella Swirl';

  @override
  String get fillLotus => 'Lotus Crunch';

  @override
  String get fillDarkTruffle => 'Dark Truffle';

  @override
  String get fillHazelnut => 'Hazelnut';

  @override
  String get fillWhiteChocolate => 'White Chocolate';

  @override
  String get fillCaramelSalt => 'Caramel Salt';

  @override
  String get fillBerryMix => 'Berry Mix';

  @override
  String get fillCoffeeBean => 'Coffee Bean';

  @override
  String get fillAlmondCrisp => 'Almond Crisp';

  @override
  String get specialMix => 'Special Mix';

  @override
  String get deleteCacheDebug => 'Delete Cache (Debug)';

  @override
  String get navHome => 'Home';

  @override
  String get navWishlist => 'Wishlist';

  @override
  String get navCart => 'Cart';

  @override
  String get noProductsInCollection => 'No products in this collection';

  @override
  String errorLoading(String error) {
    return 'Error: $error';
  }

  @override
  String get onboardingTitle => 'All your\nBest Chocolates';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logIn => 'Log In';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get getStarted => 'Get Started';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get welcomeSard => 'Welcome Sard';

  @override
  String get createAccount => 'Create Account';

  @override
  String get completeRecovery => 'Complete Recovery';

  @override
  String get chooseFavoriteMenu => 'Choose your favorite menu and join us';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get haveAccountSignIn => 'Have an account? Sign In';

  @override
  String get newHereCreateAccount => 'New here? Create Account';

  @override
  String get continueWith => 'Continue with ';

  @override
  String get google => 'Google';

  @override
  String get enterEmailPasswordError => 'Please enter email and password.';

  @override
  String get enterNameError => 'Please enter your name.';

  @override
  String get incorrectEmailPassword =>
      'Incorrect email or password. Please try again.';

  @override
  String get tooManyAttempts =>
      'Too many failed attempts. Please wait a few minutes and try again.';

  @override
  String get noAccountFound => 'No account found with this email.';

  @override
  String get incorrectPassword => 'Incorrect password. Please try again.';

  @override
  String get accountDisabled => 'This account has been disabled.';

  @override
  String get verifyEmailCheckInbox =>
      'Please verify your email before signing in. Check your inbox.';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get accountAlreadyExists =>
      'An account already exists with this email. Please sign in instead.';

  @override
  String get registrationFailed => 'Registration Failed';

  @override
  String get loginFailed => 'Login Failed';

  @override
  String get ok => 'OK';

  @override
  String get emailSent => 'Email Sent';

  @override
  String get checkInboxResetPassword =>
      'Check your inbox to reset your password.';

  @override
  String get selectContactDetailsReset =>
      'select which contact details should we use to reset your password';

  @override
  String get sendToYourEmail => 'Send to your email';

  @override
  String get sendToYourPhone => 'Send to your Phone number';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get continueText => 'Continue';

  @override
  String get notConfigured => 'Not Configured';

  @override
  String get smsResetGatewayError =>
      'SMS reset gateway not configured. Please use Email.';

  @override
  String get errorText => 'Error';

  @override
  String get createAccountChooseMenu =>
      'Create account and choose favorite menu';

  @override
  String registrationFailedDetail(String error) {
    return 'Registration failed. Please check if \'Email Link\' is enabled in your Firebase Console and that you haven\'t exceeded email limits. Error: $error';
  }

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get verificationLinkSent =>
      'We sent a verification link to your email.\nClick the link to activate your account.';

  @override
  String get didntReceiveEmailTryAgain =>
      'Didn\'t receive the email?\nTry again';

  @override
  String get productNotFound => 'Product not found';
}
