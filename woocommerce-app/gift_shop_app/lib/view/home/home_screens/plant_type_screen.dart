// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gift_shop_app/controller/controller.dart';
import 'package:gift_shop_app/utils/constantWidget.dart';
import 'package:shimmer/shimmer.dart';

import '../../../generated/l10n.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/color_category.dart';
import '../../../woocommerce/models/product_category.dart';

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoriesScreenController categoriesScreenController =
      Get.put(CategoriesScreenController());
  HomeScreenController storageController = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return categoriesScreenController.navigationFromHome
        ? WillPopScope(
            onWillPop: () async {
              homeMainScreenController.issubcatNavigate
                  ? homeMainScreenController.setIsnavigatesubcat(false)
                  : SizedBox();
              Get.back();
              return Future.value(true);
            },
            child: Scaffold(
              backgroundColor: regularWhite,
              body: SafeArea(child: columnWidget()),
            ))
        : columnWidget();
  }

  onTapArrowleft9() {
    Get.back();
  }

  columnWidget() {
    return Container(
      color: bgColor,
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
            height: 73.h,
            width: double.infinity,
            color: regularWhite,
            child: GetBuilder<CategoriesScreenController>(
              init: CategoriesScreenController(),
              builder: (cateController) => GetBuilder<HomeMainScreenController>(
                  init: HomeMainScreenController(),
                  builder: (controller) => cateController.navigationFromHome
                      ? getAppBar(S.of(context).categories, space: 109.h,
                          function: () {
                          controller.issubcatNavigate
                              ? controller.setIsnavigatesubcat(false)
                              : SizedBox();
                          cateController.setNavigationIsHome(false);
                          Get.back();
                        }, iconpermmition: true)
                      : getAppBar(S.of(context).categories,
                          function: () {}, iconpermmition: false)),
            )),
        getVerSpace(12.h),
        Expanded(
          child: Container(
            color: regularWhite,
            width: double.infinity,
            child: GetBuilder<ProductDataController>(
              init: ProductDataController(),
              builder: (controller) => controller.categoryList.isEmpty
                  ? GridView.builder(
                      itemCount: 15,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.h, vertical: 20.h),
                      primary: true,
                      shrinkWrap: false,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20.h,
                          mainAxisExtent: 144.h,
                          crossAxisSpacing: 21.h),
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          child: Container(
                            height: 111.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 111.h,
                                  decoration: getButtonDecoration(
                                    gray,
                                    withCorners: true,
                                    corner: 22.h,
                                  ),
                                ),
                                getVerSpace(12.h),
                                Container(
                                  height: 21.h,
                                  width: double.infinity,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                        );
                      },
                    )
                  : GridView.builder(
                      itemCount: controller.categoryList.length,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.h, vertical: 20.h),
                      primary: false,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20.h,
                          mainAxisExtent: 155.h,
                          crossAxisSpacing: 21.h),
                      itemBuilder: (context, index) {
                        WooProductCategory item =
                            controller.categoryList[index];
                        return animation_function(
                          index,
                          GestureDetector(
                              onTap: () {
                                homeMainScreenController
                                    .setCategory(item.id!.toInt());
                                homeMainScreenController
                                    .setMainCategoryName(item.name);
                                homeMainScreenController
                                    .setCategoryDisplay(item.display!);

                                Get.toNamed(Routes.mainCategoryScreenRoute);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 110.h,
                                    decoration: BoxDecoration(
                                        color: lightGray,
                                        borderRadius:
                                            BorderRadius.circular(12.h)),
                                    child: item.image!.src == null
                                        ? SizedBox()
                                        : CachedNetworkImage(
                                            height: 111.h,
                                            width: double.infinity,
                                            imageUrl: "${item.image!.src}",
                                            placeholder: (context, url) =>
                                                Center(
                                                    child: Shimmer.fromColors(
                                              child: Container(
                                                width: double.infinity,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 100.h,
                                                  decoration:
                                                      getButtonDecoration(
                                                    gray,
                                                    withCorners: true,
                                                    corner: 22.h,
                                                  ),
                                                ),
                                              ),
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                            )),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                  getVerSpace(12.h),
                                  getCustomFont(item.name.toString(), 14.sp,
                                      regularBlack, 1,
                                      fontWeight: FontWeight.w600)
                                ],
                              )),
                        );
                      },
                    ),
            ),
          ),
        ),
      ]),
    );
  }
}
