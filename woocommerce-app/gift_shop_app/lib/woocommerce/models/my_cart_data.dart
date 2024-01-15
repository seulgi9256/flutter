import 'package:gift_shop_app/woocommerce/models/products.dart';

class CartOtherInfo {
  int? variationId;
  List<dynamic>? variationList; // Assuming variationList stores dynamic data
  int? productId;
  int? quantity;
  String? stockStatus;
  String? type;
  String? productName;
  String? productImage;
  double? productPrice;
  TaxClass? taxClass;

  // Constructor with named parameters matching the object creation syntax
  CartOtherInfo({
    this.variationId,
    this.variationList,
    this.productId,
    this.quantity,
    this.stockStatus,
    this.type,
    this.productName,
    this.productImage,
    this.productPrice,
    this.taxClass,
  });

  

}
