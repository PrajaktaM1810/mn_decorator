import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/validate_check.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromSocialLogin;
  final SocialLogInBody? socialLogInBody;
  const ForgetPassScreen({super.key, required this.fromSocialLogin, required this.socialLogInBody});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _numberController = TextEditingController();
  String? _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
  final GlobalKey<FormState> _formKeyPhone = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.fromSocialLogin ? 'phone'.tr : 'forgot_password'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Center(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: Container(
          width: context.width > 700 ? 700 : context.width,
          padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
          margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: Column(children: [
            Image.asset(Images.forgot, height: 220),

            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('please_enter_mobile'.tr, style: robotoRegular, textAlign: TextAlign.center),
            ),

            Form(
              key: _formKeyPhone,
              child: CustomTextField(
                titleText: 'enter_email_address'.tr,
                controller: _numberController,
                inputType: TextInputType.phone,
                inputAction: TextInputAction.done,
                isPhone: true,
                showTitle: ResponsiveHelper.isDesktop(context),
                onCountryChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                },
                labelText: 'phone'.tr,
                validator: (value) => ValidateCheck.validatePhone(value, null),
                countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                    : Get.find<LocalizationController>().locale.countryCode,
                onSubmit: (text) => GetPlatform.isWeb ? _forgetPass(_countryDialCode!) : null,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            GetBuilder<AuthController>(
              builder: (authController) {
                return GetBuilder<VerificationController>(builder: (verificationController) {
                  return CustomButton(
                    buttonText: 'next'.tr,
                    isLoading: verificationController.isLoading || authController.isLoading,
                    onPressed: () => _forgetPass(_countryDialCode!),
                  );
                });
              }
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            RichText(text: TextSpan(children: [
              TextSpan(
                text: '${'if_you_have_any_queries_feel_free_to_contact_with_our'.tr} ',
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
              ),
              TextSpan(
                text: 'help_and_support'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.toNamed(RouteHelper.getSupportRoute()),
              ),
            ]), textAlign: TextAlign.center, maxLines: 3),

          ]),
        )),
      ))),
    );
  }

  void _forgetPass(String countryCode) async {
    String phone = _numberController.text.trim();

    String numberWithCountryCode = countryCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if(_formKeyPhone.currentState!.validate()) {
      if (phone.isEmpty) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      }else if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_email_id'.tr);
      }else {
        if(widget.fromSocialLogin) {
          widget.socialLogInBody!.phone = numberWithCountryCode;
          String? deviceToken = await Get.find<AuthController>().saveDeviceToken();
          widget.socialLogInBody!.deviceToken = deviceToken;
          Get.find<AuthController>().registerWithSocialMedia(widget.socialLogInBody!);
        }else {
          Get.find<VerificationController>().forgetPassword(numberWithCountryCode).then((status) async {
            if (status.isSuccess) {
              if(Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
                Get.find<AuthController>().firebaseVerifyPhoneNumber(numberWithCountryCode, '', fromSignUp: false);
              } else {
                Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, '', RouteHelper.forgotPassword, ''));
              }
            }else {
              showCustomSnackBar(status.message);
            }
          });
        }
      }
    }
    }

}


// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/gestures.dart';
// import 'package:sixam_mart/features/language/controllers/language_controller.dart';
// import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
// import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
// import 'package:sixam_mart/features/auth/domain/models/social_log_in_body.dart';
// import 'package:sixam_mart/features/verification/controllers/verification_controller.dart';
// import 'package:sixam_mart/helper/custom_validator.dart';
// import 'package:sixam_mart/helper/responsive_helper.dart';
// import 'package:sixam_mart/helper/route_helper.dart';
// import 'package:sixam_mart/helper/validate_check.dart';
// import 'package:sixam_mart/util/dimensions.dart';
// import 'package:sixam_mart/util/images.dart';
// import 'package:sixam_mart/util/styles.dart';
// import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
// import 'package:sixam_mart/common/widgets/custom_button.dart';
// import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
// import 'package:sixam_mart/common/widgets/custom_text_field.dart';
// import 'package:sixam_mart/common/widgets/footer_view.dart';
// import 'package:sixam_mart/common/widgets/menu_drawer.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ForgetPassScreen extends StatefulWidget {
//   final bool fromSocialLogin;
//   final SocialLogInBody? socialLogInBody;
//   const ForgetPassScreen({super.key, required this.fromSocialLogin, required this.socialLogInBody});
//
//   @override
//   State<ForgetPassScreen> createState() => _ForgetPassScreenState();
// }
//
// class _ForgetPassScreenState extends State<ForgetPassScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final GlobalKey<FormState> _formKeyEmail = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: widget.fromSocialLogin ? 'email'.tr : 'forgot_password'.tr),
//       endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
//       body: SafeArea(child: Center(child: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: FooterView(child: Container(
//           width: context.width > 700 ? 700 : context.width,
//           padding: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
//           margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//           decoration: context.width > 700 ? BoxDecoration(
//             color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//             boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
//           ) : null,
//           child: Column(children: [
//
//             Image.asset(Images.forgot, height: 220),
//
//             Padding(
//               padding: const EdgeInsets.all(30),
//               child: Text('Please enter your registered Email Id so that we can help you to recover your password.', style: robotoRegular, textAlign: TextAlign.center),
//             ),
//
//             Form(
//               key: _formKeyEmail,
//               child: CustomTextField(
//                 titleText: 'enter_email_address'.tr,
//                 controller: _emailController,
//                 inputType: TextInputType.emailAddress,
//                 inputAction: TextInputAction.done,
//                 showTitle: ResponsiveHelper.isDesktop(context),
//                 labelText: 'email'.tr,
//                 validator: (value) => ValidateCheck.validateEmail(value),
//                 onSubmit: (text) => GetPlatform.isWeb ? _forgetPass() : null,
//               ),
//             ),
//             const SizedBox(height: Dimensions.paddingSizeExtraLarge),
//
//             GetBuilder<AuthController>(
//                 builder: (authController) {
//                   return GetBuilder<VerificationController>(builder: (verificationController) {
//                     return CustomButton(
//                       buttonText: 'next'.tr,
//                       isLoading: verificationController.isLoading || authController.isLoading,
//                       onPressed: _forgetPass,
//                     );
//                   });
//                 }
//             ),
//             const SizedBox(height: Dimensions.paddingSizeExtraLarge),
//
//             RichText(text: TextSpan(children: [
//               TextSpan(
//                 text: '${'if_you_have_any_queries_feel_free_to_contact_with_our'.tr} ',
//                 style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
//               ),
//               TextSpan(
//                 text: 'help_and_support'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () => Get.toNamed(RouteHelper.getSupportRoute()),
//               ),
//             ]), textAlign: TextAlign.center, maxLines: 3),
//
//           ]),
//         )),
//       ))),
//     );
//   }
//
//   void _forgetPass() async {
//     String email = _emailController.text.trim();
//
//     if(_formKeyEmail.currentState!.validate()) {
//       if (email.isEmpty) {
//         showCustomSnackBar('enter_a_valid_email_address'.tr);
//       }else if (!GetUtils.isEmail(email)) {
//         showCustomSnackBar('invalid_email_id'.tr);
//       }else {
//         if(widget.fromSocialLogin) {
//           widget.socialLogInBody!.email = email;
//           String? deviceToken = await Get.find<AuthController>().saveDeviceToken();
//           widget.socialLogInBody!.deviceToken = deviceToken;
//           Get.find<AuthController>().registerWithSocialMedia(widget.socialLogInBody!);
//         }else {
//           Get.find<VerificationController>().forgetPassword(email).then((status) async {
//             if (status.isSuccess) {
//               Get.toNamed(RouteHelper.getVerificationRoute(email, '', RouteHelper.forgotPassword, ''));
//             }else {
//               showCustomSnackBar(status.message);
//             }
//           });
//         }
//       }
//     }
//   }
// }
