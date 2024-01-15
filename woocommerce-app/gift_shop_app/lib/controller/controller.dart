import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:gift_shop_app/model/model_dummy_selected_add.dart';
import 'package:gift_shop_app/routes/app_routes.dart';
import 'package:gift_shop_app/utils/pref_data.dart';
import 'package:gift_shop_app/woocommerce/models/model_tax.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../csc_picker/csc_picker.dart';
import '../csc_picker/select_status_model.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../model/my_cart_data.dart';
import '../model/product_review.dart';
import '../utils/constant.dart';
import '../utils/storage.dart';
import '../utils/woocommerce.dart';
import '../woocommerce/models/current_currency.dart';
import '../woocommerce/models/model_order.dart';
import '../woocommerce/models/model_shipping_method.dart';
import '../woocommerce/models/order_create_model.dart';
import '../woocommerce/models/payment_gateway.dart';
import '../woocommerce/models/posts.dart';
import '../woocommerce/models/products.dart';
import '../woocommerce/models/retrieve_coupon.dart';
import '../woocommerce/models/woo_get_created_order.dart';
import '../woocommerce/woocommerce.dart';

class SelectLanguagesScreenController extends GetxController {
  // Rx<int> id = 1.obs;
  Rx<String> nameOfLan = 'English'.obs;
  bool navigation = false;

  SelectLanguagesScreenController() {
    getLanguage();
  }

  void getLanguage() async {
    lnCode.value = PrefData().getAppLanguage();
    S.load(Locale(lnCode.value));
    update();
  }

  void setLanguge(int lanId, String languageCode, String language) {
    nameOfLan.value = language;
    PrefData.setAppLanguage(languageCode);
    getLanguage();
    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void onsetLangNavigation(bool val) {
    navigation = val;
    update();
  }
}

class OnboardingScreenController extends GetxController {
  int currentPage = 0;

  onPageChange(int initialPage) {
    currentPage = initialPage;
    update();
  }
}

class LoginEmptyStateController extends GetxController {
  bool remember = false;
  var isDataLoading = false.obs;
  bool passwordPos = true;
  HomeMainScreenController storageController =
      Get.put(HomeMainScreenController());
  bool setLoginIsBuynowval = false;

  void onRememberPosition() {
    remember = !remember;
    update();
  }

  loginUser(BuildContext context, WooCommerce wooCommerce, String userName,
      String password,
      {WooCustomer? currentCustomer,
      HomeMainScreenController? controller}) async {
    isDataLoading.value = true;

    var result =
        await wooCommerce.loginCustomer(username: userName, password: password);
    if (result is WooCustomer) {
      storageController.currentCustomer = result;
      setCurrentUser(storageController.currentCustomer);
      update();
      isDataLoading.value = false;
      PrefData.setIsSignIn(false);
      isLogin = true;
      if (storageController.currentCustomer != null) {
        context.loaderOverlay.hide();
        if (storageController.isLogin) {
          List<CartOtherInfo> cartOtherInfoList = [];
          PrefData.getCartList().then((value) {
            cartOtherInfoList = value;

            Get.offNamed(Routes.cartBeforePaymentRoute,
                arguments: cartOtherInfoList);
          });
        } else {
          Get.toNamed(Routes.homeMainRoute);
        }
      }
    } else {
      context.loaderOverlay.hide();

      showCustomToast("Not matched username and password.");
      isDataLoading.value = false;
      isLogin = false;
    }
  }

  void setLoginIsBuynow(bool val) {
    setLoginIsBuynowval = val;
    update();
  }

  void onPasswordPosition() {
    passwordPos = !passwordPos;
    update();
  }
}

class ForgetPaswordEmptyStateController extends GetxController {}

class ResetPaswordEmptyStateController extends GetxController {}

class SignUpEmptyStateController extends GetxController {
  bool remember = false;
  bool passwordPos = true;
  bool isPass = true;

  void onRememberPosition() {
    remember = !remember;
    update();
  }

  void onPasswordPosition() {
    passwordPos = !passwordPos;
    update();
  }

  void onIsPassPosition() {
    isPass = !isPass;
    update();
  }
}

class VerificationScareenController extends GetxController {}

class CategoriesScreenController extends GetxController {
  bool navigationFromHome = false;

