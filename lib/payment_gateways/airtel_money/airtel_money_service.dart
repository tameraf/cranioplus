// ignore_for_file: constant_identifier_names, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../configs.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'airtel_payment_response.dart';
import 'package:uuid/uuid.dart';
import 'aritel_auth_model.dart';

class AirtelMoneyDialog extends StatefulWidget {
  final String reference;
  final int bookingId;
  final num amount;
  final Function(Map<String, dynamic>) onComplete;
  const AirtelMoneyDialog({
    super.key,
    required this.onComplete,
    required this.reference,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<AirtelMoneyDialog> createState() => _AirtelMoneyDialogState();
}

class _AirtelMoneyDialogState extends State<AirtelMoneyDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _textFieldMSISDN = TextEditingController();

  bool isTxnInProgress = false;
  bool isSuccess = false;
  bool isFailToGenerateReq = false;
  String responseCode = "";

  RxBool isLoading = false.obs;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: Get.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isFailToGenerateReq
                  ? Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                          child: const Icon(Icons.close_sharp, color: Colors.white),
                        ),
                        10.height,
                        Text(getAirtelMoneyReasonTextFromCode(responseCode).$1, style: boldTextStyle()),
                        16.height,
                        Text(getAirtelMoneyReasonTextFromCode(responseCode).$2, textAlign: TextAlign.center, style: secondaryTextStyle()),
                      ],
                    ).paddingAll(16)
                  : isSuccess
                      ? Column(
                          children: [
                            const CachedImageWidget(url: Assets.iconsIcVerified, height: 60),
                            10.height,
                            Text(locale.value.paymentSuccess, style: boldTextStyle()),
                            16.height,
                            Text(locale.value.redirectingToBookings, textAlign: TextAlign.center, style: secondaryTextStyle()),
                          ],
                        ).paddingAll(16)
                      : isTxnInProgress
                          ? Column(
                              children: [
                                const LoaderWidget(),
                                10.height,
                                Text(locale.value.transactionIsInProcess, style: boldTextStyle()),
                                16.height,
                                Text(locale.value.pleaseCheckThePayment, textAlign: TextAlign.center, style: secondaryTextStyle()),
                              ],
                            ).paddingAll(16)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Form(
                                  key: formKey,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: AppTextField(
                                    controller: _textFieldMSISDN,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: inputDecoration(context, labelText: locale.value.enterYourMsisdnHere),
                                  ),
                                ),
                                16.height,
                                AppButton(
                                  color: appColorPrimary,
                                  height: 40,
                                  text: locale.value.submit,
                                  textStyle: boldTextStyle(color: Colors.white),
                                  width: Get.width - context.navigationBarHeight,
                                  onTap: () {
                                    hideKeyboard(context);
                                    maxApiCallCount = 30;
                                    _handleClick();
                                  },
                                ),
                              ],
                            ).paddingAll(16)
            ],
          ),
        ),
        Obx(
          () => const LoaderWidget().withSize(height: 80, width: 80).visible(isLoading.value && !isTxnInProgress),
        )
      ],
    );
  }

  void _handleClick() async {
    String transactionId = "${const Uuid().v1()}-${widget.bookingId}";

    isFailToGenerateReq = false;
    responseCode = "";

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading(true);
      await authorizeAirtelClient().then((value) async {
        log('acess tokn ${value.accessToken}');
        await paymentAirtelClient(
          reference: APP_NAME,
          txnId: transactionId,
          msisdn: _textFieldMSISDN.text.trim(),
          amount: widget.amount,
          accessToken: value.accessToken.validate(),
        ).then((value) async {
          if (value.status != null && value.status!.responseCode == AirtelMoneyResponseCodes.IN_PROCESS) {
            isTxnInProgress = true;
            setState(() {});
            isSuccess = await checkAirtelPaymentStatus(
              transactionId,
              loderOnOFF: (p0) {
                isLoading(p0);
              },
            );
            setState(() {});
            if (isSuccess) {
              widget.onComplete.call({
                'transaction_id': transactionId,
              });
            }
          } else if (value.status != null) {
            isFailToGenerateReq = true;
            responseCode = value.status!.responseCode.validate();
            setState(() {});
          }
        });
        isLoading(false);
      });
    }
  }
}

