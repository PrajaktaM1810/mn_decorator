import 'package:flutter/gestures.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/controllers/deliveryman_registration_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBoxWidget extends StatelessWidget {
  final bool forDeliveryMan;
  final bool forSignUp;
  const ConditionCheckBoxWidget({super.key, this.forDeliveryMan = false, this.forSignUp = true});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: forDeliveryMan ? MainAxisAlignment.start : MainAxisAlignment.center, children: [

      forDeliveryMan ? GetBuilder<DeliverymanRegistrationController>(builder: (dmRegController) {
        return GetBuilder<AuthController>(builder: (authController) {
          return Checkbox(
            activeColor: Theme.of(context).primaryColor,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            value: forSignUp ? authController.acceptTerms : dmRegController.acceptTerms,
            onChanged: (bool? isChecked) => forSignUp ? authController.toggleTerms() : dmRegController.toggleTerms(),
          );
        });
      }) : const SizedBox(),

      forDeliveryMan ? const SizedBox() : Text( '* ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

      Flexible(
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: forDeliveryMan ? 'i_agree_with_all_the'.tr :'by_login_i_agree_with_all_the'.tr,
              style: robotoRegular.copyWith(color: forDeliveryMan ? Theme.of(context).textTheme.bodyMedium!.color : Theme.of(context).hintColor, fontSize: forDeliveryMan ? Dimensions.fontSizeDefault : Dimensions.fontSizeSmall),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
                  text: 'terms_conditions'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
                TextSpan(
                  text: ' & ',
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
                  text: 'privacy_policy'.tr,
                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),

          ]),
        ),
      ),

    ]);
  }
}