  void setNavigationIsHome(bool val) {
    navigationFromHome = val;
    update();
  }
}

class HomeMainScreenController extends GetxController
    with GetTickerProviderStateMixin {
  String webUrl = Constant.webUrl;
  String consumerKey = Constant.consumerKey;
  String consumerSecret = Constant.consumerSecret;

  RxInt position = 0.obs;

  // WooCommerce? wooCommerce;
  // WooCommerce? wooCommerce;
  WooCommerce? wooCommerce1;
  Rx<int> categoryIndex = 29.obs;
  List<WooProduct> categoryProduct = [];
  WooCustomer? currentCustomer;
  String? display;
  bool issubcatNavigate = false;
  String? mainCatName;
  WooProductCategory? currentcategory;
  WooCurrentCurrency? wooCurrentCurrency;
  bool isLogin = false;
  TabController? tabController;

  setTabController(List<Widget> widgetList) {
    tabController = TabController(
      length: widgetList.length, // Number of tabs
      vsync: this,
      initialIndex: position.value, // Initial tab index
    );

    tabController!.addListener(() {
      change(tabController!.index);
    });
  }

  // changePage(int index) {
  //   pageController.animateToPage(
  //     index,
  //     duration: Duration(milliseconds: 300),
  //     curve: Curves.ease,
  //   );
  // }

  changeIsLogin(bool value) {
    isLogin = value;
    update();
  }

  Map<String, dynamic> params = {
    "url": Constant.webUrl,
    "consumerKey": Constant.consumerKey,
    "consumerSecret": Constant.consumerSecret,
    "Accept": "application/json charset=utf-8",
    "version": 'wc/v3/'
  };

  // WooCommerceAPI? api;
  WooCommerceAPI? api1;

  RxBool isLoad = false.obs;

  RxBool isSetting = false.obs;

  changeSetting(bool value) {
    isSetting.value = value;
    update();
  }

  checkNullOperator() {
    if (wooCommerce1 == null || api1 == null) {
      return true;
    }
    return false;
  }

  getCurrency() {
    if (checkNullOperator()) {
      return;
    }

    wooCommerce1!.getCurrentCurrency().then((value) {
      wooCurrentCurrency = value;
    });
  }

  // onChange(int value) {
  //   position.value = value;
  //   update();
  // }

  updateCurrentCustomer() {
    currentCustomer = getCurrentCustomer;

    update();
  }

  @override
  void onInit() {
    super.onInit();
    setData();
  }

  setData() async {
    if (isNetwork) {
      api1 = new WooCommerceAPI(params);
      wooCommerce1 = WooCommerce(
        baseUrl: webUrl,
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        isDebug: true,
      );

      currentCustomer = getCurrentCustomer;

      getCurrency();
    }
  }

  setCategory(int value) {
    categoryIndex.value = value;

    update();
  }

  change(int index) {
    position.value = index;
    update();
  }

  void setProduct() {
    if (checkNullOperator()) {
      return;
    }
    wooCommerce1!.getProducts(category: categoryIndex.toString()).then((value) {
      categoryProduct = value;
      update();
    });
  }

  double cartTotalPriceF(List<LineItem> lineItem) {
    double cartTotalPrice = 0;
    for (var element in lineItem) {
      cartTotalPrice = cartTotalPrice + double.parse(element.subtotal!);
    }
    return cartTotalPrice;
  }

  void setCategoryDisplay(String s) {
    display = s;
    update();
  }

  void setIsnavigatesubcat(bool val) {
    issubcatNavigate = val;
    update();
  }

  void setSubcategory(WooProductCategory item) {
    currentcategory = item;
    update();
  }

  void setMainCategoryName(String? name) {
    mainCatName = name;
    update();
  }
}

class SearchScreenController extends GetxController {
  RxList<WooProduct> searchItemList = <WooProduct>[].obs;
  HomeMainScreenController storageController =
      Get.find<HomeMainScreenController>();
  RxBool listChange = false.obs;
  bool loader = false;

  TextEditingController groupFiftySixController = TextEditingController();

  List<CartOtherInfo> cartOtherInfoList = [];

  getAllCartList() {
    PrefData.getCartList().then((value) {
      cartOtherInfoList = value;
      update();
    });
  }

  loadData(String search, WooCommerce wooCommerceAPI) async {
    loader = true;
    update();
    searchItemList.value = <WooProduct>[].obs;
    final response = await wooCommerceAPI.getSearchProduct(search: search);
    searchItemList.value = response;
    loader = false;
    update();
  }

  clearData() {
    searchItemList.clear();
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }
}

class FilterController extends GetxController {
  RxString sortItem = "New Added".obs;

  WooProductVariation? variationModel;

