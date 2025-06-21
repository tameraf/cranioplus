// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/auth_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';

class ForgetPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  final GlobalKey<FormState> forgotPassFormKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();

  saveForm() async {
    isLoading(true);
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      'email': emailCont.text.trim(),
    };

    await AuthServiceApis.forgotPasswordAPI(request: req).then((value) async {
      isLoading(false);
      toast(value.message.isNotEmpty ? value.message : locale.value.weHaveEmailedYourPasswordResetLink);
      Get.back();
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }
}
