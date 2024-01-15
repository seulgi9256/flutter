import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gift_shop_app/routes/app_routes.dart';
import 'package:gift_shop_app/utils/color_category.dart';
import 'package:gift_shop_app/utils/constant.dart';
import 'package:gift_shop_app/utils/constantWidget.dart';
import 'package:gift_shop_app/utils/pref_data.dart';

import 'controller/controller.dart';
import 'datafile/model_data.dart';
import 'model/language_model.dart';


class AppSplashScreen extends StatefulWidget {
  static String tag = '/';
  final String routeName;

  AppSplashScreen({this.routeName = "/"});

  @override
  _AppSplashScreenState createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? scaleController;
  Animation<double>? scaleAnimation;

  bool _a = false;
  bool _c = false;
  bool _d = false;
  bool _e = false;
  bool secondAnim = false;


  HomeMainScreenController putHomeController =
  Get.put(HomeMainScreenController());
  HomeMainScreenController homeFindScreenController =
  Get.find<HomeMainScreenController>();



  List<LanguageData> langList = Data.getLanguage();
  SelectLanguagesScreenController selectLanguagesScreenController1 =
  Get.put(SelectLanguagesScreenController());

  Color boxColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await  Future.delayed(Duration.zero);
    if(ModalRoute.of(context)!.settings.arguments!=null){
      HomeMainScreenController homeController =
      Get.find<HomeMainScreenController>();
      homeController.change(0);
      Get.toNamed(Routes.homeMainRoute);
      return;
    }


    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        boxColor = buttonColor;
        _a = true;
      });
    });
    Timer(Duration(milliseconds: 1500), () {
      setState(() {
        boxColor = regularWhite;
        _c = true;
      });
    });
    Timer(Duration(milliseconds: 1700), () {
      setState(() {
        _e = true;
      });
    });
    Timer(Duration(milliseconds: 3200), () {
      secondAnim = true;

      scaleController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
      )..forward();
      scaleAnimation = Tween<double>(begin: 0.0, end: 12).animate(scaleController!);

      setState(() {
        boxColor = regularWhite;
        _d = true;
      });
    });

    Timer(Duration(milliseconds: 2000), () async {

      if(ModalRoute.of(context)!.settings.arguments!=null){
        HomeMainScreenController homeController =
        Get.find<HomeMainScreenController>();
        homeController.change(0);
        Get.toNamed(Routes.homeMainRoute);
      }else {

        bool isSignIn =  PrefData.getIsSignIn();

        bool isIntro =  PrefData.getIsIntro();


        await  Future.delayed(Duration.zero);

        Timer(const Duration(seconds: 3), () {
          if (isIntro) {
            Get.toNamed(Routes.onBoardingRoute);
          } else {
            if (isSignIn) {
              putHomeController.changeIsLogin(false);
              Get.toNamed(Routes.loginRoute);
            } else {
              Get.toNamed(Routes.homeMainRoute);
            }
          }
        });
      }
    });


  }

  @override
  void dispose() {

    if(scaleController!=null){
      scaleController!.dispose();
    }

    super.dispose();
  }

  Widget build(BuildContext context) {
    double _h = MediaQuery.of(context).size.height;
    double _w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: regularWhite,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: _d ? 900 : 2500),
              curve: _d ? Curves.fastLinearToSlowEaseIn : Curves.elasticOut,
              height: _d
                  ? 0
                  : _a
                      ? _h / (kIsWeb ? 2.5 : 4.5)
                      : 20,
              width: 20,
            ),
            AnimatedContainer(
              duration: Duration(seconds: _c ? 2 : 0),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _d
                  ? _h
                  : _c
                      ? 200
                      : 20,
              width: _d
                  ? _w
                  : _c
                      ? 200
                      : 20,
              decoration: BoxDecoration(
                  color: !_d ?boxColor:regularWhite,
                  // shape: _d ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius: _d ? BorderRadius.only() : BorderRadius.circular(30)
              ),
              child: secondAnim
                  ? Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(color: buttonColor, shape: BoxShape.circle),
                        child: AnimatedBuilder(
                          animation: scaleAnimation!,
                          builder: (c, child) => Transform.scale(
                            scale: scaleAnimation!.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lightGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: _e ? getAssetImage(Constant.splashLogo, height: 100.h, width: 124.h) : SizedBox(),
                    ),
            ),
          ],
        ),
      ),
    );
  }



}