  changeSort(String value) {
    sortItem.value = value;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class HomeScreenController extends GetxController
    with GetTickerProviderStateMixin {
  RxInt currentQuantity = 1.obs;

  int currentPage = 0;

  onPageChange(int initialPage) {
    currentPage = initialPage;
    update();
  }

  var alreadyInPurchase = false.obs;
  WooProduct? selectedProduct;
  ModelShippingMethod? selectedShippingMethod;
  WooProductVariation? variationModel;
  List<WooProductItemAttribute> attributeList = [];
  ModelDummySelectedAdd? selectedShippingAddress;
  RxBool isBillingAdd = true.obs;
  List<ModelShippingMethod> shippingMethods = [];
  RxBool success = false.obs;
  RxBool shippingMthLoaded = false.obs;
  List<WooProductVariation> listVariation = [];
  RxDouble shippingTax = 0.0.obs;
  RxInt selectShippingIndex = (-1).obs;

  bool isLastPage = false;
  int _pageNumber = 1;
  bool error = false;
  bool loading = true;
  final int _numberOfPostsPerRequest = 8;
  List<WooProduct> bestSellingList = [];
  final int nextPageTrigger = 0;

  bool popularIsLastPage = false;
  int popularPageNumber = 1;
  bool popularError = false;
  bool popularLoading = true;
  final int popularNumberOfPostsPerRequest = 8;
  List<WooProduct> popularList = [];
  final int popularNextPageTrigger = 0;

  void cleanPopularData() {
    popularPageNumber = 1;
    popularList = [];
    popularIsLastPage = false;
    popularLoading = true;
    popularError = false;
    update();
  }

  Future<void> fetchPopularData(
      HomeMainScreenController homeMainScreenController) async {
    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    try {
      final response = await homeMainScreenController.api1!
          .get("products?featured=true&page=$popularPageNumber&oer_page=8");
      List parseRes = response;
      List<WooProduct> postList =
          parseRes.map((e) => WooProduct.fromJson(e)).toList();
      popularIsLastPage = postList.length < popularNumberOfPostsPerRequest;
      popularLoading = false;
      popularPageNumber = popularPageNumber + 1;
      popularList.addAll(postList);
    } catch (e) {
      popularLoading = false;
      popularError = true;
    }
    update();
  }

  void cleanFetchData() {
    _pageNumber = 1;
    bestSellingList = [];
    isLastPage = false;
    loading = true;
    error = false;
    update();
  }

  void filterTranding(FilterController controller) {
    if (controller.sortItem.value.toLowerCase() == "new added") {
      bestSellingList.sort((a, b) {
        return a.dateCreated.compareTo(b.dateCreated);
      });
    } else if (controller.sortItem.value.toLowerCase() == "highest price") {
      bestSellingList.sort((a, b) {
        return int.parse(b.price).compareTo(int.parse(a.price));
      });
    } else if (controller.sortItem.value.toLowerCase() == "lowest price") {
      bestSellingList.sort((a, b) {
        return int.parse(a.price).compareTo(int.parse(b.price));
      });
    }
    update();
  }

  void popularFiter(FilterController controller) {
    if (controller.sortItem.value.toLowerCase() == "new added") {
      popularList.sort((a, b) {
        return a.dateCreated.compareTo(b.dateCreated);
      });
    } else if (controller.sortItem.value.toLowerCase() == "highest price") {
      popularList.sort((a, b) {
        return int.parse(b.price).compareTo(int.parse(a.price));
      });
    } else if (controller.sortItem.value.toLowerCase() == "lowest price") {
      popularList.sort((a, b) {
        return int.parse(a.price).compareTo(int.parse(b.price));
      });
    }
    update();
  }

  Future<void> fetchData(
      HomeMainScreenController homeMainScreenController) async {
    try {
      if (homeMainScreenController.checkNullOperator()) {
        return;
      }

      final response = await homeMainScreenController.api1!
          .get("products?page=$_pageNumber&per_page=8");

      List parseRes = response;
      List<WooProduct> postList =
          parseRes.map((e) => WooProduct.fromJson(e)).toList();

      isLastPage = postList.length < _numberOfPostsPerRequest;
      loading = false;
      _pageNumber = _pageNumber + 1;

      postList.forEach((element) {
        if (element.status.toString() == "Status.PUBLISH") {
          bestSellingList.add(element);
          // update();
        }
      });
      // update();
    } catch (e) {
      loading = false;
      error = true;
    }
    update();
  }

  changeShippingIndex(int value) {
    selectShippingIndex.value = value;
    update();
  }

  changeShippingTax(double value) {
    shippingTax.value = value;
    update();
  }

  addListVariation(HomeMainScreenController controller, int id) async {
    if (controller.checkNullOperator()) {
      return;
    }
    listVariation = await controller.wooCommerce1!
        .getProductVariations(controller.api1!, productId: id);
    update();
    refresh();
  }

  changeMethod(List<ModelShippingMethod> list) {
    shippingMethods = list;
    update();
  }

  clearShippingMethod() {
    shippingMethods = [];
    update();
  }

  changeShipping(ModelShippingMethod shippingMethod) {
    selectedShippingMethod = shippingMethod;
    update();
  }

  cleareShipping() {
    selectedShippingMethod = null;
    update();
  }

  setSelectedWooProduct(WooProduct product) {
    attributeList = [];
    selectedProduct = product;
    if (selectedProduct != null && selectedProduct!.attributes.isNotEmpty) {
      selectedProduct!.attributes.forEach((element) {
        if (element.variation) {
          attributeList.add(element);
        }
      });
    }
  }

  setCurrentQuantity(int quantity, {bool isRefresh = true}) {
    currentQuantity.value = quantity;
  }

  removeCurrentQuantity() {
    currentQuantity.value = currentQuantity.value - 1;
    update();
  }

  addCurrentQuantity() {
    currentQuantity.value = currentQuantity.value + 1;
    update();
  }

  setPurchaseValue(bool update1, {bool isRefresh = true}) {
    bool isSame = alreadyInPurchase.value == update1;
    alreadyInPurchase.value = update1;
    if (isRefresh) {
      update();
    } else {
      if (!isSame) {
        update();
      }
    }
  }

  clearProductVariation() {
    variationModel = null;
    update();
  }

  changeVariation(WooProductVariation listVariation) {
    variationModel = listVariation;
    update();
  }

  nullVariation() {
    variationModel = null;
    update();
  }

  statusChange(bool value) {
    success.value = value;
    update();
  }

  List<WooProduct> flashSaleList = [];
  bool isFlashLoad = false;

  List<WooProduct> trendingList = [];

  void setTrendingPlant(WooProduct data) {
    flashSaleList.add(data);
    if (flashSaleList.isEmpty) {
      isFlashLoad = true;
    } else {
      isFlashLoad = false;
    }
    update();
  }

  setAllTrendingList(List<WooProduct> list) {
    trendingList.addAll(list);
    update();
  }

  clearTrending() {
    trendingList.clear();
    update();
  }
}

class RegisterController extends GetxController {
  TextEditingController groupSixtySixController = TextEditingController();

  TextEditingController groupSixtySevenController = TextEditingController();

  TextEditingController groupSixtyEightController = TextEditingController();

  TextEditingController groupSixtyNineController = TextEditingController();

  TextEditingController groupSeventyController = TextEditingController();
  HomeMainScreenController storageController =
      Get.put(HomeMainScreenController());

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    groupSixtySixController.dispose();
    groupSixtySevenController.dispose();
    groupSixtyEightController.dispose();
    groupSixtyNineController.dispose();
    groupSeventyController.dispose();
  }

  var isDataLoading = false.obs;

  bool isLogin = false;

  LoginEmptyStateController loginController =
      Get.put(LoginEmptyStateController());
  HomeMainScreenController homeMainScreenController =
      Get.find<HomeMainScreenController>();

  registerUser(BuildContext context, WooCommerce wooCommerce,
      WooCustomer customer, String email, String password,
      {WooCustomer? currentCustomer}) async {
    isDataLoading.value = true;
    var result = await wooCommerce.createCustomer(customer);

    if (result) {
      isLogin = true;
      isDataLoading.value = false;
      isSignup = true;

      isDataLoading.value = true;

      var result =
          await wooCommerce.loginCustomer(username: email, password: password);

      if (result is WooCustomer) {
        storageController.currentCustomer = result;

        setCurrentUser(storageController.currentCustomer);
        update();
        isDataLoading.value = false;
        PrefData.setIsSignIn(false);
        isLogin = true;
        // Navigator.of(context).pop();
        if (storageController.currentCustomer != null) {
          context.loaderOverlay.hide();
          groupSixtySixController.clear();
          groupSixtySevenController.clear();
          groupSixtyEightController.clear();
          groupSixtyNineController.clear();
          groupSeventyController.clear();
          homeMainScreenController.change(0);
          homeMainScreenController.tabController!.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          );
          Get.toNamed(Routes.homeMainRoute);
        }
      } else {
        showCustomToast(S.of(context).notMatchedUsernameAndPassword);
        isDataLoading.value = false;
        isLogin = false;
        context.loaderOverlay.hide();
      }
    } else {
      isDataLoading.value = false;

      isSignup = false;
      context.loaderOverlay.hide();
    }
  }
}

class FilterSheetController extends GetxController {
  var option = 0;
  List<String> sortBy = [
    "Popular",
    "Most Recent",
    "Price High",
    "iooio",
    "utui",
    "gutu",
  ];
  List<String> selectedSortby = [];

