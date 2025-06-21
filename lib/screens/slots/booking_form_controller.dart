import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';
import '../auth/model/login_response.dart';
import '../booking/model/booking_req.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/model/doctor_list_res.dart';
import '../other_patient/manage_other_patient_controller.dart';
import '../service/model/service_list_model.dart';
import 'components/appointment_summary_comp.dart';

class BookingFormController extends GetxController {
  Rx<Future<RxList<String>>> slotsFuture = Future(() => RxList<String>()).obs;
  RxBool isLoading = false.obs;
  RxBool nextBtnVisible = false.obs;
  RxList<String> slots = RxList();
  RxString selectedDate = DateTime.now().formatDateYYYYmmdd().obs;
  RxString selectedSlot = "".obs;

  final ManageOtherPatientController manageOtherPatientController = ManageOtherPatientController();

  Rx<UserData> selectedMember = UserData().obs;

  RxList<PlatformFile> medicalReportFiles = RxList();

  BookingReq bookingReq = BookingReq();

  RxBool isLastPage = false.obs;
  RxInt servicePage = 1.obs;
  RxInt clinicPage = 1.obs;
  RxInt doctorPage = 1.obs;

  //Service
  Rx<ServiceElement> selectedService = ServiceElement().obs;
  RxList<ServiceElement> serviceList = RxList();

  //Error Service
  RxBool hasErrorFetchingService = false.obs;
  RxString errorMessageService = "".obs;

  //Clinic
  Rx<Clinic> selectedClinic = Clinic(clinicSession: ClinicSession()).obs;
  RxList<Clinic> clinicList = RxList();

  //Error Clinic
  RxBool hasErrorFetchingClinic = false.obs;
  RxString errorMessageClinic = "".obs;

  //Doctor
  Rx<Doctor> selectedDoctor = Doctor().obs;
  RxList<Doctor> doctorList = RxList();

  //Error Clinic
  RxBool hasErrorFetchingDoctor = false.obs;
  RxString errorMessageDoctor = "".obs;

  RxString serviceNameText = "".obs;
  RxString clinicNameText = "".obs;
  RxString doctorNameText = "".obs;
  TextEditingController medicalReportCont = TextEditingController();

  @override
  void onInit() {
    if (!currentSelectedService.value.id.isNegative) {
      log('currentSelectedService.value.name==> ${currentSelectedService.value.name}');
      log('currentSelectedService.value.id==> ${currentSelectedService.value.id}');
      selectedService(currentSelectedService.value);
      serviceNameText(currentSelectedService.value.name);
      getClinicList();
    }

    if (!currentSelectedClinic.value.id.isNegative) {
      log('currentSelectedClinic.value.name==> ${currentSelectedClinic.value.name}');
      log('currentSelectedClinic.value.id==> ${currentSelectedClinic.value.id}');
      selectedClinic(currentSelectedClinic.value);
      clinicNameText(currentSelectedClinic.value.name);
      getDoctorList();
    }

    if (!currentSelectedDoctor.value.doctorId.isNegative) {
      log('currentSelectedDoctor.value.name==> ${currentSelectedDoctor.value.fullName}');
      log('currentSelectedDoctor.value.doctorId==> ${currentSelectedDoctor.value.doctorId}');
      selectedDoctor(currentSelectedDoctor.value);
      doctorNameText(currentSelectedDoctor.value.fullName);
      getTimeSlot();
    }

    init();
    super.onInit();
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    getServiceList();
    await manageOtherPatientController.getOtherPatientList();
  }

  Future<void> handleFilesPickerClick() async {
    final pickedFiles = await pickFiles();
    Set<String> filePathsSet = medicalReportFiles.map((file) => file.name.trim().toLowerCase()).toSet();
    for (var i = 0; i < pickedFiles.length; i++) {
      if (!filePathsSet.contains(pickedFiles[i].name.trim().toLowerCase())) {
        medicalReportFiles.add(pickedFiles[i]);
      }
    }
  }

