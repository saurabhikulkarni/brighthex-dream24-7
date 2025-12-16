// For demo only
import 'package:shop/constants.dart';

/// ProductModel represents a shopping product with pricing in shopping tokens
/// All prices (price, priceAfetDiscount) are in shopping tokens, not currency
class ProductModel {
  final String image, brandName, title;
  final double price; // Price in shopping tokens
  final double? priceAfetDiscount; // Discounted price in shopping tokens

  ProductModel({
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
  });
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: productDemoImg1,
    title: "Mountain Warehouse for Women",
    brandName: "Lipsy london",
    price: 540,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
  ),
  ProductModel(
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
  ),
  ProductModel(
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650,
  ),
  ProductModel(
    image: "https://i.imgur.com/h2LqppX.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
  ),
  ProductModel(
    image: "https://i.imgur.com/XrEy2eD.png",
    title: "Premium Cotton T-Shirt",
    brandName: "Urban Style",
    price: 450,
  ),
  ProductModel(
    image: "https://i.imgur.com/6N1TzYl.png",
    title: "Casual Striped Shirt",
    brandName: "Fashion Hub",
    price: 520,
  ),
  ProductModel(
    image: "https://i.imgur.com/8XkZqwL.png",
    title: "Classic Blue Hoodie",
    brandName: "Comfort Wear",
    price: 780,
  ),
  ProductModel(
    image: "https://i.imgur.com/PqW3mJK.png",
    title: "Grey Slim Fit Shirt",
    brandName: "Modern Men",
    price: 640,
  ),
  ProductModel(
    image: "https://i.imgur.com/MnVqTHx.png",
    title: "Black Cotton Hoodie",
    brandName: "Urban Trend",
    price: 850,
  ),
  ProductModel(
    image: "https://i.imgur.com/RkLpZnV.png",
    title: "White Casual T-Shirt",
    brandName: "Basic Essentials",
    price: 380,
  ),
];
List<ProductModel> demoFlashSaleProducts = [
  ProductModel(
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    price: 650,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 1264,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
  ),
];
List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650,
  ),
  ProductModel(
    image: "https://i.imgur.com/h2LqppX.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 800,
  ),
];
List<ProductModel> kidsProducts = [
  ProductModel(
    image: "https://i.imgur.com/dbbT6PA.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 590,
  ),
  ProductModel(
    image: "https://i.imgur.com/7fSxC7k.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 650,
  ),
  ProductModel(
    image: "https://i.imgur.com/pXnYE9Q.png",
    title: "Ruffle-Sleeve Ponte-Knit Sheath ",
    brandName: "Lipsy london",
    price: 400,
  ),
  ProductModel(
    image: "https://i.imgur.com/V1MXgfa.png",
    title: "Green Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 400,
  ),
  ProductModel(
    image: "https://i.imgur.com/8gvE5Ss.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 654,
  ),
  ProductModel(
    image: "https://i.imgur.com/cBvB5YB.png",
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 250,
  ),
];