  void onSetFiltercetegory(String selectedSortby) {}

  onChageOptionValue(int index) {
    option = index;
    update();
  }
}

class PaymentController extends GetxController {
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(BuildContext context,
      {required String amount,
      required String currency,
      required ValueChanged<bool> notify}) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency);

      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: "IN"),
          merchantDisplayName: 'Prospects',
          customerId: paymentIntentData!['customer'],
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
        ));
        displayPaymentSheet(context, notify);
      }
    } catch (e) {}
  }

  displayPaymentSheet(BuildContext context, ValueChanged<bool> notify) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      Get.snackbar('Payment', 'Payment Successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2));

      notify(true);
    } on Exception catch (e) {
      if (e is StripeException) {
        context.loaderOverlay.hide();
      } else {}
    } catch (e) {}
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${Constant.stripSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {}
  }

  calculateAmount(String amount) {
    double a = (double.parse(amount) * 100);
    int s = a.toInt();

    return s.toString();
  }
}

class PlantTypeScreenController extends GetxController
    with GetTickerProviderStateMixin {
  RxInt index = 0.obs;
  late TabController tabController;
  late PageController pController;

  void onChange(int categoryIndex) {
    index = categoryIndex.obs;
    update();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    pController = PageController();
    super.onInit();
  }
}

class PlantDetailScreenController extends GetxController {
  HomeMainScreenController homeMainScreenController =
      Get.put(HomeMainScreenController());
  int qu = 1;
  var isDataLoading = false.obs;
  bool position = true;
  int currentPage = 0;
  int cheakPosition = 0;
  bool likePosition = false;
  List<WooProductVariation> productVariation = [];
  int content = 1;
  List<WooProduct> upsellList = [];
  List<WooProduct> relatedProductList = [];

  bool isLastPage = false;
  int pageNumber = 1;
  bool error = false;
  bool loading = true;
  int numberOfPostsPerRequest = 10;
  int nextPageTrigger = 0;
  List<ModelReviewProduct> productReviewList = [];

  List<int> cartIdList = [];

  // List<int> variationIdList = [];
  //
  // getVariationIdList() async {
  //   variationIdList = await PrefData.getVariationIdList();
  //   update();
  // }
  //
  // getCartIdList() async {
  //   cartIdList = await PrefData.getCartIdList();
  //   update();
  // }

  void cleanReviewData() {
    pageNumber = 1;
    productReviewList = [];
    isLastPage = false;
    loading = true;
    error = false;
    update();
  }

