// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gift_shop_app/controller/controller.dart';
import 'package:gift_shop_app/routes/app_routes.dart';
import 'package:gift_shop_app/utils/color_category.dart';
import 'package:gift_shop_app/utils/constant.dart';
import 'package:gift_shop_app/utils/constantWidget.dart';

class ForgetPasswordEmptyState extends StatefulWidget {
  const ForgetPasswordEmptyState({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordEmptyState> createState() =>
      _ForgetPasswordEmptyStateState();
}

class _ForgetPasswordEmptyStateState extends State<ForgetPasswordEmptyState> {
  ForgetPaswordEmptyStateController forgetPaswordEmptyStateController =
      Get.put(ForgetPaswordEmptyStateController());
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    return WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
              child: Form(
                key: formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(color:bgColor,child: getAppBar("",function: (){
                      Get.back();
                    })),
                    getVerSpace(40.h),
                    Center(
                        child: getCustomFont(
                            "Forgot Password", 28.sp, Color(0XFF000000), 1,
                            fontWeight: FontWeight.w700)).paddingSymmetric(horizontal: 20.h),
                    getVerSpace(30.h),
                    getTextField("Email Address",fontWeight: FontWeight.w500,fontsize: 16.sp, validator: (email) {
                      if (email!.isEmpty) {
                        return 'Enter the  email';
                      }
                      return null;
                    }).paddingSymmetric(horizontal: 20.h),
                    getVerSpace(40.h),
                    getCustomButton("Submit", () {
                      if (formkey.currentState!.validate()) {
                        Get.toNamed(Routes.resetPasswordRoute);
                      }
                    }).paddingSymmetric(horizontal: 20.h),
                  ],
                ),
              )),
        ));
  }
}
