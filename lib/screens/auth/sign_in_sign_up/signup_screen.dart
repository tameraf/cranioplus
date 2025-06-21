import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kivicare_patient/components/app_logo_widget.dart';
import 'package:kivicare_patient/utils/constants.dart';

import '../../../components/app_scaffold.dart';
import '../../../configs.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import 'sign_up_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      isLoading: signUpController.isLoading,
      hasLeadingWidget: false,
      clipBehaviorSplitRegion: Clip.none,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedScrollView(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                locale.value.createYourAccount,
                style: primaryTextStyle(size: 24),
              ),
              8.height,
              Text(
                locale.value.registerYourAccountForBetterExperience,
                style: secondaryTextStyle(size: 14),
              ),
              SizedBox(height: Get.height * 0.05),
              Form(
                key: signUpController.signUpformKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    16.height,
                    AppTextField(
                      title: locale.value.firstName,
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.firstNameCont,
                      focus: signUpController.fisrtNameFocus,
                      nextFocus: signUpController.lastNameFocus,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG} ${locale.value.merry}",
                      ),
                      suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, size: 14).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      title: locale.value.lastName,
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.lastNameCont,
                      focus: signUpController.lastNameFocus,
                      nextFocus: signUpController.emailFocus,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG}  ${locale.value.doe}",
                      ),
                      suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, size: 14).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      title: locale.value.email,
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.emailCont,
                      focus: signUpController.emailFocus,
                      nextFocus: signUpController.passwordFocus,
                      textFieldType: TextFieldType.EMAIL_ENHANCED,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG} merry_456@gmail.com",
                      ),
                      suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, size: 14).paddingAll(14),
                    ),
                    16.height,
                    AppTextField(
                      title: locale.value.password,
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.passwordCont,
                      focus: signUpController.passwordFocus,
                      textFieldType: TextFieldType.PASSWORD,
                      obscureText: true,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG} #1234@1567",
                      ),
                      isValidationRequired: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return locale.value.thisFieldIsRequired;
                        }
                        if (value.length < 8 || value.length > 14) {
                          return locale.value.passwordLengthShouldBe8To14Characters;
                        }
                        return null;
                      },
                      suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, size: 14).paddingAll(12),
                      suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, size: 14).paddingAll(12),
                    ),
                    16.height,
                    Column(
                      children: [
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                checkColor: whiteColor,
                                value: signUpController.isAcceptedTc.value,
                                activeColor: appColorPrimary,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                splashRadius: 0,
                                shape: RoundedRectangleBorder(borderRadius: radius(0)),
                                side: const BorderSide(color: secondaryTextColor, width: 1.5),
                                onChanged: (val) async {
                                  signUpController.isAcceptedTc.value = !signUpController.isAcceptedTc.value;
                                },
                              ),
                              8.width,
                              RichTextWidget(
                                list: [
                                  TextSpan(text: "${locale.value.iAgreeToThe} ", style: secondaryTextStyle()),
                                  TextSpan(
                                    text: locale.value.termsConditions,
                                    style: primaryTextStyle(color: appColorPrimary, size: 12, decoration: TextDecoration.underline, decorationColor: appColorPrimary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        commonLaunchUrl(TERMS_CONDITION_URL, launchMode: LaunchMode.externalApplication);
                                      },
                                  ),
                                  TextSpan(text: " ${locale.value.and} ", style: secondaryTextStyle()),
                                  TextSpan(
                                    text: locale.value.privacyPolicy,
                                    style: primaryTextStyle(color: appColorPrimary, size: 12, decoration: TextDecoration.underline, decorationColor: appColorPrimary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        commonLaunchUrl(PRIVACY_POLICY_URL, launchMode: LaunchMode.externalApplication);
                                      },
                                  ),
                                ],
                              ).expand(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    AppButton(
                      width: Get.width,
                      text: locale.value.signUp,
                      color: appColorSecondary,
                      textStyle: appButtonTextStyleWhite,
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                      onTap: () {
                        if (signUpController.signUpformKey.currentState!.validate()) {
                          signUpController.signUpformKey.currentState!.save();
                          signUpController.saveForm();
                        }
                      },
                    ),
                  ],
                ),
              ).paddingSymmetric(horizontal: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(locale.value.alreadyHaveAnAccount, style: secondaryTextStyle()),
                  4.width,
                  InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Text(
                        locale.value.signIn,
                        style: boldTextStyle(
                          size: 12,
                          color: appColorSecondary,
                          decorationColor: appColorSecondary,
                        ),
                      )),
                ],
              ).paddingOnly(top: 16),
            ],
          ).paddingOnly(top: Get.height * 0.11),
          Positioned(
            width: Get.width,
            top: -Constants.appLogoSize / 2,
            child: const AppLogoWidget(),
          ),
        ],
      ),
    );
  }
}