  Future<void> fetchData(HomeScreenController storageController) async {
    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    try {
      final response = await homeMainScreenController.api1!
          .get("products/reviews?page=${pageNumber}");
      List parseRes = response;
      List<ModelReviewProduct> postList =
          parseRes.map((e) => ModelReviewProduct.fromJson(e)).toList();

      isLastPage = postList.length < numberOfPostsPerRequest;
      loading = false;
      pageNumber = pageNumber + 1;

      productReviewList.addAll(postList.where((element) {
        return element.productId == storageController.selectedProduct!.id;
      }).toList());
    } catch (e) {
      loading = false;
      error = true;
    }
    update();
  }

  onPageChange(int initialPage) {
    currentPage = initialPage;
    update();
  }

  void onQuntityIncrese(int quntity) {
    qu = quntity + qu;
    update();
  }

  void onQuntityDicrese(int quntity) {
    qu = quntity - 1;

    update();
  }

  onBackposition(bool pos) {
    position = pos;
    update();
  }

  onSetCheakPosition(value) {
    cheakPosition = value;
    update();
  }

  void onLikePosition() {
    likePosition = !likePosition;
    update();
  }

  void setcontent(int i) {
    content = i;
    update();
  }

  void setUpsellPlant(WooProduct result) {
    upsellList.add(result);
    update();
  }

  void setRelatedPlant(WooProduct result) {
    relatedProductList.add(result);
    update();
  }

  setLoding() {
    isDataLoading.value = true;
    update();
    Duration(seconds: 2);
    isDataLoading.value = false;
    update();
  }
}

class StorageController extends GetxController {
  WooProduct? selectedProduct;
  RxInt currentQuantity = 1.obs;
  Rx<WooProductVariation?> variationModel = (null).obs;
  Rx<WooCartItem?> wooCartItem = (null).obs;
  RxString sortItem = "NewAdded".obs;
  RxInt selectedId = 19.obs;
  RxBool success = false.obs;
  RxInt productId = 40.obs;
  RxString categoryName = "".obs;
  RxInt selectSearchCatId = 0.obs;
  int subList = 1;
  WooProductCategory? catProduct;
  ModelDummySelectedAdd? selectedShippingAddress;

  changeSearchCatId(int value) {
    selectSearchCatId.value = value;
    update();
  }

  changeCategoryName(String value) {
    categoryName.value = value;
    update();
  }

  changeProductId(int value) {
    productId.value = value;
    update();
  }

  statusChange(bool value) {
    success.value = value;
    update();
  }

  change(int value) {
    selectedId.value = value;
    update();
  }

  changeSort(String value) {
    sortItem.value = value;
    update();
  }

  List<WooProductItemAttribute> attributeList = [];
  WooPaymentGateway? selectedPaymentGateway;

  setCurrentQuantity(int quantity, {bool isRefresh = true}) {
    currentQuantity.value = quantity;
  }

  addCurrentQuantity() {
    currentQuantity.value = currentQuantity.value + 1;
    update();
  }

  removeCurrentQuantity() {
    currentQuantity.value = currentQuantity.value - 1;
    update();
  }

  clearProductVariation() {
    variationModel.value = null;
    attributeList = [];
  }

  setSelectedWooProduct(WooProduct product) {
    attributeList = [];
    selectedProduct = product;

    if (selectedProduct != null && selectedProduct!.attributes.isNotEmpty) {
      selectedProduct!.attributes.forEach((element) {
        if (element.variation) {
          attributeList.add(element);
        }
      });
    }
  }

  changeSub(int value) {
    subList = value;
    update();
  }

  void setCurrentCategoryproduct(WooProductCategory item) {
    catProduct = item;
    update();
  }
}

class SnackPlantDetailScreenController extends GetxController {}

class OutdoorsPlantScreenController extends GetxController {}

class IndoorPlantScreenController extends GetxController {
  int selectionIndex = 0;

  void onSetIndex(int index) {
    selectionIndex = index;
    update();
  }
}

class GardenScreenController extends GetxController {}

class MyCartScreenControllerAfterPayment extends GetxController {
  bool addressMode = false;

  void setAddressMode(bool val) {
    addressMode = addressMode;
    update();
  }
}

class CheckOutScreenController extends GetxController {}

class PaymentMethodScreenController extends GetxController {
  int cheakPosition = 0;
  String? select;

  void onClickPaymentRadioButton(value) {
    select = value;
    update();
  }

  onSetCheakPosition(value) {
    cheakPosition = value;
    update();
  }
}

class MyProfileController extends GetxController {
  double review = 5.0;

  void setReview(double rating) {
    review = rating;
    update();
  }
}

class MyProfileScreenController extends GetxController {}

class MyAddressScreenController extends GetxController {
  bool pos = true;

  onAddposition(bool val) {
    pos = val;
    update();
  }
}

class MyOrderScreenController extends GetxController
    with GetTickerProviderStateMixin {
  late TabController tabController;
  late PageController pController;
  bool myOrder = true;

  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    tabController = TabController(length: 2, vsync: this);
    pController = PageController();
    super.onInit();
  }

  void onMyorderBackposition(bool val) {
    myOrder = val;
    update();
  }
}

class MyCardScreenController extends GetxController {
  int? cheakPosition;

  onSetCheakPosition(value) {
    cheakPosition = value;
    update();
  }
}

class CartController extends GetxController {
  bool checkShipping = false;

