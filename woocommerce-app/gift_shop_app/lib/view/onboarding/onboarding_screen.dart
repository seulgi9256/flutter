// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gift_shop_app/controller/controller.dart';
import 'package:gift_shop_app/datafile/model_data.dart';
import 'package:gift_shop_app/model/onboarding_slider.dart';
import 'package:gift_shop_app/utils/color_category.dart';
import 'package:gift_shop_app/utils/constant.dart';
import 'package:gift_shop_app/utils/constantWidget.dart';

import '../../generated/l10n.dart';
import '../../routes/app_routes.dart';
import '../../utils/notification_init.dart';
import '../../utils/pref_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingScreenController onboardingScreenController =
      Get.put(OnboardingScreenController());
  PageController controller = PageController();
  List<Sliders>? pages;

  Widget animationDo(
    int index,
    int delay,
    Widget child,
  ) {
    // if (index == 1) {
    //   return FadeInDown(
    //     delay: Duration(milliseconds: delay),
    //     child: child,
    //   );
    // }
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: child,
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  closeApp() {
    SystemNavigator.pop();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {}
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {});
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    if (pages == null) {
      pages = Data.getSliderPages(context);
    }

    if (!kIsWeb) {
      _isAndroidPermissionGranted();
      // _requestPermissions();
      _configureDidReceiveLocalNotificationSubject();
    }
    return Directionality(
      textDirection: Constant.getSetDirection(context),
      child: WillPopScope(
        onWillPop: () async {
          closeApp();
          return false;
        },
        child: Scaffold(
          body: SafeArea(
              child: GetBuilder(
            init: OnboardingScreenController(),
            builder: (onboardingScreenController) => Stack(
              children: [
                generatepage(),
                Padding(
                  padding: EdgeInsets.only(left: 20.h, right: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 0.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 20.h, right: 20.h, bottom: 44.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        indicator(),
                        getCustomButton(
                            onboardingScreenController.currentPage ==
                                    pages!.length - 1
                                ? S.of(context).getStarted
                                : S.of(context).next, () {
                          if (onboardingScreenController.currentPage ==
                              pages!.length - 1) {
                            PrefData.setIsIntro(false);
                            homeMainScreenController.changeIsLogin(false);
                            Get.toNamed(Routes.loginRoute);
                          } else {
                            controller.nextPage(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.bounceIn);
                          }
                        }, buttonheight: 56.h)
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    onboardingScreenController.currentPage == pages!.length - 1
                        ? SizedBox()
                        : skipButton(),
                  ],
                ),
                getVerSpace(20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget generatepage() {
    return PageView.builder(
        itemCount: pages!.length,
        scrollDirection: Axis.horizontal,
        controller: controller,
        onPageChanged: (value) {
          onboardingScreenController.onPageChange(value);
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "${Constant.assetImagePath}${pages![index].image}"),
                        fit: BoxFit.fill)),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 20.h, end: 20.h),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: animationDo(
                    index,
                    300,
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: pages![index].richTitle1st,
                        style: TextStyle(
                          color: regularBlack,
                          fontWeight: FontWeight.w700,
                          fontFamily: Constant.fontsFamily,
                          fontSize: 34.sp,
                          height: 1.5.h,
                        ),
                        children: [
                          TextSpan(
                            text: " ${pages![index].richTitle2nd} ",
                            style: TextStyle(
                                color: buttonColor,
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.5.h,
                                fontFamily: Constant.fontsFamily),
                          ),
                          TextSpan(
                            text: pages![index].richTitle3rd,
                            style: TextStyle(
                              color: regularBlack,
                              fontFamily: Constant.fontsFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 34.sp,
                              height: 1.5.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).paddingOnly(top: 559.h),
            ],
          );
        });
  }

  Widget indicator() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pages!.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 7.h,
            width: index == onboardingScreenController.currentPage ? 16.h : 7.h,
            margin: EdgeInsets.symmetric(horizontal: 5.h, vertical: 30.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.h),
                color: (index == onboardingScreenController.currentPage)
                    ? buttonColor
                    : buttonColor.withOpacity(0.3)),
          );
        }));
  }

  Widget skipButton() {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 25, end: 20),
      child: GestureDetector(
          onTap: () {
            PrefData.setIsIntro(false);
            homeMainScreenController.changeIsLogin(false);
            Get.toNamed(Routes.loginRoute);
          },
          child: getCustomFont(S.of(context).skip, 16.sp, Color(0XFF000000), 1,
              fontWeight: FontWeight.w400)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
