import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/clinic/clinic_list_controller.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../api/core_apis.dart';
import '../../../utils/constants.dart';
import '../../category/model/category_list_model.dart';
import '../../clinic/model/clinic_detail_model.dart';
import '../../clinic/model/clinics_res_model.dart';
import '../../doctor/doctor_list_controller.dart';
import '../../service/service_list_controller.dart';
import 'components/clinic_filter/filter_clinic_component.dart';
import 'components/filter_category.dart';
import 'components/filter_service.dart';
import 'components/price_filter/filter_price_component.dart';
import 'components/rating_filter.dart';
import 'components/service_type_filter/filter_service_type_component.dart';

class FilterController extends GetxController {
  RxString filterType = "".obs;


  //Clinic List
  Rx<Future<RxList<Clinic>>> clinicListFuture = Future(() => RxList<Clinic>()).obs;
  RxBool isClinicLoading = false.obs;
  RxList<Clinic> clinicList = RxList();
  RxBool isClinicLastPage = false.obs;
  RxInt clinicPage = 1.obs;
  RxBool isSearchClinicText = false.obs;
  TextEditingController searchClinicCont = TextEditingController();
  StreamController<String> searchClinicStream = StreamController<String>();
  Rx<Clinic> selectedClinicData = Clinic(clinicSession: ClinicSession()).obs;

  // Service
  Rx<Future<RxList<ServiceElement>>> serviceListFuture = Future(() => RxList<ServiceElement>()).obs;
  RxBool isServiceLoading = false.obs;
  RxList<ServiceElement> serviceList = RxList();
  RxBool isServiceLastPage = false.obs;
  RxInt servicePage = 1.obs;
  RxBool isSearchServiceText = false.obs;
  TextEditingController searchServiceCont = TextEditingController();
  StreamController<String> searchServiceStream = StreamController<String>();
  final scrollServiceController = ScrollController();
  Rx<CategoryElement> selectedCategoryData = CategoryElement().obs;

  // Service
  Rx<Future<RxList<CategoryElement>>> categoryListFuture = Future(() => RxList<CategoryElement>()).obs;
  RxBool isCategoryLoading = false.obs;
  RxList<CategoryElement> categoryList = RxList();
  RxBool isCategoryLastPage = false.obs;
  RxInt categoryPage = 1.obs;
  RxBool isSearchCategoryText = false.obs;
  TextEditingController searchCategoryCont = TextEditingController();
  StreamController<String> searchCategoryStream = StreamController<String>();
  final _scrollCategoryController = ScrollController();
  Rx<ServiceElement> selectedServiceData = ServiceElement().obs;

  RxDouble minimumPrice = (0.0).obs;
  RxDouble maximumPrice = (5000.0).obs;

  RxDouble minimumRating = (0.0).obs;
  RxDouble maximumRating = (5.0).obs;
  Rx<RangeValues> rangeValues = const RangeValues(1, 5000).obs;
  Rx<RangeValues> rangeRatingValues = const RangeValues(1, 5).obs;

  RxList filterList = [locale.value.clinic, locale.value.filterService, locale.value.filterRating].obs;
  RxList serviceFilterList = [locale.value.clinic, locale.value.price, locale.value.category].obs;
  RxList clinicFilterList = [locale.value.filterService].obs;
  RxList categoryFilterList = [locale.value.clinic, locale.value.price].obs;

  RxList serviceTypeList = [
    {"title": "In Clinic", "value": ServiceTypeConst.inClinic},
    {"title": "Online", "value": ServiceTypeConst.online}
  ].obs;
  RxString selectedServiceType = "".obs;

  @override
  void onInit() {
    if (Get.arguments is List) {
      if (Get.arguments[0] is int) {
        selectedClinicData(Clinic(id: Get.arguments[0], clinicSession: ClinicSession()));
        seleClinicFilterCount(1);
      }

      if (Get.arguments[1] is String) {
        selectedServiceType(Get.arguments[1]);
      }

      if (Get.arguments[2] is String) {
        minimumPrice((Get.arguments[2] as String).toDouble() > 0 ? (Get.arguments[2] as String).toDouble() : 1);
      }

      if (Get.arguments[3] is String) {
        maximumPrice((Get.arguments[3] as String).toDouble() > 0 ? (Get.arguments[3] as String).toDouble() : 5000);
      }

      rangeValues(RangeValues(minimumPrice.value, maximumPrice.value));

      if (Get.arguments[4] == "service") {
        filterType(serviceFilterList[0]);
      } else if (Get.arguments[4] == "clinic") {
        filterType(clinicFilterList[0]);
      } else if (Get.arguments[4] == "category") {
        filterType(categoryFilterList[0]);
      } else {
        filterType(filterList[0]);
      }
    }
    if (Get.arguments[5] is int) {
      selectedCategoryData(CategoryElement(id: Get.arguments[5]));
    }

    getClinic();
    getCategory();
    getService();

    super.onInit();
  }