  int? addressIndex;

  void changeAddress() {
    checkShipping = !checkShipping;
    update();
  }

  void addressChange(int index) {
    addressIndex = index;
    update();
  }
}

class SettingScreenController extends GetxController {}

class AddressEditController extends GetxController {}

class BlogScreenController extends GetxController {}

class BlogDetailScreenController extends GetxController {
  bool savePosition = false;

  void onChangeSavePosition() {
    savePosition = !savePosition;
    update();
  }
}

class CoupanScreenController extends GetxController {
  int? selectcoupen;

  void onSelectCoupen(int index) {
    selectcoupen = index;
    update();
  }
}

class OrederDetailScreenController extends GetxController {}

class CartControllerNew extends GetxController {
  bool differentAddress = false;
  var cartOtherInfoList = <CartOtherInfo>[];
  List<WooProduct> upsellProduct = [];
  bool cheakoutAddressNavigateofchangeShipAddress = false;
  RxBool isCouponApply = false.obs;

  RxString inputCoupon = ''.obs;
  var coupon = <CouponLines>[];

  var cartItems = <LineItems>[];
  double promoPrice = 0;
  RxBool inStock = true.obs;
  List<ShippingLines> shippingLines = <ShippingLines>[];

  TextEditingController couponCodeController = TextEditingController();

  void setDifferentAddreesPosTrue() {
    differentAddress = true;
    update();
  }

  void getCartList(List<CartOtherInfo> value) {
    cartOtherInfoList = [];
    cartOtherInfoList = value;
    update();
  }

  void changeCoupon(bool value) {
    isCouponApply.value = value;
    update();
  }

  void changeInputCoupon(String value) {
    inputCoupon.value = value;
    update();
  }

  Future<void> addItemInfo(CartOtherInfo cart) async {
    cartOtherInfoList.add(cart);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PrefData.cartStoreList);
    PrefData.setCartList(cartOtherInfoList);
    update();
  }

  Future<void> alreadyAddItem() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PrefData.cartStoreList);
    PrefData.setCartList(cartOtherInfoList);
    update();
  }

  Future<void> getCartItem() async {
    cartOtherInfoList = await PrefData.getCartList();
    update();
  }

  double updatePrice(double value) {
    promoPrice = value;
    update();
    return promoPrice;
  }

  Future<void> createLineItems() async {
    cartItems.clear();
    List<CartOtherInfo> cartOtherInfoList = await PrefData.getCartList();
    for (var element in cartOtherInfoList) {
      cartItems.add(LineItems(
        productId: element.productId,
        quantity: element.quantity,
        variationId: element.variationId,
      ));
    }
  }

  Future<void> clearCart() async {
    cartItems = [];
    shippingLines = [];
    coupon = [];
    promoPrice = 0;
    cartOtherInfoList = [];
    inStock.value = true;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PrefData.cartStoreList);
    PrefData.setCouponCode('');
    update();
  }

  Future<void> removeItemInfo(String name, int variationId) async {
    List<CartOtherInfo> cartList = await PrefData.getCartList();
    for (var element in cartList) {
      if (element.productName!.contains(name)) {}
    }

    cartOtherInfoList.removeWhere((element) =>
        element.variationId == variationId && element.productName == name);
    cartList.removeWhere((element) =>
        element.variationId == variationId && element.productName == name);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PrefData.cartStoreList);

    PrefData.setCartList(cartList);
    update();
  }

  Future<void> increaseQuantity(int index) async {
    cartOtherInfoList[index].quantity =
        cartOtherInfoList[index].quantity!.toInt() + 1;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PrefData.cartStoreList);

    PrefData.setCartList(cartOtherInfoList);
    update();
  }

  Future<void> decreaseQuantity(int index) async {
    cartOtherInfoList[index].quantity =
        cartOtherInfoList[index].quantity!.toInt() - 1;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PrefData.cartStoreList);
    PrefData.setCartList(cartOtherInfoList);
    // createLineItems();
    update();
  }

  void addCoupon(CouponLines couponLines) {
    coupon.add(couponLines);
    update();
  }

  void removeCoupon(CouponLines couponLines) {
    coupon.remove(couponLines);
    PrefData.setCouponCode('');
    update();
  }

  @override
  void onClose() {
    super.onClose();
    couponCodeController.dispose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    creatUpsellListClear();
  }

  double cartTotalPriceF(quantity, List<CartOtherInfo> cartOtherInfoList) {
    double cartTotalPrice = 0;
    for (var element in cartOtherInfoList) {
      cartTotalPrice = cartTotalPrice +
          (element.productPrice!.toDouble() * element.quantity!.toDouble());
    }
    return cartTotalPrice;
  }

  void addShippingLines(ShippingLines vals) {
    shippingLines = [];
    shippingLines.add(vals);
  }

  void clearShippingLines() {
    shippingLines = [];
  }

  void setCheckoutNavigatechangeshipAddress(bool val) {
    cheakoutAddressNavigateofchangeShipAddress = val;
    update();
  }

  void setDifferentAddreesPos() {
    differentAddress = !differentAddress;
    update();
  }

  void setUpsellData(WooProduct upsell) {
    if (upsellProduct.contains(upsell)) {
      upsellProduct.remove(upsell);
    } else {
      upsellProduct.add(upsell);
    }

    update();
  }

  creatUpsellListClear() {
    upsellProduct.clear();
  }
}

