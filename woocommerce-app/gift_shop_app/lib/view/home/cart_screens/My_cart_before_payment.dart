import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutterwave_standard/core/flutterwave.dart';
import 'package:flutterwave_standard/models/requests/customer.dart';
import 'package:flutterwave_standard/models/requests/customizations.dart';
import 'package:flutterwave_standard/models/responses/charge_response.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:gift_shop_app/controller/controller.dart';
import 'package:gift_shop_app/model/my_cart_data.dart';
import 'package:gift_shop_app/routes/app_routes.dart';
import 'package:gift_shop_app/utils/razorpay_flutter.dart';
import 'package:gift_shop_app/view/home/cart_screens/check_out_shipping_add.dart';
import 'package:gift_shop_app/woocommerce/models/order_create_model.dart';
import 'package:gift_shop_app/woocommerce/models/products.dart';
import 'package:tuple/tuple.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../generated/l10n.dart';
import '../../../model/model_dummy_selected_add.dart';
import '../../../utils/color_category.dart';
import '../../../utils/constant.dart';
import '../../../utils/constantWidget.dart';
import '../../../utils/pref_data.dart';
import '../../../woocommerce/models/customer.dart';
import '../../../woocommerce/models/model_shipping_method.dart';
import '../../../woocommerce/models/model_tax.dart';
import '../../../woocommerce/models/payment_gateway.dart';

class MyCartScreenAfterPayment extends StatefulWidget {
  MyCartScreenAfterPayment({Key? key}) : super(key: key);

  @override
  State<MyCartScreenAfterPayment> createState() =>
      _MyCartScreenAfterPaymentState();
}

class _MyCartScreenAfterPaymentState extends State<MyCartScreenAfterPayment> {
  PaymentController paymentController = Get.put(PaymentController());
  CartControllerNew cartControllerNew = Get.put(CartControllerNew());
  HomeScreenController homeScreenController = Get.put(HomeScreenController());
  ProductDataController productDataController =
  Get.find<ProductDataController>();
  HomeMainScreenController homeController =
  Get.find<HomeMainScreenController>();
  HomeScreenController findhomeScreenController =
  Get.find<HomeScreenController>();
  CartControllerNew cartControllerNewFind = Get.find<CartControllerNew>();
  ProductDataController productController = Get.put(ProductDataController());

  Rx<ModelTax?> taxModel = (null).obs;
  List<CartOtherInfo> cartOtherInfoList = Get.arguments;
  TextEditingController couponCode = TextEditingController();

  final formkey = GlobalKey<FormState>();

  HomeMainScreenController homeMainScreenController =
  Get.put(HomeMainScreenController());
  StorageController storageController = Get.find<StorageController>();
  RxList<double> shippingLine = <double>[].obs;

  getOnlineCart() async {
    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    var result = await homeMainScreenController.wooCommerce1!.getMyCartItems();
    result.forEach((element) {
      if (element.variation!.isEmpty) {
        homeMainScreenController.wooCommerce1!
            .getProductDetail(id: element.id)
            .then((value) {
          cartControllerNew.addItemInfo(CartOtherInfo(
              variationId: 0,
              productId: element.id,
              type: "type",
              productName: element.name,
              productImage: element.images![0].src,
              productPrice: parseWcPrice(
                  (double.parse(element.prices!.regularPrice.toString()) / 100)
                      .round()
                      .toString()),
              variationList: [],
              quantity: element.quantity,
              stockStatus: value.stockStatus,
              taxClass: value.taxClass));
        });
      }
    });
    PrefData.setFirstLoad(true);
  }