  void setMaxPrice(double val) {
    maximumPrice(val);
  }

  void setMinPrice(double val) {
    minimumPrice(val);
  }

  void setMaxRating(double val) {
    maximumRating(val);
  }

  void setMinRating(double val) {
    minimumRating(val);
  }

  //get Clinic Info
  getClinic() {
    searchClinicStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getClinicsList();
    });
    getClinicsList();
  }

  getService() {
    scrollServiceController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchServiceStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getServicesList();
    });
    getServicesList();
  }

  getCategory() {
    _scrollCategoryController.addListener(() => Get.context != null ? hideKeyboard(Get.context) : null);
    searchCategoryStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getCategoryList();
    });
    getCategoryList();
  }

  getClinicsList({bool showLoader = true, String search = ""}) async {
    if (showLoader) {
      isClinicLoading(true);
    }
    await clinicListFuture(
      CoreServiceApis.getClinics(
        page: clinicPage.value,
        search: searchClinicCont.text.trim(),
        clinics: clinicList,
        lastPageCallBack: (p0) {
          isClinicLastPage(p0);
        },
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isClinicLoading(false);
      log('getClinics: $e');
    }).whenComplete(() => isClinicLoading(false));
  }

  getServicesList({bool showLoader = true, String search = ""}) async {
    if (showLoader) {
      isServiceLoading(true);
    }
    await serviceListFuture(
      CoreServiceApis.getServiceList(
        serviceList: serviceList,
        page: servicePage.value,
        allServices: 'all',
        lastPageCallBack: (p0) {
          isServiceLastPage(p0);
        },
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isServiceLoading(false);
      log('getClinics: $e');
    }).whenComplete(() => isServiceLoading(false));
  }

  getCategoryList({bool showLoader = true, String search = ""}) async {
    if (showLoader) {
      isCategoryLoading(true);
    }
    await categoryListFuture(
      CoreServiceApis.getCategoryList(
        categories: categoryList,
        page: categoryPage.value,
        lastPageCallBack: (p0) {
          isCategoryLastPage(p0);
        },
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isCategoryLoading(false);
      log('getClinics: $e');
    }).whenComplete(() => isCategoryLoading(false));
  }

  RxInt appliedFilterCount = 0.obs;

  resetFilter(String moduleType, String filterType) {
    selectedClinicData(Clinic(clinicSession: ClinicSession()));
    totalServiceCount(0).obs;
    totalDoctorCount(0).obs;
    seleFilterCount(0).obs;
    selePriceFilterCount(0).obs;
    seleRatingFilterCount(0).obs;
    seleClinicFilterCount(0).obs;
    seleCategoryFilterCount(0).obs;
    selectedServiceType("");
    minimumPrice(0.0);
    maximumPrice(0.0);
    minimumRating(0.0);
    maximumRating(0.0);
    rangeValues(const RangeValues(1, 5000));
    rangeRatingValues(const RangeValues(1, 5));

    if (filterType != 'category') {
      selectedCategoryData(CategoryElement());
      selectedServiceData(ServiceElement());
    }

    applyFilter(moduleType, isReset: true);
  }

  viewFilterWidget(String displayValue) {
    log("filter type--------------${filterType.value}");
    switch (filterType.value) {
      case "Price":
        return displayValue == 'service' || displayValue == 'category' ? FilterPriceComponent().expand(flex: 3).visible(displayValue == 'service' || displayValue == 'category') : SizedBox();
      case "Clinic":
        return FilterClinicComponent().expand(flex: 3).visible(displayValue == "doctor" || displayValue == "service" || displayValue == 'category');
      case "Service Type":
        return FilterServiceTypeComponent().expand(flex: 3);
      case "Category":
        return FilterServiceComponent().expand(flex: 3).visible(displayValue == "service");
      case "Service":
        return displayValue == 'doctor' || displayValue == 'clinic' || displayValue == 'category'
            ? FilterCategoryComponent().expand(flex: 3).visible(displayValue == 'doctor' || displayValue == 'clinic' || displayValue == 'category')
            : SizedBox().expand(flex: 3).visible(displayValue == 'doctor');
      case "Rating":
        return FilterRatingComponent().expand(flex: 3).visible(displayValue == 'doctor');
      default:
        return FilterServiceComponent().expand(flex: 3);
    }
  }

  Rx<ServiceElement> filterServiceData = ServiceElement().obs;
  RxInt seleFilterCount = 0.obs;

  void selectedServiceDataFunc(ServiceElement service) {
    if (filterServiceData.value.id != service.id) {
      filterServiceData.value = service;
      selectedServiceData(service);
    } else {
      filterServiceData.value = ServiceElement();
    }
    if (seleFilterCount.value == 0) seleFilterCount++;
  }

  Rx<Clinic> filterClinicData = Clinic(clinicSession: ClinicSession()).obs;
  RxInt seleClinicFilterCount = 0.obs;

  void selectedClinicDataFunc(Clinic clinic) {
    if (filterClinicData.value.id != clinic.id) {
      filterClinicData.value = clinic;
      selectedClinicData(clinic);
    } else {
      filterClinicData.value = Clinic(clinicSession: ClinicSession());
    }
    if (seleClinicFilterCount.value == 0) seleClinicFilterCount++;
  }

  RxInt get totalDoctorCount => (seleFilterCount.value + seleClinicFilterCount.value + seleRatingFilterCount.value).obs;

  Rx<CategoryElement> filterCategoryData = CategoryElement().obs;
  RxInt seleCategoryFilterCount = 0.obs;

  void selectedCategoryDataFunc(CategoryElement category) {
    if (filterCategoryData.value.id != category.id) {
      filterCategoryData.value = category;
      selectedCategoryData(category);
    } else {
      filterCategoryData.value = CategoryElement();
    }
    if (seleCategoryFilterCount.value == 0) seleCategoryFilterCount++;
  }

  RxInt get totalServiceCount => (seleCategoryFilterCount.value + seleClinicFilterCount.value + selePriceFilterCount.value).obs;
  RxInt seleRatingFilterCount = 0.obs;
  RxInt selePriceFilterCount = 0.obs;

  void applyFilterCount() {
    if (minimumRating.value > 0.0 && maximumRating.value > 0.0 && seleRatingFilterCount.value == 0) seleRatingFilterCount++;
    if (minimumPrice.value > 0.0 && maximumPrice.value > 0.0 && selePriceFilterCount.value == 0) selePriceFilterCount++;
  }

  RxInt get totalCategoryCount => (seleClinicFilterCount.value + selePriceFilterCount.value).obs;

  Future<void> applyFilter(String type, {bool isReset = false, String newFilterType = ''}) async {
    if (type == "service") {
      ServiceListController serviceCont = Get.find();
      serviceCont.clinicId(selectedClinicData.value.id);
      serviceCont.serviceType(selectedServiceType.value);

      serviceCont.priceMin(minimumPrice.value > 0 ? minimumPrice.value.toString() : "");
      serviceCont.priceMax(maximumPrice.value > 0 ? maximumPrice.value.toString() : "");
      serviceCont.serviceData(selectedServiceData.value);
      serviceCont.category(selectedCategoryData.value);
      serviceCont.categoryId(selectedCategoryData.value.id);
      applyFilterCount();
      serviceCont.refresh();
      Get.back(result: totalCategoryCount.value);
      serviceCont.getServiceList();
    } else if (type == 'doctor') {
      DoctorListController doctorConte = Get.find();
      doctorConte.clinicId(selectedClinicData.value.id);
      doctorConte.serviceType(selectedServiceType.value);
      doctorConte.ratingMin(minimumRating.value > 0 ? minimumRating.value.toString() : "");
      doctorConte.ratingMax(maximumRating.value > 0 ? maximumRating.value.toString() : "");
      currentSelectedService(selectedServiceData.value);
      applyFilterCount();
      Get.back(
        result: {
          'totalDoctorCount': totalDoctorCount.value,
        },
      );

      doctorConte.getDoctors();
    } else if (type == 'clinic') {
      ClinicListController clinicCont = Get.find();
      clinicCont.clinicId(selectedClinicData.value.id);
      clinicCont.service(selectedServiceData.value);

      clinicCont.priceMin(minimumPrice.value > 0 ? minimumPrice.value.toString() : "");
      clinicCont.priceMax(maximumPrice.value > 0 ? maximumPrice.value.toString() : "");
      applyFilterCount();
      Get.back(result: totalCategoryCount.value);
      clinicCont.page(1);
      clinicCont.getClinicList();
    }
  }

  @override
  void onClose() {
    searchClinicStream.close();
    super.onClose();
  }
}