class ProductDataController extends GetxController {
  var isCategoryDataLoading = false.obs;
  var isFlashDataLoading = false.obs;
  var isNewArrivalDataLoading = false.obs;
  var isPostLoading = false.obs;
  var isCouponLoading = false.obs;

  var isPaymentMethodLoading = false.obs;
  RxInt selectedIndex = (-1).obs;
  var isMyOrderLoading = false.obs;
  var isOrderLoading = false.obs;
  List<ModelOrderNote> orderList = [];

  List<String> newCountryList = [];

  List<WooGetCreatedOrder> orderLists = [];

  List<WooProductCategory> categoryList = [];
  String categoryId = "0";
  bool isCategoryLoad = false;
  List<ModelTax> taxList = [];
  List<WooProduct> flashSaleList = [];
  List<WooProduct> newArriveProductList = [];
  bool newArriveProductLoad = false;
  bool postLoad = false;
  List<WooProduct> popularList = [];
  List<Posts> postsList = [];
  List<RetrieveCoupon?> modelCouponCode = [];
  bool isCouponLoad = false;
  List<WooPaymentGateway?> modelPaymentGateway = [];
  List<WooGetCreatedOrder?> myOrderList = [];
  RxList<String> favProductList = <String>[].obs;
  var isFavouriteLoading = false.obs;
  bool isOrderLoad = false;

  Future<void> fetchOrderData(
      HomeMainScreenController homeMainScreenController) async {
    orderLists.clear();
    update();
    isOrderLoad = true;

    if (homeMainScreenController.checkNullOperator()) {
      return;
    }
    final response =
        await homeMainScreenController.api1!.get("orders?per_page=100");
    List parseRes = response;
    List<WooGetCreatedOrder> postList =
        parseRes.map((e) => WooGetCreatedOrder.fromJson(e)).toList();
    if (!orderLists.contains(postList.where((element) =>
        element.customerId == homeMainScreenController.currentCustomer!.id))) {
      if (homeMainScreenController.currentCustomer != null) {
        orderLists.addAll(postList
            .where((element) =>
                element.customerId ==
                homeMainScreenController.currentCustomer!.id)
            .toList());
        isOrderLoad = false;
      }
    } else {
      isOrderLoad = false;
    }
    update();
  }

  Future<List<WooGetCreatedOrder>> getOrderData(
      HomeMainScreenController homeMainScreenController) async {
    orderLists.clear();

    if (homeMainScreenController.checkNullOperator()) {
      return [];
    }

    final response =
        await homeMainScreenController.api1!.get("orders?per_page=100");
    List parseRes = response;
    List<WooGetCreatedOrder> postList =
        parseRes.map((e) => WooGetCreatedOrder.fromJson(e)).toList();
    if (!orderLists.contains(postList.where((element) =>
        element.customerId == homeMainScreenController.currentCustomer!.id))) {
      orderLists.addAll(postList
          .where((element) =>
              element.customerId ==
              homeMainScreenController.currentCustomer!.id)
          .toList());
    }
    update();
    return orderLists;
  }

  addNewListData(String value) async {
    var countries = await getResponse() as List;
    countries.forEach((data) {
      var model = Country();

      if (data["code"] == value) {
        model.code = data["code"];
        model.name = data['name'];
        model.emoji = data['emoji'];
        if (!newCountryList.contains(model.emoji! + "    " + model.name!)) {
          newCountryList.add(model.emoji! + "    " + model.name!);
        }
      }
    });

    update();
  }

  addAllList() async {
    var countries = await getResponse() as List;
    countries.forEach((data) {
      var model = Country();

      model.code = data["code"];
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!newCountryList.contains(model.emoji! + "    " + model.name!)) {
        newCountryList.add(model.emoji! + "    " + model.name!);
      }
    });

