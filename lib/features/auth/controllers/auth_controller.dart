import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/common/models/response_model.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/auth/domain/models/signup_body_model.dart';
import 'package:sixam_mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:sixam_mart/helper/route_helper.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}){
    _notification = authServiceInterface.isSharedPrefNotificationActive();
  }

  bool _notification = true;
  bool get notification => _notification;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _guestLoading = false;
  bool get guestLoading => _guestLoading;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _isActiveRememberMe = true;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  Future<ResponseModel> registration(SignUpBodyModel signUpBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.registration(signUpBody, Get.find<SplashController>().configModel!.customerVerification!);
    if (responseModel.isSuccess && !Get.find<SplashController>().configModel!.customerVerification!) {
      Get.find<ProfileController>().getUserInfo();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> login(String? phone, String password) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(phone: phone, password: password, isCustomerVerificationOn: Get.find<SplashController>().configModel!.customerVerification!);
    if (responseModel.isSuccess && !Get.find<SplashController>().configModel!.customerVerification! && responseModel.isPhoneVerified!) {
      Get.find<ProfileController>().getUserInfo();
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  @override
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_id");
  }

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.guestLogin();
    _guestLoading = false;
    update();
    return responseModel;
  }

  Future<void> loginWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    bool canNavigateToLocation = await authServiceInterface.loginWithSocialMedia(socialLogInBody, 60, Get.find<SplashController>().configModel!.customerVerification!);
    if(canNavigateToLocation) {
      Get.find<LocationController>().navigateToLocationScreen('sign-in');
    }
    _isLoading = false;
    update();
  }

  Future<void> registerWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    bool canNavigateToLocationScreen = await authServiceInterface.registerWithSocialMedia(socialLogInBody, Get.find<SplashController>().configModel!.customerVerification!);
    if(canNavigateToLocationScreen) {
      Get.find<LocationController>().navigateToLocationScreen('sign-in');
    }
    _isLoading = false;
    update();
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  bool isGuestLoggedIn() {
    return authServiceInterface.isGuestLoggedIn();
  }

  String getGuestId() {
    return authServiceInterface.getSharedPrefGuestId();
  }

  Future<bool> clearSharedData({bool removeToken = true}) async {
    Get.find<SplashController>().setModule(null);
    return await authServiceInterface.clearSharedData(removeToken: removeToken);
  }

  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  Future<bool> clearSharedAddress() async {
    return await authServiceInterface.clearSharedAddress();
  }

  Future<void> saveUserNumberAndPasswordSharedPref(String number, String password, String countryCode) async {
    await authServiceInterface.saveUserNumberAndPassword(number, password, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<void> updateZone() async {
    await authServiceInterface.updateZone();
  }

  Future<void> saveGuestNumber(String number) async {
    await authServiceInterface.saveGuestContactNumber(number);
  }

  String getGuestNumber() {
    return authServiceInterface.getGuestContactNumber();
  }

  ///TODO: need to move these in required controller..
  Future<void> saveDmTipIndex(String i) async {
    await authServiceInterface.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return authServiceInterface.getDmTipIndex();
  }

  void saveEarningPoint(String point){
    authServiceInterface.saveEarningPoint(point);
  }

  String getEarningPint() {
    return authServiceInterface.getEarningPint();
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    await authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  Future<String?> saveDeviceToken() async {
    return await authServiceInterface.saveDeviceToken();
  }

  Future<void> firebaseVerifyPhoneNumber(String phoneNumber, String? token, {bool fromSignUp = true, bool canRoute = true})async {
    _isLoading = true;
    update();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        update();

        if(e.code == 'invalid-phone-number') {
          showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
        }else{
          showCustomSnackBar(e.message?.replaceAll('_', ' '));
        }

      },
      codeSent: (String vId, int? resendToken) {

        _isLoading = false;
        update();

        if(canRoute) {
          Get.toNamed(RouteHelper.getVerificationRoute(phoneNumber, token, fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword, '', session: vId));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

  }

}