  @override
  void initState() {
    // TODO: implement initState
    cartControllerNew.getCartItem();

    ModelDummySelectedAdd selectedAdd;
    if (cartControllerNew.differentAddress &&
        homeController.currentCustomer != null) {
      Shipping billing = homeController.currentCustomer!.shipping!;
      selectedAdd = ModelDummySelectedAdd(
          billing.firstName ?? "",
          billing.lastName ?? "",
          billing.company ?? "",
          billing.address1 ?? "",
          billing.address2 ?? "",
          billing.city ?? "",
          billing.state ?? "",
          billing.postcode ?? "",
          billing.country ?? "");
      homeScreenController.selectedShippingAddress = selectedAdd;
    } else if (homeController.currentCustomer != null) {
      Billing billing = homeController.currentCustomer!.billing!;

      selectedAdd = ModelDummySelectedAdd(
          billing.firstName ?? "",
          billing.lastName ?? "",
          billing.company ?? "",
          billing.address1 ?? "",
          billing.address2 ?? "",
          billing.city ?? "",
          billing.state ?? "",
          billing.postcode ?? "",
          billing.country ?? "");
      homeScreenController.selectedShippingAddress = selectedAdd;
    }

    getShippingMethods();
    getTaxRates(cartOtherInfoList, cartControllerNewFind);
    // if (homeMainScreenController.currentCustomer != null) {
    //   if (!PrefData.getFirstLoad()) {
    //     getOnlineCart();
    //   }
    // }

    Future.delayed(Duration(milliseconds: 200), () async {
      if (cartControllerNew.isCouponApply.value) {
        if (homeMainScreenController.checkNullOperator()) {
          return;
        }
        var promoPrice = await homeMainScreenController.wooCommerce1!
            .retrieveCoupon(
            cartControllerNew.inputCoupon.value, cartOtherInfoList);
        if (promoPrice > 0.0) {
          cartControllerNew.updatePrice(promoPrice);
          cartControllerNew.changeCoupon(true);
        }
      } else {
        cartControllerNew.updatePrice(0.00);
      }
    });
    cartControllerNew.createLineItems();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeScreenSize(context);
    // Shipping? wooCustomer = (homeController.currentCustomer != null)
    //     ? homeController.currentCustomer!.shipping
    //     : null;
    // Billing? shippingAddress = (homeController.currentCustomer != null)
    //     ? homeController.currentCustomer!.billing
    //     : null;

    // print("sdsdsdsd========${wooCustomer!.address1}=======${shippingAddress!.address1}");

    return Directionality(
      textDirection: Constant.getSetDirection(context),
      child: WillPopScope(
        onWillPop: () async {
          findhomeScreenController.cleareShipping();
          findhomeScreenController.clearShippingMethod();
          homeScreenController.changeShippingIndex(-1);
          homeScreenController.changeShippingTax(0.0);
          Get.back();
          return false;
        },
        child: Scaffold(
            backgroundColor: regularWhite,
            body: SafeArea(
                child: Container(
                  color: bgColor,
                  child: GetBuilder<PlantDetailScreenController>(
                    init: PlantDetailScreenController(),
                    builder: (plantDetailScreenController) => Stack(
                      children: [
                        GetBuilder<CartControllerNew>(
                          init: CartControllerNew(),
                          builder: (controller) => Column(
                            children: [
                              Container(
                                  height: 73.h,
                                  color: regularWhite,
                                  child: getAppBar(S.of(context).checkout,
                                      function: () {
                                        findhomeScreenController.cleareShipping();
                                        findhomeScreenController.clearShippingMethod();
                                        homeScreenController.changeShippingIndex(-1);
                                        homeScreenController.changeShippingTax(0.0);
                                        Get.back();
                                      })),
                              getVerSpace(12.h),
                              Expanded(
                                flex: 1,
                                child: ListView(
                                  children: [
                                    Container(
                                      color: regularWhite,
                                      width: double.infinity,
                                      child: getSvgImage(Constant.paymentIcon)
                                          .paddingOnly(top: 10.h, bottom: 14.h),
                                    ),
                                    getVerSpace(16.h),
                                    Form(
                                      key: formkey,
                                      child: Container(
                                        color: regularWhite,
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                      validator: (value) {
                                                        String? error = "";
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          error = S
                                                              .of(context)
                                                              .pleaseEnterCouponCode;
                                                        } else {
                                                          for (int i = 0;
                                                          i <
                                                              productDataController
                                                                  .modelCouponCode
                                                                  .length;
                                                          i++) {
                                                            if (!productDataController
                                                                .modelCouponCode[i]!
                                                                .code
                                                                .contains(value
                                                                .toString())) {
                                                              error = S
                                                                  .of(context)
                                                                  .pleaseEnterValidCouponCode;
                                                            } else {
                                                              error = null;
                                                              break;
                                                            }
                                                          }
                                                        }

                                                        return error;
                                                      },
                                                      cursorColor: buttonColor,
                                                      controller: couponCode,
                                                      decoration: InputDecoration(
                                                          errorStyle: TextStyle(
                                                              color: redColor,
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                              FontWeight.w400,
                                                              fontFamily: Constant
                                                                  .fontsFamily),
                                                          filled: true,
                                                          fillColor: lightGray,
                                                          contentPadding:
                                                          EdgeInsets.only(
                                                              left: 16.h),
                                                          hintText: S
                                                              .of(context)
                                                              .enterCouponCode,
                                                          hintStyle: TextStyle(
                                                            color: black40,
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                            FontWeight.w400,
                                                          ),
                                                          border:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(6.h),
                                                            borderSide: BorderSide(
                                                              color: lightGray,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          errorBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(6.h),
                                                            borderSide: BorderSide(
                                                              color: redColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          focusedErrorBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(6.h),
                                                            borderSide: BorderSide(
                                                              color: redColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(6.h),
                                                            borderSide: BorderSide(
                                                              color: lightGray,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(6.h),
                                                            borderSide: BorderSide(
                                                              color: buttonColor,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          suffixIconConstraints:
                                                          BoxConstraints(
                                                              maxHeight: 52.h,
                                                              minHeight: 52.h,
                                                              maxWidth: 75.h),
                                                          suffixIcon:
                                                          GestureDetector(
                                                              onTap: () async {
                                                                if (formkey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  if (couponCode
                                                                      .text
                                                                      .isNotEmpty) {
                                                                    cartControllerNew
                                                                        .changeInputCoupon(
                                                                        couponCode.text);
                                                                    controller
                                                                        .couponCodeController
                                                                        .text =
                                                                        couponCode
                                                                            .text
                                                                            .toString();
                                                                    context
                                                                        .loaderOverlay
                                                                        .show();
                                                                    CouponLines
                                                                    coupon =
                                                                    CouponLines(
                                                                        code:
                                                                        controller.inputCoupon.value);
                                                                    controller
                                                                        .addCoupon(
                                                                        coupon);
                                                                    if (homeMainScreenController
                                                                        .checkNullOperator()) {
                                                                      return;
                                                                    }
                                                                    var promoPrice = await homeMainScreenController.wooCommerce1!.retrieveCoupon(
                                                                        controller
                                                                            .inputCoupon
                                                                            .value,
                                                                        cartOtherInfoList);
                                                                    showCustomToast(
                                                                        "Apply ${cartControllerNew.inputCoupon} Coupon Successfully");
                                                                    if (promoPrice >
                                                                        0.0) {
                                                                      controller
                                                                          .updatePrice(
                                                                          promoPrice);
                                                                      controller
                                                                          .changeCoupon(
                                                                          true);
                                                                      context
                                                                          .loaderOverlay
                                                                          .hide();
                                                                    } else {
                                                                      context
                                                                          .loaderOverlay
                                                                          .hide();
                                                                    }
                                                                    getTaxRates(
                                                                        cartOtherInfoList,
                                                                        cartControllerNew);
                                                                  }
                                                                }
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsetsDirectional
                                                                    .only(
                                                                    top: 10
                                                                        .h,
                                                                    bottom: 10
                                                                        .h,
                                                                    end: 15
                                                                        .h),
                                                                width: 60.h,
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                    buttonColor,
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        7.h)),
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: getCustomFont(
                                                                    S
                                                                        .of(
                                                                        context)
                                                                        .apply,
                                                                    16.sp,
                                                                    regularWhite,
                                                                    1,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                              )))),
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      Get.toNamed(
                                                          Routes.couponRoute)!
                                                          .then((value) {
                                                        formkey.currentState!
                                                            .reset();
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                            new FocusNode());
                                                        getTaxRates(
                                                            cartOtherInfoList,
                                                            cartControllerNew);
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsetsDirectional
                                                          .only(
                                                          start: 22.h,
                                                          end: 10.h),
                                                      child: getCustomFont(
                                                          S.of(context).viewAll,
                                                          16.sp,
                                                          regularBlack,
                                                          1,
                                                          fontWeight:
                                                          FontWeight.w400,
                                                          txtHeight: 1.5.h,
                                                          textAlign:
                                                          TextAlign.center),
                                                    )),
                                              ],
                                            )
                                          ],
                                        ).paddingSymmetric(
                                            vertical: 16.h, horizontal: 20.h),
                                        padding: EdgeInsetsDirectional.only(
                                            bottom: 12.h),
                                      ),
                                    ),
                                    getVerSpace(16.h),
                                    Container(
                                      color: regularWhite,
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          getCustomFont(
                                              S.of(context).paymentSummary,
                                              20.sp,
                                              regularBlack,
                                              1,
                                              fontWeight: FontWeight.w700),
                                          Padding(
                                              padding: EdgeInsets.only(top: 20.h),
                                              child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    getCustomFont(
                                                        S.of(context).subTotal,
                                                        16.sp,
                                                        regularBlack,
                                                        1,
                                                        fontWeight:
                                                        FontWeight.w400),
                                                    getCustomFont(
                                                        formatStringCurrency(
                                                            total: getSubTotal(
                                                                cartOtherInfoList),
                                                            context: context),
                                                        16.sp,
                                                        regularBlack,
                                                        1,
                                                        fontWeight:
                                                        FontWeight.w400),
                                                  ])),
                                          getVerSpace(12.h),
                                          getDivider(
                                              color: black20,
                                              horPadding: 0.h,
                                              height: 0),
                                          GetBuilder<CartControllerNew>(
                                            init: CartControllerNew(),
                                            builder: (controller) => Padding(
                                                padding: EdgeInsets.only(top: 12.h),
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      getCustomFont(
                                                          S.of(context).discount,
                                                          16.sp,
                                                          regularBlack,
                                                          1,
                                                          fontWeight:
                                                          FontWeight.w400),
                                                      // getCustomFont(
                                                      //     "-${formatStringCurrency(total: cartControllerNew.promoPrice.toString(), context: context)}",
                                                      //     16.sp,
                                                      //     Color(0XFF089A16),
                                                      //     1,
                                                      //     fontWeight:
                                                      //         FontWeight.w400),
                                                      getSubTotal(cartOtherInfoList) ==
                                                          "0.0"
                                                          ? Center(
                                                          child:
                                                          CircularProgressIndicator(
                                                            color: buttonColor,
                                                          ))
                                                          : Row(
                                                        children: [
                                                          cartControllerNew
                                                              .isCouponApply
                                                              .value
                                                              ? GestureDetector(
                                                              onTap:
                                                                  () async {
                                                                context
                                                                    .loaderOverlay
                                                                    .show();
                                                                CouponLines
                                                                coupon =
                                                                CouponLines(
                                                                    code: controller.inputCoupon.value);
                                                                controller
                                                                    .removeCoupon(
                                                                    coupon);
                                                                if (homeMainScreenController
                                                                    .checkNullOperator()) {
                                                                  return;
                                                                }
                                                                var promoPrice = await homeMainScreenController.wooCommerce1!.retrieveCoupon(
                                                                    controller
                                                                        .inputCoupon
                                                                        .value,
                                                                    cartOtherInfoList);
                                                                showCustomToast(
                                                                    "Remove ${cartControllerNew.inputCoupon} Coupon Successfully");

                                                                if (promoPrice >
                                                                    0.0) {
                                                                  controller
                                                                      .updatePrice(promoPrice);
                                                                  controller
                                                                      .changeCoupon(false);
                                                                  controller
                                                                      .changeInputCoupon("");
                                                                  context
                                                                      .loaderOverlay
                                                                      .hide();
                                                                  getTaxRates(
                                                                      cartOtherInfoList,
                                                                      cartControllerNewFind);
                                                                  Future.delayed(
                                                                      Duration(milliseconds: 200),
                                                                          () async {
                                                                        if (cartControllerNew
                                                                            .isCouponApply
                                                                            .value) {
                                                                          if (homeMainScreenController.checkNullOperator()) {
                                                                            return;
                                                                          }
                                                                          var promoPrice =
                                                                          await homeMainScreenController.wooCommerce1!.retrieveCoupon(cartControllerNew.inputCoupon.value, cartOtherInfoList);
                                                                          if (promoPrice >
                                                                              0.0) {
                                                                            cartControllerNew.updatePrice(promoPrice);
                                                                            cartControllerNew.changeCoupon(true);
                                                                          }
                                                                        } else {
                                                                          cartControllerNew.updatePrice(0.00);
                                                                        }
                                                                      });
                                                                } else {
                                                                  context
                                                                      .loaderOverlay
                                                                      .hide();
                                                                }
                                                              },
                                                              child: getCustomFont(
                                                                  S
                                                                      .of(context)
                                                                      .removeCoupon,
                                                                  16.sp,
                                                                  black40,
                                                                  1))
                                                              : SizedBox(),
                                                          getHorSpace(10.h),
                                                          getCustomFont(
                                                              "-${formatStringCurrency(total: cartControllerNew.promoPrice.toString(), context: context)}",
                                                              16.sp,
                                                              Color(
                                                                  0XFF089A16),
                                                              1,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                        ],
                                                      ),
                                                    ])),
                                          ),
                                          getVerSpace(12.h),
                                          Container(
                                              decoration: BoxDecoration(),
                                              child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    GetBuilder<
                                                        HomeScreenController>(
                                                      init: HomeScreenController(),
                                                      builder: (controller) => Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          getCustomFont(
                                                              S
                                                                  .of(context)
                                                                  .shipping,
                                                              16.sp,
                                                              regularBlack,
                                                              1,
                                                              fontWeight:
                                                              FontWeight.w400),
                                                          getCustomFont(
                                                              "+${formatStringCurrency(total: (controller.selectedShippingMethod != null) ? controller.selectedShippingMethod!.settings!.cost == null ? "0" : controller.selectedShippingMethod!.settings!.cost.value : "0", context: context)}",
                                                              16.sp,
                                                              regularBlack,
                                                              1,
                                                              fontWeight:
                                                              FontWeight.w400)
                                                        ],
                                                      ),
                                                    ),
                                                    GetBuilder<
                                                        HomeScreenController>(
                                                        init:
                                                        HomeScreenController(),
                                                        builder: (controller) {
                                                          if (controller
                                                              .shippingMethods
                                                              .isNotEmpty) {
                                                            return ListView.builder(
                                                              shrinkWrap: true,
                                                              padding:
                                                              EdgeInsets.zero,
                                                              physics:
                                                              const NeverScrollableScrollPhysics(),
                                                              itemCount: controller
                                                                  .shippingMethods
                                                                  .length,
                                                              itemBuilder:
                                                                  (context, index) {
                                                                ModelShippingMethod
                                                                shippingMtd =
                                                                controller
                                                                    .shippingMethods[
                                                                index];
                                                                if (shippingMtd
                                                                    .settings!
                                                                    .cost ==
                                                                    null) {
                                                                  if (int.parse(shippingMtd
                                                                      .settings!
                                                                      .minAmount!
                                                                      .value) <=
                                                                      cartControllerNew
                                                                          .cartTotalPriceF(
                                                                          1,
                                                                          cartOtherInfoList)
                                                                          .toInt()) {
                                                                    return Padding(
                                                                      padding: EdgeInsetsDirectional
                                                                          .only(
                                                                          top: 12
                                                                              .h),
                                                                      child: Row(
                                                                        children: [
                                                                          GestureDetector(
                                                                            child: getSvgImage(controller.selectShippingIndex.value ==
                                                                                index
                                                                                ? Constant.checkBoxFillIcon
                                                                                : Constant.checkBoxIcon),
                                                                            onTap:
                                                                                () {
                                                                              controller
                                                                                  .changeShippingIndex(index);
                                                                              controller
                                                                                  .changeShipping(shippingMtd);

                                                                              controller
                                                                                  .changeShippingTax(0.0);

                                                                              cartControllerNew.addShippingLines(ShippingLines(
                                                                                  methodId: shippingMtd.methodId,
                                                                                  methodTitle: shippingMtd.methodTitle,
                                                                                  total: shippingMtd.settings.cost?.value == null ? "0" : shippingMtd.settings!.cost!.value));
                                                                            },
                                                                          ),
                                                                          Padding(
                                                                            child: Text(
                                                                                shippingMtd.title
                                                                                    .toString(),
                                                                                style: TextStyle(
                                                                                    color: regularBlack,
                                                                                    fontSize: 15.sp,
                                                                                    fontFamily: Constant.fontsFamily,
                                                                                    fontWeight: FontWeight.w400,
                                                                                    height: 1.20)),
                                                                            padding:
                                                                            EdgeInsetsDirectional.only(start: 16.h),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    return SizedBox();
                                                                  }
                                                                } else {
                                                                  return Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                        top:
                                                                        16),
                                                                    child: Row(
                                                                      children: [
                                                                        GestureDetector(
                                                                          child: getSvgImage(controller.selectShippingIndex.value ==
                                                                              index
                                                                              ? Constant
                                                                              .checkBoxFillIcon
                                                                              : Constant
                                                                              .checkBoxIcon),
                                                                          onTap:
                                                                              () {
                                                                            controller
                                                                                .changeShippingIndex(index);
                                                                            controller
                                                                                .changeShipping(shippingMtd);
                                                                            shippingLine
                                                                                .clear();
                                                                            cartOtherInfoList
                                                                                .forEach((element) {
                                                                              if (taxList
                                                                                  .isNotEmpty) {
                                                                                for (int i = 0;
                                                                                i < taxList.length;
                                                                                i++) {
                                                                                  if (element.taxClass == TaxClass.EMPTY) {
                                                                                    if (taxList[i].modelTaxClass == null) {
                                                                                      shippingLine.add(double.parse(taxList[i].rate!));
                                                                                    }
                                                                                  }
                                                                                  if (element.taxClass == taxList[i].modelTaxClass) {
                                                                                    shippingLine.add(double.parse(taxList[i].rate!));
                                                                                  }
                                                                                }
                                                                              }
                                                                            });
                                                                            shippingLine
                                                                                .sort();

                                                                            controller.changeShippingTax(int.parse(shippingMtd.settings!.cost.value) *
                                                                                shippingLine.last /
                                                                                100);

                                                                            cartControllerNew.addShippingLines(ShippingLines(
                                                                                methodId: shippingMtd
                                                                                    .methodId,
                                                                                methodTitle: shippingMtd
                                                                                    .methodTitle,
                                                                                total: shippingMtd.settings.cost?.value == null
                                                                                    ? "0"
                                                                                    : shippingMtd.settings!.cost!.value));
                                                                          },
                                                                        ),
                                                                        Padding(
                                                                          child: Text(
                                                                              shippingMtd
                                                                                  .title
                                                                                  .toString(),
                                                                              style: TextStyle(
                                                                                  color: regularBlack,
                                                                                  fontSize: 15.sp,
                                                                                  fontFamily: Constant.fontsFamily,
                                                                                  fontWeight: FontWeight.w400,
                                                                                  height: 1.20.h)),
                                                                          padding: EdgeInsetsDirectional.only(
                                                                              start:
                                                                              16.h),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            );
                                                          } else {
                                                            return Center(
                                                                child: getVerSpace(
                                                                    0.h));
                                                          }
                                                        }),
                                                  ])),
                                          Obx(
                                                () => Padding(
                                                padding: EdgeInsets.only(top: 12.h),
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      getCustomFont(
                                                          "Tax ${(taxModel.value != null) ? taxModel.value!.rate!.replaceRange(1, 6, "") : ""}%",
                                                          16.sp,
                                                          regularBlack,
                                                          1,
                                                          fontWeight:
                                                          FontWeight.w400),
                                                      getCustomFont(
                                                          "+${formatStringCurrency(total: (tax.value != 0.0) ? (tax.value + findhomeScreenController.shippingTax.value).toString() : "0", context: context)}",
                                                          16.sp,
                                                          regularBlack,
                                                          1,
                                                          fontWeight:
                                                          FontWeight.w400),
                                                    ])),
                                          ),
                                          getVerSpace(12.h),
                                          getDivider(
                                              color: black20,
                                              horPadding: 0.h,
                                              height: 0),
                                          GetBuilder<CartControllerNew>(
                                            init: CartControllerNew(),
                                            builder: (controller) => Padding(
                                                padding: EdgeInsets.only(top: 16.h),
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      getCustomFont(
                                                          S
                                                              .of(context)
                                                              .totalPaymentAmount,
                                                          16.sp,
                                                          regularBlack,
                                                          1,
                                                          fontWeight:
                                                          FontWeight.w500),
                                                      GetBuilder<
                                                          HomeScreenController>(
                                                        init:
                                                        HomeScreenController(),
                                                        builder: (homeScreen) => getCustomFont(
                                                            formatStringCurrency(
                                                                total: getTotalString(
                                                                    controller
                                                                        .isCouponApply,
                                                                    cartOtherInfoList,
                                                                    homeScreen)
                                                                    .toString(),
                                                                context: context),
                                                            16.sp,
                                                            regularBlack,
                                                            1,
                                                            fontWeight:
                                                            FontWeight.w500),
                                                      ),
                                                    ])),
                                          ),
                                        ],
                                      ).paddingSymmetric(
                                          vertical: 20.h, horizontal: 20.h),
                                    ),
                                    getVerSpace(16.h),
                                    Container(
                                      color: regularWhite,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          getVerSpace(16.h),
                                          getCustomFont(
                                              S.of(context).billingAddress,
                                              20.sp,
                                              regularBlack,
                                              1,
                                              fontWeight: FontWeight.w700)
                                              .paddingSymmetric(horizontal: 20.h),
                                          GetBuilder<HomeMainScreenController>(
                                              init: HomeMainScreenController(),
                                              builder: (homeController) {
                                                return (homeController
                                                    .currentCustomer !=
                                                    null &&
                                                    homeController
                                                        .currentCustomer!
                                                        .billing!
                                                        .city!
                                                        .isNotEmpty)
                                                    ? Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 0.h),
                                                  child:
                                                  SelectaddressItemWidget(
                                                      homeController
                                                          .currentCustomer!
                                                          .billing!,
                                                      false),
                                                )
                                                    : GetBuilder<
                                                    MyCartScreenControllerAfterPayment>(
                                                  init:
                                                  MyCartScreenControllerAfterPayment(),
                                                  builder: (controller) =>
                                                      GestureDetector(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          children: [
                                                            getSvgImage(
                                                                "add_plus.svg",
                                                                height: 24.h,
                                                                width: 24.h),
                                                            12.h.horizontalSpace,
                                                            getCustomFont(
                                                                S
                                                                    .of(context)
                                                                    .addNewAddress,
                                                                18.sp,
                                                                regularBlack,
                                                                1,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                          ],
                                                        ).marginSymmetric(
                                                            vertical: 32.h),
                                                        onTap: () {
                                                          controller
                                                              .setAddressMode(
                                                              true);
                                                          cartControllerNew
                                                              .setDifferentAddreesPos();
                                                          Get.toNamed(Routes
                                                              .addBillingAddressRoute)!
                                                              .then(
                                                                  (value) =>
                                                                  setState(
                                                                          () {
                                                                        ModelDummySelectedAdd
                                                                        selectedAdd;
                                                                        if (cartControllerNew
                                                                            .differentAddress &&
                                                                            homeMainScreenController.currentCustomer !=
                                                                                null) {
                                                                          Billing
                                                                          billing =
                                                                          homeController.currentCustomer!.billing!;
                                                                          selectedAdd = ModelDummySelectedAdd(
                                                                              billing.firstName ??
                                                                                  "",
                                                                              billing.lastName ??
                                                                                  "",
                                                                              billing.company ??
                                                                                  "",
                                                                              billing.address1 ??
                                                                                  "",
                                                                              billing.address2 ??
                                                                                  "",
                                                                              billing.city ??
                                                                                  "",
                                                                              billing.state ??
                                                                                  "",
                                                                              billing.postcode ??
                                                                                  "",
                                                                              billing.country ??
                                                                                  "");
                                                                          homeScreenController.selectedShippingAddress =
                                                                              selectedAdd;
                                                                        } else if (homeMainScreenController
                                                                            .currentCustomer !=
                                                                            null) {
                                                                          Shipping
                                                                          billing =
                                                                          homeController.currentCustomer!.shipping!;
                                                                          selectedAdd = ModelDummySelectedAdd(
                                                                              billing.firstName ??
                                                                                  "",
                                                                              billing.lastName ??
                                                                                  "",
                                                                              billing.company ??
                                                                                  "",
                                                                              billing.address1 ??
                                                                                  "",
                                                                              billing.address2 ??
                                                                                  "",
                                                                              billing.city ??
                                                                                  "",
                                                                              billing.state ??
                                                                                  "",
                                                                              billing.postcode ??
                                                                                  "",
                                                                              billing.country ??
                                                                                  "");
                                                                          homeScreenController.selectedShippingAddress =
                                                                              selectedAdd;
                                                                        }

                                                                        getShippingMethods();
                                                                      }));
                                                        },
                                                      ),
                                                );
                                              })
                                        ],
                                      ).paddingSymmetric(
                                          horizontal: 0.h, vertical: 0.h),
                                    ),
                                    getVerSpace(16.h),
                                    GetBuilder<HomeMainScreenController>(
                                      init: HomeMainScreenController(),
                                      builder: (homeController) => GestureDetector(
                                        onTap: () {
                                          cartControllerNew
                                              .setCheckoutNavigatechangeshipAddress(
                                              true);
                                          cartControllerNew
                                              .setDifferentAddreesPosTrue();
                                          (homeController.currentCustomer != null &&
                                              homeController.currentCustomer!
                                                  .shipping!.city!.isNotEmpty)
                                              ? () {
                                            showCustomToast(S
                                                .of(context)
                                                .youHaveAlreadyAddedTheAddressPleaseSelectCheakbox);
                                          }
                                              : Get.toNamed(Routes
                                              .addBillingAddressRoute)!
                                              .then((value) => setState(() {
                                            // cartControllerNew
                                            //     .setDifferentAddreesPos();
                                            ModelDummySelectedAdd
                                            selectedAdd;
                                            if (cartControllerNew
                                                .differentAddress) {
                                              Billing billing =
                                              homeController
                                                  .currentCustomer!
                                                  .billing!;
                                              selectedAdd =
                                                  ModelDummySelectedAdd(
                                                      billing.firstName ??
                                                          "",
                                                      billing.lastName ??
                                                          "",
                                                      billing.company ??
                                                          "",
                                                      billing.address1 ??
                                                          "",
                                                      billing.address2 ??
                                                          "",
                                                      billing.city ??
                                                          "",
                                                      billing.state ??
                                                          "",
                                                      billing.postcode ??
                                                          "",
                                                      billing.country ??
                                                          "");
                                            } else {
                                              Shipping billing =
                                              homeController
                                                  .currentCustomer!
                                                  .shipping!;
                                              selectedAdd =
                                                  ModelDummySelectedAdd(
                                                      billing.firstName ??
                                                          "",
                                                      billing.lastName ??
                                                          "",
                                                      billing.company ??
                                                          "",
                                                      billing.address1 ??
                                                          "",
                                                      billing.address2 ??
                                                          "",
                                                      billing.city ??
                                                          "",
                                                      billing.state ??
                                                          "",
                                                      billing.postcode ??
                                                          "",
                                                      billing.country ??
                                                          "");
                                            }

                                            homeScreenController
                                                .selectedShippingAddress =
                                                selectedAdd;
                                            getShippingMethods();
                                            homeScreenController
                                                .changeShippingIndex(
                                                -1);
                                          }));
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          color: regularWhite,
                                          child: GetBuilder<CartControllerNew>(
                                            init: CartControllerNew(),
                                            builder: (controller) => Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                getVerSpace(20.h),
                                                getCustomFont(
                                                    S
                                                        .of(context)
                                                        .shippingAddress,
                                                    20.sp,
                                                    regularBlack,
                                                    1,
                                                    fontWeight: FontWeight.w700)
                                                    .paddingSymmetric(
                                                    horizontal: 20.h),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            findhomeScreenController
                                                                .cleareShipping();
                                                            findhomeScreenController
                                                                .clearShippingMethod();
                                                            controller
                                                                .setDifferentAddreesPos();
                                                            ModelDummySelectedAdd
                                                            selectedAdd;
                                                            if (controller
                                                                .differentAddress) {
                                                              Shipping billing =
                                                              homeController
                                                                  .currentCustomer!
                                                                  .shipping!;
                                                              selectedAdd = ModelDummySelectedAdd(
                                                                  billing.firstName ??
                                                                      "",
                                                                  billing.lastName ??
                                                                      "",
                                                                  billing.company ??
                                                                      "",
                                                                  billing.address1 ??
                                                                      "",
                                                                  billing.address2 ??
                                                                      "",
                                                                  billing.city ??
                                                                      "",
                                                                  billing.state ??
                                                                      "",
                                                                  billing.postcode ??
                                                                      "",
                                                                  billing.country ??
                                                                      "");
                                                            } else {
                                                              Billing billing =
                                                              homeController
                                                                  .currentCustomer!
                                                                  .billing!;
                                                              selectedAdd = ModelDummySelectedAdd(
                                                                  billing.firstName ??
                                                                      "",
                                                                  billing.lastName ??
                                                                      "",
                                                                  billing.company ??
                                                                      "",
                                                                  billing.address1 ??
                                                                      "",
                                                                  billing.address2 ??
                                                                      "",
                                                                  billing.city ??
                                                                      "",
                                                                  billing.state ??
                                                                      "",
                                                                  billing.postcode ??
                                                                      "",
                                                                  billing.country ??
                                                                      "");
                                                            }

                                                            homeScreenController
                                                                .selectedShippingAddress =
                                                                selectedAdd;
                                                            getShippingMethods();

                                                            homeScreenController
                                                                .changeShippingIndex(
                                                                -1);
                                                            homeScreenController
                                                                .changeShippingTax(
                                                                0.0);
                                                          },
                                                          child: getSvgImage(
                                                              controller
                                                                  .differentAddress
                                                                  ? Constant
                                                                  .checkBoxFillIcon
                                                                  : Constant
                                                                  .checkBoxIcon,
                                                              height: 20.h,
                                                              width: 20.h),
                                                        ),
                                                        getHorSpace(8.h),
                                                        getCustomFont(
                                                            S
                                                                .of(context)
                                                                .shipToADifferentAddress,
                                                            16.sp,
                                                            regularBlack,
                                                            1,
                                                            fontWeight:
                                                            FontWeight.w400)
                                                      ],
                                                    ),
                                                    getSvgImage("arrow_right.svg")
                                                  ],
                                                ).paddingOnly(
                                                    top: 10.h,
                                                    left: 20.h,
                                                    right: 20.h),
                                                GetBuilder<
                                                    HomeMainScreenController>(
                                                    init:
                                                    HomeMainScreenController(),
                                                    builder: (homeController) {
                                                      return (homeController
                                                          .currentCustomer !=
                                                          null &&
                                                          homeController
                                                              .currentCustomer!
                                                              .shipping!
                                                              .city!
                                                              .isNotEmpty &&
                                                          controller
                                                              .differentAddress)
                                                          ? Padding(
                                                        padding:
                                                        EdgeInsets.only(
                                                            top: 0.h),
                                                        child: SelectDifferentaddressItemWidget(
                                                            homeController
                                                                .currentCustomer!
                                                                .shipping!,
                                                            false),
                                                      )
                                                          : getVerSpace(20.h);
                                                    })
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    getVerSpace(16.h),
                                    Container(
                                      width: double.infinity,
                                      color: regularWhite,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          getCustomFont(
                                              S.of(context).chooseYourPaymentMode,
                                              20.sp,
                                              regularBlack,
                                              1,
                                              fontWeight: FontWeight.w700),
                                          getVerSpace(20.h),
                                          GetBuilder<ProductDataController>(
                                            init: ProductDataController(),
                                            builder: (controller) {
                                              if (controller
                                                  .modelPaymentGateway.isEmpty) {
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    color: buttonColor,
                                                  ),
                                                );
                                              } else {
                                                return ListView.separated(
                                                    physics:
                                                    NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return SizedBox(height: 26.h);
                                                    },
                                                    itemCount: productDataController
                                                        .modelPaymentGateway.length,
                                                    itemBuilder: (context, index) {
                                                      WooPaymentGateway wooGateway =
                                                      productDataController
                                                          .modelPaymentGateway[
                                                      index]!;
                                                      return CheckoutoneItemWidget(
                                                          wooGateway, index);
                                                    });
                                              }
                                            },
                                          ),
                                        ],
                                      ).paddingSymmetric(
                                          vertical: 20.h, horizontal: 20.h),
                                    ),
                                    getVerSpace(110.h),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GetBuilder<HomeScreenController>(
                          init: HomeScreenController(),
                          builder: (homeScreenController) =>
                              GetBuilder<CartControllerNew>(
                                init: CartControllerNew(),
                                builder: (controller) => Align(
                                    alignment: Alignment.bottomCenter,
                                    child: GetBuilder<HomeMainScreenController>(
                                        init: HomeMainScreenController(),
                                        builder: (homeController) {
                                          return GetBuilder<ProductDataController>(
                                            init: ProductDataController(),
                                            builder: (productController) => (homeController
                                                .currentCustomer !=
                                                null &&
                                                homeController.currentCustomer!
                                                    .billing!.city!.isNotEmpty)
                                                ? homeScreenController
                                                .shippingMethods.isEmpty
                                                ? getDisableButton(
                                                S.of(context).confirmPayment,
                                                    () {
                                                  showCustomToast(S
                                                      .of(context)
                                                      .thereAreNoShippingOptionsAvailablePleaseEnsureThatYour);
                                                })
                                                : productController.selectedIndex.value ==
                                                -1
                                                ? getDisableButton(
                                                S
                                                    .of(context)
                                                    .confirmPayment,
                                                    () {})
                                                : homeScreenController
                                                .selectedShippingMethod !=
                                                null
                                                ? getCustomButton(
                                                S.of(context).confirmPayment,
                                                    () async {
                                                  if (!EasyLoading
                                                      .isShow) {
                                                    storageController
                                                        .selectedPaymentGateway =
                                                    productDataController
                                                        .modelPaymentGateway[
                                                    productDataController
                                                        .selectedIndex
                                                        .value];
                                                    homeMainScreenController
                                                        .getCurrency();
                                                    homeScreenController
                                                        .statusChange(
                                                        false);
                                                    String currency =
                                                    homeMainScreenController
                                                        .wooCurrentCurrency!
                                                        .code!;
                                                    List<ModelItems>
                                                    list = [];
                                                    String listCountry =
                                                    await getCountriesISO(
                                                        homeScreenController
                                                            .selectedShippingAddress!
                                                            .country);
                                                    cartControllerNew
                                                        .cartOtherInfoList
                                                        .forEach(
                                                            (element) {
                                                          list.add(ModelItems(
                                                              name: element
                                                                  .productName,
                                                              price: element
                                                                  .productPrice
                                                                  .toString(),
                                                              currency:
                                                              currency,
                                                              quantity: element
                                                                  .quantity,
                                                              tax: (tax.value !=
                                                                  0.0)
                                                                  ? (tax.value +
                                                                  findhomeScreenController.shippingTax.value)
                                                                  .toString()
                                                                  : "0"));
                                                        });
                                                    switch (storageController
                                                        .selectedPaymentGateway!
                                                        .id) {
                                                      case "bacs":
                                                        break;
                                                      case "cod" ||
                                                      "Cash on delivery":
                                                        cashOnDeliveryPayment();
                                                        break;
                                                      case "razorpay":
                                                        setRazorPay(
                                                            currency)
                                                            .then(
                                                                (value) {
                                                              context
                                                                  .loaderOverlay
                                                                  .hide();
                                                            });
                                                        break;

                                                      case "stripe":
                                                        stripePayment(
                                                            currency);
                                                        break;
                                                      case "ppec_paypal":
                                                      case "ppcp-gateway":
                                                        paypalPayment(
                                                            currency,
                                                            list,
                                                            homeController
                                                                .currentCustomer!
                                                                .shipping,
                                                            listCountry);
                                                        break;
                                                      case "sslcommerz":
                                                        sslCommerzPayment();
                                                        break;
                                                      case "tbz_rave":
                                                        flutterWave();
                                                        break;
                                                      case "webview":
                                                        webviewPayment();
                                                        break;
                                                      case "ppcp-credit-card-gateway":
                                                        break;
                                                    }
                                                  }
                                                })
                                                : getDisableButton(
                                                S.of(context).confirmPayment, () {})
                                                : getDisableButton(S.of(context).confirmPayment, () {}),
                                          );
                                        })),
                              ),
                        ).paddingOnly(left: 20.h, right: 20.h, bottom: 30.h),
                      ],
                    ),
                  ),
                ))),
      ),
    );
  }

  Widget buildProgressWidget(BuildContext context) {
    return Row(
      children: [
        getSvgImage("location_fill.svg", height: 24.h, width: 24.h),
        Expanded(
          child: FDottedLine(
            color: buttonColor,
            height: 1.h,
            strokeWidth: 1.h,
            width: double.infinity,
            space: 4.h,
            dottedLength: 4.h,
            child: Container(),
            corner: FDottedLineCorner.all(5.h),
          ).paddingSymmetric(horizontal: 6.h),
        ),
        getSvgImage("card_fill.svg", height: 24.h, width: 24.h),
        Expanded(
          child: FDottedLine(
            color: buttonColor,
            height: 1.h,
            strokeWidth: 1.h,
            width: double.infinity,
            space: 4.h,
            dottedLength: 4.h,
            child: Container(),
            corner: FDottedLineCorner.all(5.h),
          ).paddingSymmetric(horizontal: 6.h),
        ),
        getSvgImage("check_circle.svg", height: 24.h, width: 24.h),
      ],
    ).paddingSymmetric(horizontal: 30.h);
  }

  Widget orderItem() {
    return GetBuilder<CartControllerNew>(
        init: CartControllerNew(),
        builder: (controller) {
          if (controller.cartOtherInfoList.isEmpty) {
            return SizedBox();
          } else {
            return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 10.h),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return getVerSpace(10.h);
                },
                itemCount: cartOtherInfoList.length,
                itemBuilder: (context, index) {
                  CartOtherInfo cartInfo = cartOtherInfoList[index];
                  return getCartDetailFormateNewOfCheakoutScreen(
                      cartInfo.productImage!,
                      cartInfo.productName!,
                      cartInfo.productPrice!.toString(),
                      cartInfo.quantity!, () async {
                    if (cartInfo.quantity! > 1) {
                      controller.decreaseQuantity(index);
                    }

                    Future.delayed(Duration(milliseconds: 200), () async {
                      if (controller.isCouponApply.value) {
                        if (homeMainScreenController.checkNullOperator()) {
                          return;
                        }
                        var promoPrice = await homeMainScreenController
                            .wooCommerce1!
                            .retrieveCoupon(controller.inputCoupon.value,
                            cartOtherInfoList);
                        if (promoPrice > 0.0) {
                          controller.updatePrice(promoPrice);
                          controller.changeCoupon(true);
                        }
                      }
                    });
                  }, () {
                    controller.increaseQuantity(index);

                    Future.delayed(Duration(milliseconds: 200), () async {
                      if (controller.isCouponApply.value) {
                        if (homeMainScreenController.checkNullOperator()) {
                          return;
                        }
                        var promoPrice = await homeMainScreenController
                            .wooCommerce1!
                            .retrieveCoupon(controller.inputCoupon.value,
                            cartOtherInfoList);
                        if (promoPrice > 0.0) {
                          controller.updatePrice(promoPrice);
                          controller.changeCoupon(true);
                        }
                      }
                    });
                  }, () {
                    cartControllerNew.removeItemInfo(
                        cartOtherInfoList[index].productName.toString(),
                        cartOtherInfoList[index].variationId!);

                    Future.delayed(Duration(milliseconds: 200), () async {
                      if (controller.isCouponApply.value) {
                        if (homeMainScreenController.checkNullOperator()) {
                          return;
                        }
                        var promoPrice = await homeMainScreenController
                            .wooCommerce1!
                            .retrieveCoupon(controller.inputCoupon.value,
                            cartOtherInfoList);
                        if (promoPrice > 0.0) {
                          controller.updatePrice(promoPrice);
                          controller.changeCoupon(true);
                        }
                      }
                    });
                    controller.coupon.clear();
                    Get.back();
                  }, cartInfo.quantity,
                      widget: cartInfo.variationList != null &&
                          cartInfo.variationList!.isNotEmpty
                          ? Container(
                        height: 20.h,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: cartInfo.variationList!.length,
                          itemBuilder: (context, index) {
                            return getCustomFont(
                                "${cartInfo.variationList![index]!.name!} : ${cartInfo.variationList![index]!.option!}",
                                14.sp,
                                Color(0XFF808080),
                                1,
                                txtHeight: 1.5.h,
                                fontWeight: FontWeight.w500);
                          },
                        ),
                      )
                          : SizedBox());
                });
          }
        });
  }

  Future<void> cashOnDeliveryPayment() async {
    context.loaderOverlay.show();

    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    bool isCreated = await homeMainScreenController.wooCommerce1!.createOrder(
      homeMainScreenController.currentCustomer!,
      cartControllerNew.cartItems,
      storageController.selectedPaymentGateway!.methodTitle,
      false,
      homeScreenController.selectedShippingAddress!,
      cartControllerNew.coupon,
      cartControllerNew.shippingLines,
    );
    if (isCreated) {
      context.loaderOverlay.hide();
      cartControllerNew.clearCart();
      storageController.currentQuantity.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(Routes.orderConfirmRoute, arguments: [
          S.of(context).yourOrderHasBeenReceived,
          S.of(context).thankYouForShoppingWithUs
        ]);
      });
    } else {
      context.loaderOverlay.hide();
    }
  }

  void stripePayment(String currency) {
    context.loaderOverlay.show();

    paymentController.makePayment(
      context,
      amount: getTotalString(cartControllerNew.isCouponApply, cartOtherInfoList,
          homeScreenController)
          .toString(),
      currency: currency,
      notify: (value) async {
        if (homeMainScreenController.checkNullOperator()) {
          return;
        }
        bool isCreated =
        await homeMainScreenController.wooCommerce1!.createOrder(
          homeMainScreenController.currentCustomer!,
          cartControllerNew.cartItems,
          storageController.selectedPaymentGateway!.methodTitle,
          value,
          homeScreenController.selectedShippingAddress!,
          cartControllerNew.coupon,
          cartControllerNew.shippingLines,
        );

        if (isCreated) {
          context.loaderOverlay.hide();
          cartControllerNew.clearCart();
          storageController.currentQuantity.value = 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed(Routes.orderConfirmRoute, arguments: [
              S.of(context).yourOrderHasBeenReceived,
              S.of(context).thankYouForShoppingWithUs
            ]);
          });
        } else {
          context.loaderOverlay.hide();
        }
      },
    );
  }

  void paypalPayment(String currency, List<ModelItems> list,
      Shipping? shippingAddress, String listCountry) {
    Future.delayed(
      Duration.zero,
          () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => UsePaypal(
                sandboxMode: Constant.sandbox,
                clientId: Constant.paypalClientId,
                secretKey: Constant.paypalClientSecret,
                returnURL: "https://samplesite.com/return",
                cancelURL: "https://samplesite.com/cancel",
                transactions: [
                  {
                    "amount": {
                      "total": getTotalString(cartControllerNew.isCouponApply,
                          cartOtherInfoList, homeScreenController),
                      "currency": currency,
                      "details": {
                        "subtotal": getSubTotal(cartOtherInfoList),
                        "tax": ((tax.value != 0.0)
                            ? (tax.value +
                            findhomeScreenController.shippingTax.value)
                            .toString()
                            : "0"),
                        "shipping":
                        (findhomeScreenController.selectedShippingMethod !=
                            null)
                            ? findhomeScreenController
                            .selectedShippingMethod!
                            .settings!
                            .cost!
                            .value
                            .toString()
                            : "0",
                      }
                    },
                    "description": "The WooWach Payment",
                    "item_list": {
                      "items": list,
                      "shipping_address": {
                        "recipient_name":
                        "${shippingAddress!.firstName} ${shippingAddress.lastName}",
                        "line1": shippingAddress.address1,
                        "line2": shippingAddress.address2,
                        "city": shippingAddress.city,
                        // "country": selectedAdd.country,
                        "country_code": listCountry,
                        "postal_code": shippingAddress.postcode,
                        "phone": homeMainScreenController
                            .currentCustomer!.billing!.phone ??
                            "",
                        "state": shippingAddress.state
                      },
                    }
                  }
                ],
                note: "Contact us for any questions on your order.",
                onSuccess: (Map params) async {
                  context.loaderOverlay.hide();
                  if (homeMainScreenController.checkNullOperator()) {
                    return;
                  }
                  bool isCreated =
                  await homeMainScreenController.wooCommerce1!.createOrder(
                    homeMainScreenController.currentCustomer!,
                    cartControllerNew.cartItems,
                    storageController.selectedPaymentGateway!.methodTitle,
                    true,
                    storageController.selectedShippingAddress!,
                    cartControllerNew.coupon,
                    cartControllerNew.shippingLines,
                  );
                  if (isCreated) {
                    context.loaderOverlay.hide();
                    cartControllerNew.clearCart();
                    storageController.currentQuantity.value = 1;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Get.toNamed(Routes.orderConfirmRoute, arguments: [
                        S.of(context).yourOrderHasBeenReceived,
                        S.of(context).thankYouForShoppingWithUs
                      ]);
                    });
                  }
                },
                onError: (error) {},
                onCancel: (params) {}),
          ),
        );
      },
    );
  }

  Future<void> flutterWave() async {
    final Customer customer = Customer(
        name:
        "${homeController.currentCustomer!.firstName} ${homeController.currentCustomer!.lastName}",
        phoneNumber: homeController.currentCustomer!.billing!.phone ?? "",
        email: homeController.currentCustomer!.billing!.email ?? "");
    final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: Constant.flutterwavePublicKey,
        currency: Constant.flutterwaveCurrency,
        redirectUrl: 'https://facebook.com',
        txRef: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: getTotalString(cartControllerNew.isCouponApply,
            cartOtherInfoList, homeScreenController),
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(title: "Test Payment"),
        isTestMode: Constant.sandbox);
    final ChargeResponse response = await flutterwave.charge();
    context.loaderOverlay.show();
    if (response.success == true) {
      if (homeMainScreenController.checkNullOperator()) {
        return;
      }
      bool isCreated = await homeMainScreenController.wooCommerce1!.createOrder(
        homeMainScreenController.currentCustomer!,
        cartControllerNew.cartItems,
        storageController.selectedPaymentGateway!.methodTitle,
        false,
        homeScreenController.selectedShippingAddress!,
        cartControllerNew.coupon,
        cartControllerNew.shippingLines,
      );
      if (isCreated) {
        context.loaderOverlay.hide();
        cartControllerNew.clearCart();
        storageController.currentQuantity.value = 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(Routes.orderConfirmRoute, arguments: [
            S.of(context).yourOrderHasBeenReceived,
            S.of(context).thankYouForShoppingWithUs
          ]);
        });
      } else {
        context.loaderOverlay.hide();
      }
    } else {
      context.loaderOverlay.hide();
    }
  }

  Future<void> sslCommerzPayment() async {
    context.loaderOverlay.show();
    Sslcommerz sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        ipn_url: "www.ipnurl.com",
        currency: SSLCurrencyType.BDT,
        product_category: "Food",
        sdkType: Constant.sslSandbox ? SSLCSdkType.TESTBOX : SSLCSdkType.LIVE,
        store_id: Constant.storeId,
        store_passwd: Constant.storePassword,
        total_amount: double.parse(getTotalString(
            cartControllerNew.isCouponApply,
            cartOtherInfoList,
            homeScreenController)),
        tran_id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );
    try {
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      if (result.status!.toLowerCase() == "failed") {
        context.loaderOverlay.hide();
      } else if (result.status!.toLowerCase() == "closed") {
        context.loaderOverlay.hide();
      } else {
        if (homeMainScreenController.checkNullOperator()) {
          return;
        }
        bool isCreated =
        await homeMainScreenController.wooCommerce1!.createOrder(
          homeMainScreenController.currentCustomer!,
          cartControllerNew.cartItems,
          storageController.selectedPaymentGateway!.methodTitle,
          false,
          homeScreenController.selectedShippingAddress!,
          cartControllerNew.coupon,
          cartControllerNew.shippingLines,
        );
        if (isCreated) {
          context.loaderOverlay.hide();
          cartControllerNew.clearCart();
          storageController.currentQuantity.value = 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.toNamed(Routes.orderConfirmRoute, arguments: [
              S.of(context).yourOrderHasBeenReceived,
              S.of(context).thankYouForShoppingWithUs
            ]);
          });
        } else {
          context.loaderOverlay.hide();
        }
      }
    } catch (e) {}
  }

  void webviewPayment() {
    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    context.loaderOverlay.show();
    homeMainScreenController.wooCommerce1!
        .createOrder(
      homeMainScreenController.currentCustomer!,
      cartControllerNew.cartItems,
      "Cash on delivery",
      false,
      homeScreenController.selectedShippingAddress!,
      cartControllerNew.coupon,
      cartControllerNew.shippingLines,
    )
        .then((value) {
      if (value) {
        productController.getOrderData(homeMainScreenController).then((value) {
          if (value.isNotEmpty) {
            Get.toNamed(Routes.myWebViewRoute,
                arguments:
                Tuple2(value[0].paymentUrl!, value[0].id.toString()));

            // Get.to(
            //     MyWebView(
            //       url: value[0]
            //           .paymentUrl!,
            //       id: value[0]
            //           .id
            //           .toString(),
            //     ));
          }
        });
        context.loaderOverlay.hide();
        cartControllerNew.clearCart();

        storageController.currentQuantity.value = 1;
      }
    });
  }

  Widget paymentMethod(WooPaymentGateway modelPaymentGateway) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getCustomFont(
                "${modelPaymentGateway.methodTitle}", 14, regularBlack, 1,
                fontWeight: FontWeight.w400),
          ],
        ),
      ],
    );
  }

  String getSubTotal(List<CartOtherInfo> cartOtherInfoList) {
    return cartControllerNew.cartTotalPriceF(1, cartOtherInfoList).toString();
  }

  RxDouble tax = 0.0.obs;

  List<ModelTax> taxList = [];

  String getTotalString(RxBool isCouponApply,
      List<CartOtherInfo> cartOtherInfoList, HomeScreenController homeScreen) {
    double totalVals = (isCouponApply.value)
        ? (cartControllerNew.cartTotalPriceF(1, cartOtherInfoList) -
        cartControllerNew.promoPrice +
        ((tax.value != 0.0)
            ? (tax.value + homeScreen.shippingTax.value)
            : 0.0))
        : cartControllerNew.cartTotalPriceF(1, cartOtherInfoList) +
        ((tax.value != 0.0)
            ? (tax.value + homeScreen.shippingTax.value)
            : 0.0);

    if (homeScreen.selectedShippingMethod != null) {
      totalVals = totalVals +
          double.parse(homeScreen.selectedShippingMethod!.settings!.cost == null
              ? "0"
              : homeScreen.selectedShippingMethod!.settings!.cost!.value);
    }
    return totalVals.toString();
  }

  getShippingMethods() async {
    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    String zoneId = await productDataController.getShippingMethodZoneId(
        homeMainScreenController.wooCommerce1!,
        homeScreenController.selectedShippingAddress!.country);

    homeScreenController.changeMethod(
        await homeMainScreenController.wooCommerce1!.getAllShippingMethods(
            zoneId,
            homeMainScreenController.wooCommerce1!,
            homeScreenController.selectedShippingAddress!.postcode));

    findhomeScreenController.shippingMthLoaded.value = true;
  }

  getTaxRates(List<CartOtherInfo> cartOtherInfoList,
      CartControllerNew cartControllerNew) {
    tax.value = 0.0;
    cartOtherInfoList.forEach((element) async {
      taxList = productDataController.taxList;
      if (taxList.isNotEmpty) {
        for (int i = 0; i < taxList.length; i++) {
          if (element.taxClass == TaxClass.EMPTY) {
            if (taxList[i].modelTaxClass == null) {
              tax.value = tax.value +
                  (element.productPrice! *
                      double.parse(taxList[i].rate.toString()) /
                      100) *
                      element.quantity!;
              if (cartControllerNew.isCouponApply.value) {
                tax.value = tax.value -
                    (cartControllerNew.promoPrice *
                        double.parse(taxList[i].rate.toString()) /
                        100) *
                        element.quantity!;
              }
            }
          }
          if (element.taxClass == taxList[i].modelTaxClass) {
            tax.value = tax.value +
                (element.productPrice! *
                    double.parse(taxList[i].rate.toString()) /
                    100) *
                    element.quantity!;
            if (cartControllerNew.isCouponApply.value) {
              tax.value = tax.value -
                  (cartControllerNew.promoPrice *
                      double.parse(taxList[i].rate.toString()) /
                      100) *
                      element.quantity!;
            }
          }
        }
      }
    });
  }

  Widget CheckoutoneItemWidget(WooPaymentGateway wooGateway, int index) {
    return GetBuilder<ProductDataController>(
      init: ProductDataController(),
      builder: (controller) => GestureDetector(
          onTap: () {
            productDataController.onChanegIndex(index);
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      getAssetImage(Constant.getPaymentImage(wooGateway.id),
                          width: 28.h, height: 28.h),
                      getHorSpace(16.h),
                      Expanded(
                        child: Text(Constant.getPaymentString(wooGateway.id),
                            style: TextStyle(
                                color: regularBlack,
                                fontSize: 16.sp,
                                fontFamily: Constant.fontsFamily,
                                fontWeight: FontWeight.w700,
                                height: 1.5.h)),
                      ),
                    ],
                  ),
                ),
                getSvgImage(
                  (controller.selectedIndex.value == index)
                      ? Constant.radioFillIcon
                      : Constant.radioButtonIcon,
                ),
              ],
            ),
          )),
    );
  }

  Future<void> setRazorPay(String currency) async {
    final Razorpay razorpay = Razorpay();
    context.loaderOverlay.show();
    var options = {
      'key': Constant.razorpayid,
      'amount': double.parse(getTotalString(cartControllerNew.isCouponApply,
          cartOtherInfoList, homeScreenController)
          .toString()) *
          100,
      "currency": currency,
      'name':
      "${homeController.currentCustomer!.firstName} ${homeController.currentCustomer!.lastName}",
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': homeController.currentCustomer!.billing!.phone ?? "",
        'email': homeController.currentCustomer!.billing!.email ?? ""
      }
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, () {
      context.loaderOverlay.hide();
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
            (PaymentSuccessResponse response) async {
          if (homeMainScreenController.checkNullOperator()) {
            return;
          }
          bool isCreated = await homeMainScreenController.wooCommerce1!.createOrder(
            homeMainScreenController.currentCustomer!,
            cartControllerNew.cartItems,
            storageController.selectedPaymentGateway!.methodTitle,
            false,
            homeScreenController.selectedShippingAddress!,
            cartControllerNew.coupon,
            cartControllerNew.shippingLines,
          );
          if (isCreated) {
            context.loaderOverlay.hide();
            cartControllerNew.clearCart();

            storageController.currentQuantity.value = 1;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.toNamed(Routes.orderConfirmRoute, arguments: [
                S.of(context).yourOrderHasBeenReceived,
                S.of(context).thankYouForShoppingWithUs
              ]);
            });
          } else {
            context.loaderOverlay.hide();
          }
        });
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, () {
      context.loaderOverlay.hide();
    });
    razorpay.open(options);
  }
}

