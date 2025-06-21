import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:kivicare_patient/screens/other_patient/model/other_patient_list_res.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/clinic/model/clinics_res_model.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';

import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../screens/Encounter/model/encounter_list_model.dart';
import '../screens/auth/model/login_response.dart';
import '../screens/booking/model/appointment_detail_res.dart';
import '../screens/booking/model/appointment_invoice_res.dart';
import '../screens/booking/model/appointment_status_model.dart';
import '../screens/booking/model/appointments_res_model.dart';
import '../screens/booking/model/doctor_review_res_model.dart';
import '../screens/booking/model/employee_review_data.dart';
import '../screens/booking/model/encounter_detail_model.dart';
import '../screens/booking/model/save_booking_res.dart';
import '../screens/category/model/category_list_model.dart';
import '../screens/clinic/model/clinic_detail_model.dart';
import '../screens/clinic/model/clinic_gallery_model.dart';
import '../screens/doctor/model/doctor_detail_model.dart';
import '../screens/doctor/model/doctor_list_res.dart';
import '../screens/home/model/system_service_res.dart';
import '../screens/service/model/service_detail_model.dart';
import '../screens/slots/appointment_slot_model.dart';
import '../utils/api_end_points.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';

class CoreServiceApis {
  static Future<RxList<SystemService>> getSystemService({
    int page = 1,
    int perPage = 10,
    required List<SystemService> systemServiceList,
    Function(bool)? lastPageCallBack,
    int? categoryId,
  }) async {
    String catId = (categoryId != null && categoryId != -1) ? '&category_id=$categoryId' : '';
    final systemServiceListRes = SystemServicesRes.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getSystemService}?per_page=$perPage&page=$page$catId", method: HttpMethodType.GET),
    ));
    if (page == 1) systemServiceList.clear();
    systemServiceList.addAll(systemServiceListRes.data);
    lastPageCallBack?.call(systemServiceListRes.data.length != perPage);
    return systemServiceList.obs;
  }

  static Future<RxList<CategoryElement>> getCategoryList({
    int page = 1,
    int perPage = 50,
    required List<CategoryElement> categories,
    Function(bool)? lastPageCallBack,
  }) async {
    final categoryListRes = CategoryListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getCategoryList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) categories.clear();
    categories.addAll(categoryListRes.data);
    lastPageCallBack?.call(categoryListRes.data.length != perPage);
    return categories.obs;
  }

  static Future<RxList<EncounterElement>> getEncounterList({
    int page = 1,
    int perPage = 10,
    required List<EncounterElement> encounterList,
    Function(bool)? lastPageCallBack,
  }) async {
    final encounterListRes = EncounterListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getEncounterList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) encounterList.clear();
    encounterList.addAll(encounterListRes.data);
    lastPageCallBack?.call(encounterListRes.data.length != perPage);
    return encounterList.obs;
  }

  static Future<RxList<ServiceElement>> getServiceList({
    int page = 1,
    int perPage = 10,
    required List<ServiceElement> serviceList,
    Function(bool)? lastPageCallBack,
    String search = "",
    String serviceType = "",
    String servicePriceMin = "",
    String servicePriceMax = "",
    int? categoryId,
    int? systemServiceId,
    int? clinicId,
    int? doctorId,
    int isFeatures = -1,
    int isPopulars = -1,
    int enableAdvancePayment = -1,
    String allServices = "",
  }) async {
    String catId = (categoryId != null && categoryId != -1) ? '&category_id=$categoryId' : '';
    String clinicid = (clinicId != null && clinicId != -1) ? '&clinic_id=$clinicId' : '';
    String sysServiceId = (systemServiceId != null && systemServiceId != -1) ? '&system_service_id=$systemServiceId' : '';
    String docId = (doctorId != null && doctorId != -1) ? '&doctor_id=$doctorId' : '';
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    String type = serviceType.isNotEmpty ? '&type=$serviceType' : '';
    String priceMin = servicePriceMin.isNotEmpty ? '&is_price_min=$servicePriceMin' : '';
    String priceMax = servicePriceMax.isNotEmpty ? '&is_price_max=$servicePriceMax' : '';
    String isFeature = isFeatures != -1 ? '&is_features=$isFeatures' : '';
    String isPopular = isPopulars != -1 ? '&is_popular=$isPopulars' : '';
    String isEdvance = enableAdvancePayment != -1 ? '&is_enable_advance_payment=$enableAdvancePayment' : '';
    String totalPage = allServices == 'all' ?'all':perPage.toString();

    final serviceListRes = ServiceListRes.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getServiceList}?per_page=$totalPage&page=$page$searchService$catId$sysServiceId$clinicid$docId$isFeature$type$priceMin$priceMax$isEdvance$isPopular", method:
      HttpMethodType.GET),
    ));
    if (page == 1) serviceList.clear();
    serviceList.addAll(serviceListRes.data);
    lastPageCallBack?.call(serviceListRes.data.length != perPage);
    return serviceList.obs;
  }

  static Future<RxList<ServiceElement>> getDoctorServiceList({
    int page = 1,
    int perPage = 10,
    required List<ServiceElement> serviceList,
    Function(bool)? lastPageCallBack,
    int? doctorId,
    String search = "",
  }) async {
    String docId = (doctorId != null && doctorId != -1) ? '&doctor_id=$doctorId' : '';
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    final doctorServiceListRes = ServiceListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getServiceList}?per_page=$perPage&page=$page$docId$searchService", method: HttpMethodType.GET)));
    if (page == 1) serviceList.clear();
    serviceList.addAll(doctorServiceListRes.data);
    lastPageCallBack?.call(doctorServiceListRes.data.length != perPage);
    return serviceList.obs;
  }

  static Future<ServiceDetailModel> getServiceDetail({required int serviceId}) async {
    return ServiceDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getServiceDetails}?service_id=$serviceId', method: HttpMethodType.GET)));
  }

  static Future<ClinicDetailModel> getClinicDetails({required int clinicId}) async {
    return ClinicDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getClinicDetails}?clinic_id=$clinicId', method: HttpMethodType.GET)));
  }

  static Future<DoctorDetailModel> getDoctorDetails({required int doctorId}) async {
    return DoctorDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getDoctorDetails}?doctor_id=$doctorId', method: HttpMethodType.GET)));
  }

  static Future<RxList<Clinic>> getClinics({
    int page = 1,
    int perPage = 10,
    required List<Clinic> clinics,
    Function(bool)? lastPageCallBack,
    String servicePriceMin = "",
    String servicePriceMax = "",
    String search = '',
    int? serviceId,
    int? isPopulars = -1,
    int? clinicId,
  }) async {
    String servId = (serviceId != null && serviceId != -1) ? '&service_id=$serviceId' : '';
    String searchClinic = search.isNotEmpty ? '&search=$search' : '';
    String isPopular = isPopulars != -1 ? '&is_popular=$isPopulars' : '';
    String priceMin = servicePriceMin.isNotEmpty ? '&is_price_min=$servicePriceMin' : '';
    String priceMax = servicePriceMax.isNotEmpty ? '&is_price_max=$servicePriceMax' : '';
    String clinicid = (clinicId != null && clinicId != -1) ? '&clinic_id=$clinicId' : '';
    final clinicsRes = ClinicsRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinicList}?per_page=$perPage&page=$page$servId$searchClinic$priceMin$priceMax$clinicid$isPopular", method: HttpMethodType.GET)));
    if (page == 1) clinics.clear();
    clinics.addAll(clinicsRes.data);
    lastPageCallBack?.call(clinicsRes.data.length != perPage);
    return clinics.obs;
  }

  static Future<RxList<GalleryData>> getClinicGalleryList({
    int page = 1,
    int perPage = 10,
    required List<GalleryData> galleryList,
    Function(bool)? lastPageCallBack,
    int clinicId = -1,
  }) async {
    String clncId = clinicId != -1 ? '&clinic_id=$clinicId' : '';
    final galleryListRes = ClinicGalleryModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinicGallery}?per_page=$perPage&page=$page$clncId", method: HttpMethodType.GET)));
    if (page == 1) galleryList.clear();
    galleryList.addAll(galleryListRes.data);
    lastPageCallBack?.call(galleryListRes.data.length != perPage);
    return galleryList.obs;
  }

  static Future<RxList<Doctor>> getDoctors({
    int page = 1,
    int perPage = 10,
    required List<Doctor> doctors,
    Function(bool)? lastPageCallBack,
    String? doctorRatingMin = '',
    String? doctorRatingMax = '',
    String search = "",
    int clinicId = -1,
    int? serviceId,
    int? isPopulars = -1,
  }) async {

    String clncId = clinicId != -1 ? '&clinic_id=$clinicId' : '';
    String doctorMinRating = doctorRatingMin != '' ? '&is_rating_min=$doctorRatingMin' : '';
    String doctorMaxRating = doctorRatingMax != '' ? '&is_rating_max=$doctorRatingMax' : '';
    String servId = serviceId != null ? '&service_id=$serviceId' : '';
    String searchDoctor = search.isNotEmpty ? '&search=$search' : '';
    String isPopular = isPopulars != -1 ? '&is_popular=$isPopulars' : '';
    final doctorListRes = DoctorListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getDoctorList}?per_page=$perPage&page=$page$clncId$servId$searchDoctor$isPopular$doctorMinRating$doctorMaxRating", method: HttpMethodType.GET)));
    if (page == 1) doctors.clear();
    doctors.addAll(doctorListRes.data);
    lastPageCallBack?.call(doctorListRes.data.length != perPage);
    return doctors.obs;
  }

  static Future<RxList<String>> getTimeSlots({
    required RxList<String> slots,
    required String date,
    required int clinicId,
    required int doctorId,
    required int serviceId,
  }) async {
    final timeSlotsRes = TimeSlotsRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getTimeSlots}?appointment_date=$date&doctor_id=$doctorId&clinic_id=$clinicId&service_id=$serviceId", method: HttpMethodType.GET)));
    slots(timeSlotsRes.slots);
    return slots;
  }

  static Future<void> bookServiceApi({required Map<String, dynamic> request, List<PlatformFile>? files, required VoidCallback onSuccess, required VoidCallback loaderOff}) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.saveBooking);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'file_url'));
    }

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      // toast(baseResponseModel.message, print: true);
      try {
        saveBookingRes(SaveBookingRes.fromJson(jsonDecode(temp)));
      } catch (e) {
        log('SaveBookingRes.fromJson E: $e');
      }
      onSuccess.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
      loaderOff.call();
    });
  }

  static Future<RxList<AppointmentData>> getAppointmentList({
    String filterByStatus = '',
    String filterByService = '',
    int page = 1,
    String search = '',
    int perPage = Constants.perPageItem,
    required List<AppointmentData> appointments,
    Function(bool)? lastPageCallBack,
  }) async {
    String searchBooking = search.isNotEmpty ? '&search=$search' : '';
    String statusFilter = '';
    if (filterByStatus.isNotEmpty) {
      if (filterByStatus == AppointmentStatus.all.name) {
        statusFilter = '';
      } else if (filterByStatus == AppointmentStatus.upcoming.name) {
        String status = '${filterByStatus}_appointment';
        statusFilter = '&$status';
      } else if (filterByStatus == AppointmentStatus.completed.name) {
        statusFilter = '&status=checkout';
      }
    } else {
      statusFilter = '';
    }
    String serviceFilter = filterByService.isNotEmpty ? '&system_service_name=$filterByService' : '';
    final bookingRes = AppointmentListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointments}?page=$page&per_page=$perPage$statusFilter$serviceFilter$searchBooking", method: HttpMethodType.GET)));
    if (page == 1) appointments.clear();
    appointments.addAll(bookingRes.data.validate());

    lastPageCallBack?.call(bookingRes.data.validate().length != perPage);

    return appointments.obs;
  }

  static Future<AppointmentDetailRes> getAppointmentDetail({required int appointmentId, String notifyId = "",}) async {
     String notificationId = notifyId.trim().isNotEmpty ? '&notification_id=$notifyId' : '';
    return AppointmentDetailRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointmentDetail}?appointment_id=$appointmentId$notificationId", method: HttpMethodType.GET)));
  }

  static Future<Rx<AppointmentInvoiceResp>> appointmentInvoice(int appointmentId) async {
    final res = AppointmentInvoiceResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.downloadInvoice}?id=$appointmentId", method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<EncounterDetailModel> getEncounterDetail({required int encounterId}) async {
    return EncounterDetailModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.encounterDashboardDetail}?encounter_id=$encounterId", method: HttpMethodType.GET)));
  }

  static Future<BaseResponseModel> updateStatus({required Map request, required int appointmentId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.updateStatus}/$appointmentId', request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> rescheduleBooking({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.rescheduleBooking, request: request, method: HttpMethodType.POST)));
  }


  static Future<BaseResponseModel> updateReview({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveRating, request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> deleteReview({required int id}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.deleteRating, request: {"id": id}, method: HttpMethodType.POST)));
  }

  static Future<RxList<DoctorReviewData>> getDoctorReviews({
    int page = 1,
    int perPage = Constants.perPageItem,
    required List<DoctorReviewData> reviewList,
    Function(bool)? lastPageCallBack,
    int doctorId = -1,
  }) async {
    String docId = doctorId != -1 ? '&doctor_id=$doctorId' : '';
    final reviewRes = DoctorReviewRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getRating}?per_page=$perPage&page=$page$docId", method: HttpMethodType.GET)));
    if (page == 1) reviewList.clear();
    reviewList.addAll(reviewRes.reviewData);
    lastPageCallBack?.call(reviewRes.reviewData.length != perPage);
    return reviewList.obs;
  }

  //Payment
  static Future<BaseResponseModel> savePayment({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.savePayment, request: request, method: HttpMethodType.POST)));
  }

  /// Fetch Other Patient List
  static Future<RxList<UserData>> otherMemberPatientList({
    int page = 1,
    int perPage = 10,
    required List<UserData> memberList,
    Function(bool)? lastPageCallBack,
  }) async {
    OtherPatientListRes memberListRes = OtherPatientListRes.fromJson(await handleResponse(await buildHttpResponse(
      "${APIEndPoints.otherMemberPatientList}?per_page=$perPage&page=$page",
      method: HttpMethodType.GET,
    )));
    if (page == 1) memberList.clear();
    memberList.addAll(memberListRes.data);
    lastPageCallBack?.call(memberListRes.data.length != perPage);
    return memberList.obs;
  }

  /// Add/Update Other Patient List
  static Future<BaseResponseModel> addUpdateOtherPatientApi({
    required Map<String, dynamic> request,
    File? profileImage,
  }) async {
    return BaseResponseModel.fromJson(
      await buildMultiPartResponse(
        endPoint: APIEndPoints.addPatient,
        request: request,
        fileKey: UserKeys.profileImage,
        files: profileImage != null ? [profileImage] : [],
      ),
    );
  }

  static Future<BaseResponseModel> deleteMember({required int memberId}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(
        '${APIEndPoints.deleteOtherMember}/$memberId',
        method: HttpMethodType.POST,
      )),
    );
  }
}