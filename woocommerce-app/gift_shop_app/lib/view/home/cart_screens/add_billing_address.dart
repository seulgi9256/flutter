import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:gift_shop_app/utils/constantWidget.dart';

import '../../../controller/controller.dart';
import '../../../csc_picker/csc_picker.dart';
import '../../../generated/l10n.dart';
import '../../../utils/color_category.dart';
import '../../../utils/constant.dart';
import '../../../woocommerce/models/customer.dart';

class AddBillingAddress extends StatefulWidget {
  const AddBillingAddress({Key? key}) : super(key: key);

  @override
  State<AddBillingAddress> createState() => _AddBillingAddressState();
}

class _AddBillingAddressState extends State<AddBillingAddress> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  RxBool useShipping = false.obs;
  static final GlobalKey<FormState> addBillingKey = GlobalKey<FormState>();
  SelectAddressController shippingCont = Get.put(SelectAddressController());
  HomeMainScreenController homeController = Get.put(HomeMainScreenController());
  CartControllerNew cartControllerNew = Get.put(CartControllerNew());
  HomeScreenController findhomeScreenController =
      Get.find<HomeScreenController>();
  HomeScreenController putstorageController = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Constant.getSetDirection(context),
      child: SafeArea(
          child: Scaffold(
        backgroundColor: bgColor,
        body: GetBuilder<CartControllerNew>(
          init: CartControllerNew(),
          builder: (controller) => Container(
            width: double.maxFinite,
            child: Container(
              padding: EdgeInsets.only(left: 0.h, right: 0.h, bottom: 24.h),
              child: Form(
                key: addBillingKey,
                child: Column(
                  children: [
                    Container(
                        height: 73.h,
                        color: regularWhite,
                        child:
                            getAppBar(S.of(context).addAddress, function: () {
                          Get.back();
                        }, space: 114.h)),
                    getVerSpace(8.h),
                    Expanded(
                      child: Container(
                        color: regularWhite,
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.h, vertical: 20.h),
                          primary: true,
                          shrinkWrap: false,
                          children: [
                            getTextField(
                              S.of(context).name,
                              controller: firstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).pleaseEnterValidName;
                                }
                                return null;
                              },
                            ),
                            getVerSpace(16.h),
                            getTextField(
                              S.of(context).address,

                              controller: address1Controller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S
                                      .of(context)
                                      .pleaseEnterValidAddressLine1;
                                }
                                return null;
                              },
                              maxline: 5,
                            ),
                            getVerSpace(16.h),
                            getTextField(S.of(context).pinCode,
                                controller: pincodeController,
                                validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterValidPincode;
                              }
                              return null;
                            },

                                ),
                            getVerSpace(16.h),
                            GetBuilder<SelectAddressController>(
                              init: SelectAddressController(),
                              builder: (controller) => Padding(
                                padding: EdgeInsets.only(top: 15.h),
                                child: CSCPicker(
                                  showStates: true,
                                  disabledDropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.h),
                                    color: gray,
                                  ),
                                  showCities: true,
                                  flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                                  selectedItemStyle: TextStyle(
                                      color: regularBlack,
                                      fontSize: 17.sp,
                                      fontFamily: 'SF UI Text',
                                      fontWeight: FontWeight.w400,
                                      height: 1.24.h),
                                  onCountryChanged: (value) {
                                    controller.changeCountry(value);
                                  },
                                  onStateChanged: (value) {
                                    if (value != null) {
                                      controller.changeState(value);
                                    }
                                  },
                                  onCityChanged: (value) {
                                    if (value != null) {
                                      controller.changeCity(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            getVerSpace(16.h),
                            getTextField(S.of(context).phoneNumber,
                                controller: phoneController,
                                validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S
                                    .of(context)
                                    .pleaseEnterValidPhoneNumber;
                              }
                              return null;
                            },
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textInputAction: TextInputAction.done),
                            getVerSpace(15.h),
                          ],
                        ),
                      ),
                    ),
                    getCustomButton(S.of(context).add, () async {
                      if (controller.differentAddress) {
                        if (addBillingKey.currentState!.validate()) {
                          Shipping billings = Shipping(
                              firstName: firstNameController.text.toString(),
                              lastName: lastNameController.text.toString(),
                              company: "uetu5ry",
                              country: shippingCont.countryValue,
                              city: shippingCont.cityValue,
                              state: shippingCont.stateValue,
                              address1: address1Controller.text,
                              address2: address2Controller.text,
                              postcode: pincodeController.text,
                              phone: phoneController.text);
                          context.loaderOverlay.show();

                          if(homeController.checkNullOperator()){
                            return ;
                          }

                          await homeController.wooCommerce1!
                              .updateCustomerShipping(
                                  id: homeController.currentCustomer!.id!,
                                  data: billings);
                          homeController.updateCurrentCustomer();

                          context.loaderOverlay.hide();
                          findhomeScreenController.cleareShipping();
                          findhomeScreenController.clearShippingMethod();
                          putstorageController.changeShippingIndex(-1);
                          putstorageController.changeShippingTax(0.0);
                          Future.delayed(
                            Duration.zero,
                            () {
                              Get.back();
                            },
                          );
                        }
                      } else {
                        if (addBillingKey.currentState!.validate()) {
                          Billing billing = Billing(
                              firstName: firstNameController.text.toString(),
                              lastName: lastNameController.text.toString(),
                              company: "uetu5ry",
                              country: shippingCont.countryValue,
                              city: shippingCont.cityValue,
                              state: shippingCont.stateValue,
                              address1: address1Controller.text,
                              address2: address2Controller.text,
                              postcode: pincodeController.text,
                              phone: phoneController.text);
                          context.loaderOverlay.show();

                          if(homeController.checkNullOperator()){
                            return ;
                          }

                          await homeController.wooCommerce1!
                              .updateCustomerBilling(
                                  id: homeController.currentCustomer!.id!,
                                  data: billing);
                          homeController.updateCurrentCustomer();

                          context.loaderOverlay.hide();
                          findhomeScreenController.cleareShipping();
                          findhomeScreenController.clearShippingMethod();
                          putstorageController.changeShippingIndex(-1);
                          putstorageController.changeShippingTax(0.0);
                          Future.delayed(
                            Duration.zero,
                            () {
                              Get.back();
                            },
                          );
                        }
                      }
                    }).paddingOnly(left: 20.h, right: 20.h, bottom: 30.h)
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  onTapArrowleft4() {
    Get.back();
  }
}
