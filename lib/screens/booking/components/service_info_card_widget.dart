import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/price_widget.dart';
import '../../service/model/service_list_model.dart';
import '../model/appointments_res_model.dart';

class ServiceInfoCardWidget extends StatelessWidget {
  final AppointmentData appointmentDet;

  const ServiceInfoCardWidget({super.key, required this.appointmentDet});

  @override
  Widget build(BuildContext context) {
    return appointmentDet.billingItems.isEmpty
        ? Container(
            decoration: boxDecorationDefault(color: context.cardColor),
            child: Column(
              children: [
                16.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: boxDecorationDefault(),
                      child: CachedImageWidget(
                        url: appointmentDet.serviceImage,
                        fit: BoxFit.cover,
                        radius: 6,
                      ),
                    ),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: boxDecorationDefault(
                            color: isDarkMode.value ? Colors.grey.withValues(alpha: 0.1) : lightSecondaryColor,
                            borderRadius: radius(8),
                          ),
                          child: Text(
                            appointmentDet.categoryName,
                            style: boldTextStyle(size: 10, fontFamily: fontFamilyWeight700, color: appColorSecondary),
                          ),
                        ).visible(appointmentDet.categoryName.isNotEmpty),
                        8.height,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(appointmentDet.serviceName, overflow: TextOverflow.ellipsis, maxLines: 2, style: boldTextStyle(size: 16)).expand(),
                              ],
                            ),
                            8.height,
                            Row(
                              spacing: 6,
                              children: [
                                if (!appointmentDet.isInclusiveTaxesAvailable && appointmentDet.discountValue > 0 && appointmentDet.discountAmount > 0)
                                  PriceWidget(
                                    price: appointmentDet.servicePrice,
                                    color: dividerColor,
                                    isLineThroughEnabled: appointmentDet.discountValue > 0 && appointmentDet.discountAmount > 0 ? true : false,
                                    size: 12,
                                    isBoldText: true,
                                  ),
                                PriceWidget(
                                  price: appointmentDet.serviceAmount,
                                  color: dividerColor,
                                  size: 12,
                                  isBoldText: true,
                                ),
                                if (appointmentDet.isInclusiveTaxesAvailable)
                                  Text(
                                    ' ${locale.value.includesInclusiveTax}',
                                    style: secondaryTextStyle(
                                      color: appColorSecondary,
                                      size: 10,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ),
                16.height,
              ],
            ).paddingSymmetric(horizontal: 16),
          )
        : AnimatedListView(
            shrinkWrap: true,
            itemCount: appointmentDet.billingItems.length,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.None,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: index == appointmentDet.billingItems.length - 1 ? 0 : 16),
                decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: boxDecorationDefault(),
                      child: CachedImageWidget(
                        url: appointmentDet.billingItems[index].serviceDetail != null ? appointmentDet.billingItems[index].serviceDetail!.serviceImage : "",
                        fit: BoxFit.cover,
                        radius: 6,
                      ),
                    ).paddingRight(16).visible(appointmentDet.billingItems[index].serviceDetail != null),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appointmentDet.billingItems[index].itemName, maxLines: 2, overflow: TextOverflow.ellipsis, style: boldTextStyle(size: 14)).expand(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              locale.value.total,
                              overflow: TextOverflow.ellipsis,
                              style: primaryTextStyle(size: 12, color: dividerColor),
                            ),
                            16.width,
                            Flexible(
                              child: Marquee(
                                child: Row(
                                  children: [
                                    if (!appointmentDet.billingItems[index].isIncludesInclusiveTaxAvailable) ...[
                                      PriceWidget(
                                        price: appointmentDet.billingItems[index].serviceAmount,
                                        color: dividerColor,
                                        isLineThroughEnabled: appointmentDet.billingItems[index].serviceDetail != null && appointmentDet.billingItems[index].serviceDetail!.isDiscount ? true : false,
                                        size: 12,
                                        isBoldText: true,
                                      ).paddingRight(6),
                                      if (appointmentDet.billingItems[index].serviceDetail != null && appointmentDet.billingItems[index].serviceDetail!.isDiscount)
                                        PriceWidget(
                                          price: appointmentDet.billingItems[index].serviceDetail!.assignDoctor
                                              .firstWhere(
                                                (e) => e.doctorId == appointmentDet.doctorId,
                                                orElse: () => AssignDoctor(
                                                  priceDetail: PriceDetail(
                                                    serviceAmount: appointmentDet.billingItems[index].serviceAmount,
                                                  ),
                                                ),
                                              )
                                              .priceDetail
                                              .serviceAmount,
                                          color: dividerColor,
                                          size: 12,
                                          isBoldText: true,
                                        ),
                                      Text(" x ${appointmentDet.billingItems[index].quantity} = ", style: primaryTextStyle(size: 12, color: dividerColor)),
                                    ],
                                    PriceWidget(
                                      price: appointmentDet.billingItems[index].totalAmount,
                                      color: appColorPrimary,
                                      size: 14,
                                      isBoldText: true,
                                    ),
                                    if (appointmentDet.billingItems[index].isIncludesInclusiveTaxAvailable)
                                      Text(
                                        ' ${locale.value.includesInclusiveTax}',
                                        style: secondaryTextStyle(
                                          color: appColorSecondary,
                                          size: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).flexible(),
                  ],
                ),
              );
            },
          );
  }

  bool isAppointmentService(index) => appointmentDet.billingItems[index].serviceDetail != null && appointmentDet.billingItems[index].serviceDetail!.id == appointmentDet.serviceId;
}