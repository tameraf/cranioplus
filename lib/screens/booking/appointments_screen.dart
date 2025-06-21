import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import 'appointments_controller.dart';
import 'components/appointment_card.dart';
import 'model/appointment_status_model.dart';

class AppointmentsScreen extends StatelessWidget {
  AppointmentsScreen({super.key});

  final AppointmentsController appointmentsCont = Get.put(AppointmentsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.appointments,
      hasLeadingWidget: false,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: appointmentsCont.isLoading,
      body: Obx(
        () => SnapHelperWidget(
          future: appointmentsCont.getAppointments.value,
          initialData: appointmentsCont.appointments.isNotEmpty ? appointmentsCont.appointments : null,
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () {
                appointmentsCont.page(1);
                appointmentsCont.getAppointmentList();
              },
            ).paddingSymmetric(horizontal: 16);
          },
          loadingWidget: appointmentsCont.isLoading.value ? const Offstage() : const LoaderWidget(),
          onSuccess: (booking) {
            return Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HorizontalList(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    spacing: 16,
                    itemCount:filterStatus.length,
                    itemBuilder: (ctx, index) {
                      AppointmentStatusModel filterStatus1 = filterStatus[index];
                      return Obx(
                        () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilterChip(
                              shape: RoundedRectangleBorder(borderRadius: radius(6), side: const BorderSide(color: Colors.transparent)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedImageWidget(
                                    url: filterStatus1.icon,
                                    fit: BoxFit.fitHeight,
                                    height: 14,
                                    color: appointmentsCont.selectedTab.value.type == filterStatus1.type ? whiteTextColor : secondaryTextColor,
                                  ),
                                  4.width,
                                  Text(
                                    filterStatus1.name!.value,
                                    style: boldTextStyle(
                                      size: 14,
                                      color: appointmentsCont.selectedTab.value.type == filterStatus1.type ? whiteTextColor : secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              selected: false,
                              backgroundColor: appointmentsCont.selectedTab.value.type == filterStatus1.type ? appColorSecondary : context.cardColor,
                              onSelected: (bool selected) {
                                appointmentsCont.selectedTab(filterStatus[index]);
                                appointmentsCont.page(1);
                                appointmentsCont.getAppointmentList(status: appointmentsCont.selectedTab.value.type.toString());
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  16.height,
                  AnimatedListView(
                    shrinkWrap: true,
                    itemCount: appointmentsCont.appointments.length,
                    listAnimationType: ListAnimationType.None,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    emptyWidget: NoDataWidget(
                      title: locale.value.noAppointmentsFound,
                      imageWidget: const EmptyStateWidget(),
                      subTitle: locale.value.thereAreCurrentlyNoAppointmentsAvailableStart,
                    ).paddingSymmetric(horizontal: 16).paddingBottom(Get.height * 0.1),
                    itemBuilder: (context, index) {
                      return AppointmentCard(
                        appointment: appointmentsCont.appointments[index],
                        onUpdateBooking: () {
                          appointmentsCont.page(1);
                          appointmentsCont.getAppointmentList();
                        },
                      ).paddingBottom(16);
                    },
                    onNextPage: () async {
                      if (!appointmentsCont.isLastPage.value) {
                        appointmentsCont.page(appointmentsCont.page.value + 1);
                        appointmentsCont.getAppointmentList();
                      }
                    },
                    onSwipeRefresh: () async {
                      appointmentsCont.page(1);
                      return await appointmentsCont.getAppointmentList(showLoader: false);
                    },
                  ).expand(),
                ],
              ),
            );
          },
        ).makeRefreshable,
      ).paddingTop(16),
    );
  }
}