  ///Get Service List
  getServiceList({String searchText = ""}) {
    isLoading(true);
    CoreServiceApis.getServiceList(
      page: servicePage.value,
      serviceList: serviceList,
      categoryId: currentSelectedService.value.categoryId,
      systemServiceId: currentSelectedService.value.systemServiceId,
      clinicId: currentSelectedClinic.value.id,
      doctorId: currentSelectedDoctor.value.doctorId,
      search: searchText.trim(),
      lastPageCallBack: (p) {
        isLastPage(p);
      },
    ).then((value) {
      isLoading(false);
      hasErrorFetchingService(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingService(true);
      errorMessageService(error.toString());
      isLoading(false);
    });
  }

  ///Get Clinic List
  getClinicList({String searchText = ""}) {
    isLoading(true);
    CoreServiceApis.getClinics(
      page: clinicPage.value,
      clinics: clinicList,
      serviceId: selectedService.value.id,
      search: searchText.trim(),
      lastPageCallBack: (p) {
        isLastPage(p);
      },
    ).then((value) {
      isLoading(false);
      hasErrorFetchingClinic(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingClinic(true);
      errorMessageClinic(error.toString());
      isLoading(false);
    });
  }

  void clearDoctorSelection() {
    doctorNameText("");

    /// Clear selected doctor in doctor name field
    selectedDoctor(Doctor());
  }

  ///Get Doctor List
  getDoctorList({String searchText = ""}) {
    isLoading(true);
    CoreServiceApis.getDoctors(
      page: doctorPage.value,
      doctors: doctorList,
      clinicId: selectedClinic.value.id,
      serviceId: selectedService.value.id,
      search: searchText.trim(),
      lastPageCallBack: (p) {
        isLastPage(p);
      },
    ).then((value) async {
      isLoading(false);
      hasErrorFetchingDoctor(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingDoctor(true);
      errorMessageDoctor(error.toString());
      isLoading(false);
    });
  }

  Future<void> getTimeSlot({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    /// Get Time Slots Api Call
    await slotsFuture(
      CoreServiceApis.getTimeSlots(
        slots: slots,
        date: selectedDate.value,
        serviceId: selectedService.value.id,
        clinicId: selectedClinic.value.id,
        doctorId: selectedDoctor.value.doctorId,
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isLoading(false);
      log("getTimeSlots error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onDateTimeChange() {
    final appointmentDateTime = "${selectedDate.value} ${selectedSlot.value}";
    if (appointmentDateTime.isValidDateTime) {
      nextBtnVisible(true);
    } else {
      nextBtnVisible(false);
    }
  }

  handleNextClick(BuildContext context) {
    //BookingReq
    bookingReq.files = medicalReportFiles;
    bookingReq.clinicId = selectedClinic.value.id.toString();
    bookingReq.serviceId = selectedService.value.id.toString();
    bookingReq.appointmentDate = selectedDate.value;
    bookingReq.userId = loginUserData.value.id.toString();
    bookingReq.status = StatusConst.pending;
    bookingReq.doctorId = selectedDoctor.value.doctorId.toString();
    bookingReq.appointmentTime = selectedSlot.value;
    bookingReq.description = medicalReportCont.text;
    //
    bookingReq.serviceName = selectedService.value.name;
    bookingReq.doctorName = selectedDoctor.value.fullName;
    bookingReq.clinicName = selectedClinic.value.name;
    bookingReq.location = selectedClinic.value.address;
    bookingReq.totalAmount = totalAmount.toStringAsFixed(2).toDouble();
    bookingReq.isEnableAdvancePayment = selectedService.value.isEnableAdvancePayment;
    bookingReq.advancePayableAmount = advancePayableAmount;
    bookingReq.isOnlineService = selectedService.value.type.toLowerCase() == ServiceTypeConst.online;
    if (selectedMember.value.id > 0) {
      bookingReq.otherPatientId = selectedMember.value.id.toString();
    }
    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      builder: (_) {
        return AppointmentSummaryWidget(bookingData: bookingReq);
      },
    );
  }

  //----------------------------------------Price Calculation-----------------------------------
  AssignDoctor get finalAssignDoctor => selectedService.value.assignDoctor.firstWhere(
        (element) => element.doctorId == selectedDoctor.value.doctorId,
        orElse: () => AssignDoctor(
          priceDetail: PriceDetail(
            servicePrice: selectedService.value.charges,
            serviceAmount: selectedService.value.charges,
            discountAmount: selectedService.value.discountAmount,
            discountType: selectedService.value.discountType,
            discountValue: selectedService.value.discountValue,
            totalAmount: selectedService.value.payableAmount,
            duration: selectedService.value.duration,
          ),
        ),
      );

  double get fixedExclusiveTaxAmount => appConfigs.value.taxData
      .where((element) => (element.taxScope == TaxType.exclusiveTax) && (element.type.toLowerCase().contains(TaxType.FIXED.toLowerCase())))
      .sumByDouble((p0) => p0.value.validate());

  double get percentExclusiveTaxAmount => appConfigs.value.taxData.where((element) {
        return (element.taxScope == TaxType.exclusiveTax) && (element.type.toLowerCase().contains(TaxType.PERCENT.toLowerCase()));
      }).sumByDouble((p0) {
        return ((selectedService.value.assignDoctor.isNotEmpty ? finalAssignDoctor.priceDetail.serviceAmount * p0.value.validate() : selectedService.value.payableAmount * p0.value.validate()) / 100);
      });

  num get totalExclusiveTax => (fixedExclusiveTaxAmount + percentExclusiveTaxAmount).toStringAsFixed(Constants.DECIMAL_POINT).toDouble();

  num get totalAmount => (selectedService.value.assignDoctor.isNotEmpty
      ? (finalAssignDoctor.priceDetail.totalAmount) : (selectedService.value.payableAmount + totalExclusiveTax));

  num get advancePayableAmount => (totalAmount * selectedService.value.advancePaymentAmount) / 100;

  num get remainingAmountAfterService => totalAmount - advancePayableAmount;
}