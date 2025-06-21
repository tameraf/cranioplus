// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../api/auth_apis.dart';
import 'sign_in_controller.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  final GlobalKey<FormState> signUpformKey = GlobalKey();

  RxBool agree = false.obs;
  RxBool isAcceptedTc = false.obs;
  TextEditingController emailCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode fisrtNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  saveForm() async {
    if (isAcceptedTc.value) {
      isLoading(true);
      hideKeyBoardWithoutContext();
      Map<String, dynamic> req = {
        "email": emailCont.text.trim(),
        "first_name": firstNameCont.text.trim(),
        "last_name": lastNameCont.text.trim(),
        "password": passwordCont.text.trim(),
        UserKeys.userType: LoginTypeConst.LOGIN_TYPE_USER,
      };

      await AuthServiceApis.createUser(request: req).then((value) async {
        toast(value.message.toString(), print: true);
        try {
          final SignInController sCont = Get.find();
          sCont.emailCont.text = emailCont.text.trim();
          sCont.passwordCont.text = passwordCont.text.trim();
          sCont.isNavigateToDashboard(true);
          sCont.userName("${firstNameCont.text.trim()} ${lastNameCont.text.trim()}");
          isLoading(true);
          sCont.saveForm().whenComplete(() => isLoading(false));
        } catch (e) {
          log('E: $e');
          toast(e.toString(), print: true);
        }
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
    }).whenComplete(() => isLoading(false));
    } else {
      toast(locale.value.pleaseAcceptTermsAnd);
    }
  }
}