    update();
  }

  getAllFavouriteList(WooCommerce wooCommerce) async {
    isFavouriteLoading.value = true;
    favProductList.value = PrefData().getFavouriteList();

    isFavouriteLoading.value = false;
  }

  getAllProductCategoryList(WooCommerceAPI wooCommerce) async {
    final response =
        await wooCommerce.get("products/categories?parent=0&per_page=100");
    List parseRes = response;
    categoryList = parseRes.map((e) => WooProductCategory.fromJson(e)).toList();
    categoryId = categoryList[0].id.toString();
    if (categoryList.isEmpty) {
      isCategoryLoad = true;
    } else {
      isCategoryLoad = false;
    }
    update();
  }

  getAllTaxList(WooCommerceAPI wooCommerce) async {
    taxList = [];
    final response = await wooCommerce.getWithout("taxes");
    List parseRes = response;
    taxList = parseRes.map((e) => ModelTax.fromJson(e)).toList();
    update();
  }

  getNewArrivalProductList(WooCommerceAPI wooCommerce) async {
    final response = await wooCommerce.get("products?featured=true");
    List parseRes = response;
    List<WooProduct> postList =
        parseRes.map((e) => WooProduct.fromJson(e)).toList();
    newArriveProductList = postList;
    if (newArriveProductList.isEmpty) {
      newArriveProductLoad = true;
    } else {
      newArriveProductLoad = false;
    }
    update();
  }

  removeList(WooProduct product) {
    favProductList.remove(product.id.toString());
    update();
  }

  getAllPaymentMethodList(WooCommerceAPI wooCommerce) async {
    modelPaymentGateway = [];
    final response = await wooCommerce.getWithout("payment_gateways");
    List parseRes = response;
    List<WooPaymentGateway> postList =
        parseRes.map((e) => WooPaymentGateway.fromJson(e)).toList();
    postList.forEach((element) {
      if (element.enabled == true) {
        modelPaymentGateway.add(element);
      }
    });
    modelPaymentGateway.add(WooPaymentGateway(
        id: "webview",
        title: "webview",
        description: "description",
        order: "",
        enabled: true,
        methodTitle: "",
        methodDescription: "",
        settings: "",
        needsSetup: false,
        postInstallScripts: [],
        settingsUrl: "",
        connectionUrl: "",
        setupHelpText: "",
        requiredSettingsKeys: [],
        links: LinksPayment(self: [], collection: [])));

    update();
  }

  getAllMyOrder(WooCommerce wooCommerce) async {
    myOrderList = [];
    isMyOrderLoading.value = true;
    var result = await wooCommerce.getMyOrder();
    myOrderList = result;
    isMyOrderLoading.value = false;
  }

  Future<String> getShippingMethodZoneId(
      WooCommerce wooCommerce, String country) async {
    String countrySet = await CSCPickerState().getCountriesCode(country) ?? "";

    String zoneId = "0";
    List<WooShippingZone> shippingZone = await wooCommerce.getShippingZones();

    if (shippingZone.isNotEmpty) {
      for (int i = 0; i < shippingZone.length; i++) {
        final response = await wooCommerce
            .getShippingZoneLocations(shippingZone[i].id.toString());

        List parseRes = response;

        List<WooShippingZoneLocation> countryList =
            parseRes.map((e) => WooShippingZoneLocation.fromJson(e)).toList();

        if (countryList.any((element) => element.code == countrySet)) {
          zoneId = shippingZone[i].id.toString();
          return zoneId;
        }
      }
    }

    return zoneId;
  }

  getFlashSaleList(WooCommerce wooCommerce) async {
    isFlashDataLoading.value = true;
    var result = await wooCommerce.getProducts();
    flashSaleList = result;
    isFlashDataLoading.value = false;
  }

  onChanegIndex(int index) {
    selectedIndex.value = index;
    update();
  }

  getPopularList() {
    popularList.addAll(newArriveProductList);
    update();
  }

  clearPopularList() {
    popularList.clear();
    update();
  }

  getAllPostsList(WooCommerceAPI wooCommerce) async {
    final response = await wooCommerce.get("posts?_embed", version: "wp/v2/");
    List parseRes = response;
    List<Posts> postList = parseRes.map((e) => Posts.fromJson(e)).toList();
    postsList = postList;
    if (postsList.isEmpty) {
      postLoad = true;
    } else {
      postLoad = false;
    }
    update();
  }

  getAllCouponList(WooCommerceAPI wooCommerce) async {
    isCouponLoading.value = true;
    final response = await wooCommerce.getWithout("coupons");
    List parseRes = response;
    modelCouponCode = parseRes.map((e) => RetrieveCoupon.fromJson(e)).toList();
    final ids = modelCouponCode.map((e) => e!.id).toSet();
    modelCouponCode.retainWhere((x) => ids.remove(x!.id));
    isCouponLoading.value = false;
    if (modelCouponCode.isEmpty) {
      isCouponLoad = true;
    } else {
      isCouponLoad = false;
    }
    update();
  }

  getAllOrderNotes(WooCommerce wooCommerce, int orderId) async {
    isOrderLoading.value = true;
    var result = await wooCommerce.getOrderNotes(orderId);
    orderList = result;
    isOrderLoading.value = false;
  }

  void clearCopunList() {
    modelCouponCode.clear();
    update();
  }
}

class SelectAddressController extends GetxController {
  RxString radioGroup = "".obs;

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";

  changeCountry(String con) {
    countryValue = con;
    update();
  }

  changeState(String con) {
    stateValue = con;
    update();
  }

  changeCity(String con) {
    cityValue = con;
    update();
  }

  changeRadio(String value) {
    radioGroup.value = value;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class ShippingAddressController extends GetxController {
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";

  changeCountry(String con) {
    countryValue = con;
    update();
  }

  changeState(String con) {
    stateValue = con;
    update();
  }

  changeCity(String con) {
    cityValue = con;
    update();
  }
}

class ImageController extends GetxController {
  File? image;
  RxString imagePath = ''.obs;
  final _picker = ImagePicker();

  getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);

      imagePath(pickedFile.path);
      update();
    } else {}
  }
}

class ZoomImageScreenController extends GetxController {
  int currentPage = 0;

  onPageChange(int initialPage) {
    currentPage = initialPage;
    update();
  }
}

class CategoriesController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class OrderConfirmScreenController extends GetxController {
  String? orderId;
  String? orderStatus;
  bool navigation = false;
  WooGetCreatedOrder? orederData;

  void setOrederDetail(id, status) {
    orderId = id;
    orderStatus = status;
    update();
  }

  void setNavigateToOrderConfirm(bool val) {
    navigation = val;
    update();
  }
}