class MyWebView extends StatefulWidget {
  //
  // const MyWebView({Key? key, required this.url, required this.id})
  //     : super(key: key);
  // final String url;
  // final String id;

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  bool isPaf = false;

  @override
  Widget build(BuildContext context) {
    Tuple2 tuple2 = ModalRoute.of(context)!.settings.arguments as Tuple2;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: bgColor,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 73.h,
                  width: double.infinity,
                  color: regularWhite,
                  child: GetBuilder<CategoriesScreenController>(
                      init: CategoriesScreenController(),
                      builder: (cateController) =>
                          GetBuilder<HomeMainScreenController>(
                              init: HomeMainScreenController(),
                              builder: (controller) => getAppBar(
                                  S.of(context).checkout,
                                  space: 109.h, function: () {
                                controller.issubcatNavigate
                                    ? controller.setIsnavigatesubcat(false)
                                    : SizedBox();
                                cateController.setNavigationIsHome(false);
                                Get.back();
                              }, iconpermmition: true))),
                ),
                getVerSpace(12.h),
                Expanded(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(const Color(0x00000000))
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onProgress: (int progress) {
                            // Update loading bar.
                          },
                          onPageStarted: (String url) {},
                          onPageFinished: (url) {
                            int position = url.indexOf('?') - 1;

                            if (url.substring(0, position) ==
                                (Constant.orderConfirmUrl + tuple2.item2)) {
                              Get.toNamed(Routes.orderConfirmRoute, arguments: [
                                S.of(context).yourOrderHasBeenReceived,
                                S.of(context).thankYouForShoppingWithUs
                              ]);
                            }
                          },
                          onWebResourceError: (WebResourceError error) {},
                          onNavigationRequest: (NavigationRequest request) {
                            return NavigationDecision.navigate;
                          },
                        ),
                      )
                      ..loadRequest(Uri.parse(tuple2.item1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