//region airtel pay
Future<AirtelAuthModel> authorizeAirtelClient() async {
  Map<dynamic, dynamic>? request = {"client_id": appConfigs.value.airtelMoney.airtelClientid, "client_secret": appConfigs.value.airtelMoney.airtelSecretkey, "grant_type": "client_credentials"};
  return AirtelAuthModel.fromJson(await handleResponse(await airtelPayBuildHttpResponse('auth/oauth2/token', request: request, method: HttpMethodType.POST)));
}

Future<AirtelPaymentResponse> paymentAirtelClient({
  required String reference,
  required String accessToken,
  required String txnId,
  required String msisdn,
  required num amount,
}) async {
  Map<dynamic, dynamic>? request = {
    "reference": reference,
    "subscriber": {"country": airtel_country_code, "currency": airtel_currency_code, "msisdn": msisdn},
    "transaction": {"amount": amount, "country": airtel_country_code, "currency": airtel_currency_code, "id": txnId}
  };

  return AirtelPaymentResponse.fromJson(
    await handleResponse(
      await airtelPayBuildHttpResponse(
        'merchant/v1/payments/',
        request: request,
        method: HttpMethodType.POST,
        extraKeys: {'X-Country': airtel_country_code, 'X-Currency': airtel_currency_code, 'access_token': accessToken, 'isAirtelMoney': true},
      ),
    ),
  );
}

int maxApiCallCount = 30;
AirtelPaymentResponse res = AirtelPaymentResponse();
Future<bool> checkAirtelPaymentStatus(
  String txnId, {
  required Function(bool) loderOnOFF,
}) async {
  bool isSuccess = false;
  if (maxApiCallCount <= 0) {
    return isSuccess;
  }
  await authorizeAirtelClient().then((value) async {
    log('acess tokn ${value.accessToken}');
    log('maxApiCallCount is $maxApiCallCount');

    res = AirtelPaymentResponse.fromJson(await handleResponse(
        await airtelPayBuildHttpResponse('standard/v1/payments/$txnId', extraKeys: {'X-Country': airtel_country_code, 'X-Currency': airtel_currency_code, 'access_token': '${value.accessToken}', 'isAirtelMoney': true}, method: HttpMethodType.GET)));
    if (res.status != null && res.status!.responseCode == AirtelMoneyResponseCodes.SUCCESS) {
      isSuccess = true;
      return isSuccess;
    } else if (maxApiCallCount > 0 && res.status != null && res.status!.responseCode == AirtelMoneyResponseCodes.IN_PROCESS) {
      await Future.delayed(const Duration(seconds: 2));
      maxApiCallCount--;
      // toast("$maxApiCallCount");
      isSuccess = await checkAirtelPaymentStatus(txnId, loderOnOFF: loderOnOFF);
    } else {
      loderOnOFF(false);
      log('return here');
      return isSuccess;
    }
  });
  return isSuccess;
}

