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

// Men's Products Category
List<ProductModel> mensProducts = [
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

// Women's Products Category
List<ProductModel> womensProducts = [
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
];

// Jewelry Products Category (Mens & Womens)
List<ProductModel> jewelryProducts = [
  ProductModel(
    image: "https://i.imgur.com/JkM9pZx.png",
    title: "Silver Chain Necklace",
    brandName: "Jewelry Plus",
    price: 320,
  ),
  ProductModel(
    image: "https://i.imgur.com/TpR2nXx.png",
    title: "Gold Hoop Earrings",
    brandName: "Jewelry Plus",
    price: 280,
  ),
  ProductModel(
    image: "https://i.imgur.com/NnO7qQx.png",
    title: "Pearl Bracelet",
    brandName: "Luxury Wear",
    price: 380,
  ),
  ProductModel(
    image: "https://i.imgur.com/OoP8rRx.png",
    title: "Diamond Stud Earrings",
    brandName: "Fine Jewelry",
    price: 650,
  ),
  ProductModel(
    image: "https://i.imgur.com/PpQ9sSx.png",
    title: "Mens Stainless Steel Chain",
    brandName: "Bold Style",
    price: 440,
  ),
  ProductModel(
    image: "https://i.imgur.com/QqR0tTx.png",
    title: "Mens Leather Bracelet",
    brandName: "Vintage Gear",
    price: 310,
  ),
  ProductModel(
    image: "https://i.imgur.com/XxY7aaX.png",
    title: "Womens Beaded Bracelet Set",
    brandName: "Accessory Hub",
    price: 260,
  ),
];

// Handbags Products Category
List<ProductModel> handbagsProducts = [
  ProductModel(
    image: "https://i.imgur.com/HnQ7vWx.png",
    title: "Leather Crossbody Bag",
    brandName: "Bag Store",
    price: 750,
  ),
  ProductModel(
    image: "https://i.imgur.com/MmN6pPx.png",
    title: "Canvas Handbag",
    brandName: "Style Store",
    price: 520,
  ),
];

// Mobile Accessories Products Category
List<ProductModel> mobileAccessoriesProducts = [
  ProductModel(
    image: "https://i.imgur.com/WxL3pZx.png",
    title: "Mobile Phone Case",
    brandName: "Mobile Accessories",
    price: 180,
  ),
  ProductModel(
    image: "https://i.imgur.com/SsT2vVx.png",
    title: "Phone Back Cover - Black",
    brandName: "Mobile Protect",
    price: 150,
  ),
  ProductModel(
    image: "https://i.imgur.com/TtU3wWx.png",
    title: "Phone Back Cover - Blue",
    brandName: "Mobile Protect",
    price: 150,
  ),
  ProductModel(
    image: "https://i.imgur.com/UuV4xXx.png",
    title: "Mobile Charm - Heart",
    brandName: "Cute Charms",
    price: 95,
  ),
  ProductModel(
    image: "https://i.imgur.com/VvW5yYx.png",
    title: "Mobile Charm - Star",
    brandName: "Cute Charms",
    price: 95,
  ),
];

// Mens Wallet Products Category
List<ProductModel> mensWalletProducts = [
  ProductModel(
    image: "https://i.imgur.com/VsK8oYx.png",
    title: "Leather Belt",
    brandName: "Fashion Hub",
    price: 420,
  ),
  ProductModel(
    image: "https://i.imgur.com/RrS1uUx.png",
    title: "Leather Wallet",
    brandName: "Pocket Essentials",
    price: 380,
  ),
  ProductModel(
    image: "https://i.imgur.com/WwX6zZx.png",
    title: "Womens Fabric Wallet",
    brandName: "Design Studio",
    price: 290,
  ),
];

// Accessories Products Category (Legacy - kept for backward compatibility)
List<ProductModel> accessoriesProducts = [
  ProductModel(
    image: "https://i.imgur.com/JkM9pZx.png",
    title: "Silver Chain Necklace",
    brandName: "Jewelry Plus",
    price: 320,
  ),
  ProductModel(
    image: "https://i.imgur.com/HnQ7vWx.png",
    title: "Leather Crossbody Bag",
    brandName: "Bag Store",
    price: 750,
  ),
  ProductModel(
    image: "https://i.imgur.com/QwL5mKx.png",
    title: "Classic Wrist Watch",
    brandName: "Time Masters",
    price: 580,
  ),
  ProductModel(
    image: "https://i.imgur.com/TpR2nXx.png",
    title: "Gold Hoop Earrings",
    brandName: "Jewelry Plus",
    price: 280,
  ),
  ProductModel(
    image: "https://i.imgur.com/VsK8oYx.png",
    title: "Leather Belt",
    brandName: "Fashion Hub",
    price: 420,
  ),
  ProductModel(
    image: "https://i.imgur.com/WxL3pZx.png",
    title: "Mobile Phone Case",
    brandName: "Mobile Accessories",
    price: 180,
  ),
  ProductModel(
    image: "https://i.imgur.com/MmN6pPx.png",
    title: "Canvas Handbag",
    brandName: "Style Store",
    price: 520,
  ),
  ProductModel(
    image: "https://i.imgur.com/NnO7qQx.png",
    title: "Pearl Bracelet",
    brandName: "Luxury Wear",
    price: 380,
  ),
  ProductModel(
    image: "https://i.imgur.com/OoP8rRx.png",
    title: "Diamond Stud Earrings",
    brandName: "Fine Jewelry",
    price: 650,
  ),
  ProductModel(
    image: "https://i.imgur.com/PpQ9sSx.png",
    title: "Mens Stainless Steel Chain",
    brandName: "Bold Style",
    price: 440,
  ),
  ProductModel(
    image: "https://i.imgur.com/QqR0tTx.png",
    title: "Mens Leather Bracelet",
    brandName: "Vintage Gear",
    price: 310,
  ),
  ProductModel(
    image: "https://i.imgur.com/RrS1uUx.png",
    title: "Leather Wallet",
    brandName: "Pocket Essentials",
    price: 380,
  ),
  ProductModel(
    image: "https://i.imgur.com/SsT2vVx.png",
    title: "Phone Back Cover - Black",
    brandName: "Mobile Protect",
    price: 150,
  ),
  ProductModel(
    image: "https://i.imgur.com/TtU3wWx.png",
    title: "Phone Back Cover - Blue",
    brandName: "Mobile Protect",
    price: 150,
  ),
  ProductModel(
    image: "https://i.imgur.com/UuV4xXx.png",
    title: "Mobile Charm - Heart",
    brandName: "Cute Charms",
    price: 95,
  ),
  ProductModel(
    image: "https://i.imgur.com/VvW5yYx.png",
    title: "Mobile Charm - Star",
    brandName: "Cute Charms",
    price: 95,
  ),
  ProductModel(
    image: "https://i.imgur.com/WwX6zZx.png",
    title: "Womens Fabric Wallet",
    brandName: "Design Studio",
    price: 290,
  ),
  ProductModel(
    image: "https://i.imgur.com/XxY7aaX.png",
    title: "Beaded Bracelet Set",
    brandName: "Accessory Hub",
    price: 260,
  ),
];

// Chargers Products Category
List<ProductModel> chargersProducts = [
  ProductModel(
    image: "https://i.imgur.com/BbC5dEx.png",
    title: "USB-C Fast Charger",
    brandName: "Power Solutions",
    price: 450,
  ),
  ProductModel(
    image: "https://i.imgur.com/JjK3mMx.png",
    title: "Type-C Charger 65W",
    brandName: "Power Tech",
    price: 580,
  ),
];

// Wired Headphones Products Category
List<ProductModel> wiredHeadphonesProducts = [
  ProductModel(
    image: "https://i.imgur.com/DdE7gGx.png",
    title: "Wired Earbuds",
    brandName: "Audio Tech",
    price: 320,
  ),
  ProductModel(
    image: "https://i.imgur.com/GgH0jJx.png",
    title: "Wired Headphones Premium",
    brandName: "Sound Master",
    price: 520,
  ),
];

// Bluetooth Headphones Products Category
List<ProductModel> bluetoothHeadphonesProducts = [
  ProductModel(
    image: "https://i.imgur.com/AaB4cDx.png",
    title: "Wireless Bluetooth Headphones",
    brandName: "Audio Tech",
    price: 1200,
  ),
];

// USB Cables Products Category
List<ProductModel> usbCablesProducts = [
  ProductModel(
    image: "https://i.imgur.com/HhI1kKx.png",
    title: "USB Type-C Cable",
    brandName: "Cable Connect",
    price: 180,
  ),
  ProductModel(
    image: "https://i.imgur.com/LlM5oOx.png",
    title: "USB 3.0 Cable",
    brandName: "Cable Connect",
    price: 220,
  ),
];

// Speakers Products Category
List<ProductModel> speakersProducts = [
  ProductModel(
    image: "https://i.imgur.com/IiJ2lLx.png",
    title: "Portable Bluetooth Speaker",
    brandName: "Audio Plus",
    price: 890,
  ),
  ProductModel(
    image: "https://i.imgur.com/KkL4nNx.png",
    title: "Stereo Bluetooth Speaker",
    brandName: "Bass Booster",
    price: 1050,
  ),
];

// Electronics Products Category (Legacy - kept for backward compatibility)
List<ProductModel> electronicsProducts = [
  ProductModel(
    image: "https://i.imgur.com/AaB4cDx.png",
    title: "Wireless Bluetooth Headphones",
    brandName: "Audio Tech",
    price: 1200,
  ),
  ProductModel(
    image: "https://i.imgur.com/BbC5dEx.png",
    title: "USB-C Fast Charger",
    brandName: "Power Solutions",
    price: 450,
  ),
  ProductModel(
    image: "https://i.imgur.com/DdE7gGx.png",
    title: "Wired Earbuds",
    brandName: "Audio Tech",
    price: 320,
  ),
  ProductModel(
    image: "https://i.imgur.com/GgH0jJx.png",
    title: "Wired Headphones Premium",
    brandName: "Sound Master",
    price: 520,
  ),
  ProductModel(
    image: "https://i.imgur.com/HhI1kKx.png",
    title: "USB Type-C Cable",
    brandName: "Cable Connect",
    price: 180,
  ),
  ProductModel(
    image: "https://i.imgur.com/IiJ2lLx.png",
    title: "Portable Bluetooth Speaker",
    brandName: "Audio Plus",
    price: 890,
  ),
  ProductModel(
    image: "https://i.imgur.com/JjK3mMx.png",
    title: "Type-C Charger 65W",
    brandName: "Power Tech",
    price: 580,
  ),
  ProductModel(
    image: "https://i.imgur.com/KkL4nNx.png",
    title: "Stereo Bluetooth Speaker",
    brandName: "Bass Booster",
    price: 1050,
  ),
  ProductModel(
    image: "https://i.imgur.com/LlM5oOx.png",
    title: "USB 3.0 Cable",
    brandName: "Cable Connect",
    price: 220,
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