Future<Response> airtelPayBuildHttpResponse(
  String endPoint, {
  HttpMethodType method = HttpMethodType.GET,
  Map? request,
  Map? extraKeys,
}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderForAirtelMoney(extraKeys!['access_token'], extraKeys['X-Country'], extraKeys['X-Currency']);
    //  Uri url = buildBaseUrl(endPoint);
    Uri url = Uri.parse(endPoint);
    url = Uri.parse('$AIRTEL_BASE$endPoint');

    Response response;
    log('url : $url');
    if (method == HttpMethodType.POST) {
      log('Request: ${jsonEncode(request)}');
      response = await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethodType.DELETE) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethodType.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    log('Response (${method.name}) ${response.statusCode}: ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

// region AirtelMoney Const
class AirtelMoneyResponseCodes {
  static const AMBIGUOUS = "DP00800001000";
  static const SUCCESS = "DP00800001001";
  static const INCORRECT_PIN = "DP00800001002";
  static const LIMIT_EXCEEDED = "DP00800001003";
  static const INVALID_AMOUNT = "DP00800001004";
  static const INVALID_TRANSACTION_ID = "DP00800001005";
  static const IN_PROCESS = "DP00800001006";
  static const INSUFFICIENT_BALANCE = "DP00800001007";
  static const REFUSED = "DP00800001008";
  static const DO_NOT_HONOR = "DP00800001009";
  static const TRANSACTION_NOT_PERMITTED = "DP00800001010";
  static const TRANSACTION_TIMED_OUT = "DP00800001024";
  static const TRANSACTION_NOT_FOUND = "DP00800001025";
  static const FORBIDDEN = "DP00800001026";
  static const FETCHED_ENCRYPTION_KEY_SUCCESSFULLY = "DP00800001027";
  static const ERROR_FETCHING_ENCRYPTION_KEY = "DP00800001028";
  static const TRANSACTION_EXPIRED = "DP00800001029";
}

(String, String) getAirtelMoneyReasonTextFromCode(String code) {
  switch (code) {
    case AirtelMoneyResponseCodes.AMBIGUOUS:
      return (locale.value.ambiguous, locale.value.theTransactionIsStill);
    case AirtelMoneyResponseCodes.SUCCESS:
      return (locale.value.success, locale.value.transactionIsSuccessful);
    case AirtelMoneyResponseCodes.INCORRECT_PIN:
      return (locale.value.incorrectPin, locale.value.incorrectPinHasBeen);
    case AirtelMoneyResponseCodes.LIMIT_EXCEEDED:
      return (locale.value.exceedsWithdrawalAmountLimit, locale.value.theUserHasExceeded);
    case AirtelMoneyResponseCodes.INVALID_AMOUNT:
      return (locale.value.invalidAmount, locale.value.theAmountUserIs);
    case AirtelMoneyResponseCodes.INVALID_TRANSACTION_ID:
      return (locale.value.transactionIdIsInvalid, locale.value.userDidnTEnterThePin);
    case AirtelMoneyResponseCodes.IN_PROCESS:
      return (locale.value.inProcess, locale.value.transactionInPendingState);
    case AirtelMoneyResponseCodes.INSUFFICIENT_BALANCE:
      return (locale.value.notEnoughBalance, locale.value.userWalletDoesNot);
    case AirtelMoneyResponseCodes.REFUSED:
      return (locale.value.refused, locale.value.theTransactionWasRefused);
    case AirtelMoneyResponseCodes.DO_NOT_HONOR:
      return (locale.value.doNotHonor, locale.value.thisIsAGeneric);
    case AirtelMoneyResponseCodes.TRANSACTION_NOT_PERMITTED:
      return (locale.value.transactionNotPermittedTo, locale.value.payeeIsAlreadyInitiated);
    case AirtelMoneyResponseCodes.TRANSACTION_TIMED_OUT:
      return (locale.value.transactionTimedOut, locale.value.theTransactionWasTimed);
    case AirtelMoneyResponseCodes.TRANSACTION_NOT_FOUND:
      return (locale.value.transactionNotFound, locale.value.theTransactionWasNot);
    case AirtelMoneyResponseCodes.FORBIDDEN:
      return (locale.value.forbidden, locale.value.xSignatureAndPayloadDid);
    case AirtelMoneyResponseCodes.FETCHED_ENCRYPTION_KEY_SUCCESSFULLY:
      return (locale.value.successfullyFetchedEncryptionKey, locale.value.encryptionKeyHasBeen);
    case AirtelMoneyResponseCodes.ERROR_FETCHING_ENCRYPTION_KEY:
      return (locale.value.errorWhileFetchingEncryption, locale.value.couldNotFetchEncryption);
    case AirtelMoneyResponseCodes.TRANSACTION_EXPIRED:
      return (locale.value.transactionExpired, locale.value.transactionHasBeenExpired);
    default:
      return (locale.value.somethingWentWrong, locale.value.somethingWentWrong);
  }
}
//endregion AirtelMoney
