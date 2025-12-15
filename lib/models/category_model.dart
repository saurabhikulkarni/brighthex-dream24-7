class CategoryModel {
  final String title;
  final String? image, svgSrc;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.subCategories,
  });
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png"),
  CategoryModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png"),
  CategoryModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png"),
  CategoryModel(title: "Electronics", image: "https://i.imgur.com/9K3F8pL.png"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    title: "Men's",
    svgSrc: "assets/icons/Man&Woman.svg",
    subCategories: [
      CategoryModel(title: "All Clothing"),
      CategoryModel(title: "New In"),
      CategoryModel(title: "Coats & Jackets"),
      CategoryModel(title: "Shirts"),
      CategoryModel(title: "Pants"),
      CategoryModel(title: "T-Shirts"),
      CategoryModel(title: "Jeans"),
      CategoryModel(title: "Hoodies"),
    ],
  ),
  CategoryModel(
    title: "Women's",
    svgSrc: "assets/icons/Woman.svg",
    subCategories: [
      CategoryModel(title: "All Clothing"),
      CategoryModel(title: "New In"),
      CategoryModel(title: "Coats & Jackets"),
      CategoryModel(title: "Dresses"),
      CategoryModel(title: "Tops"),
      CategoryModel(title: "T-Shirts"),
      CategoryModel(title: "Jeans"),
      CategoryModel(title: "Hoodies"),
    ],
  ),
  CategoryModel(
    title: "Accessories",
    svgSrc: "assets/icons/Accessories.svg",
    subCategories: [
      CategoryModel(title: "Bags"),
      CategoryModel(title: "Jewelry"),
      CategoryModel(title: "Watches"),
      CategoryModel(title: "Belts"),
      CategoryModel(title: "Hats"),
      // iPhone Back Covers
      CategoryModel(title: "iPhone 13"),
      CategoryModel(title: "iPhone 13 Pro"),
      CategoryModel(title: "iPhone 14"),
      CategoryModel(title: "iPhone 14 Pro"),
      CategoryModel(title: "iPhone 16"),
      CategoryModel(title: "iPhone 17"),
      CategoryModel(title: "iPhone 16 Pro"),
      CategoryModel(title: "iPhone 17 Pro"),
      CategoryModel(title: "iPhone 16 Pro Max"),
      // Android Back Covers
      CategoryModel(title: "Samsung Galaxy S23"),
      CategoryModel(title: "Samsung Galaxy S24"),
      CategoryModel(title: "Google Pixel 7"),
      CategoryModel(title: "Google Pixel 8"),
      CategoryModel(title: "Google Pixel 9"),
      CategoryModel(title: "OnePlus 12"),
      CategoryModel(title: "Motorola Edge"),
      CategoryModel(title: "Xiaomi Mi 14"),
      CategoryModel(title: "Mobile Charms"),
      CategoryModel(title: "Handbags"),
      CategoryModel(title: "Men's Wallet"),
      // Women's Jewelry
      CategoryModel(title: "Earrings"),
      CategoryModel(title: "Necklace"),
      CategoryModel(title: "Bracelets"),
      CategoryModel(title: "Hair Band"),
      CategoryModel(title: "Hair Clips"),
      CategoryModel(title: "Claw Clips"),
    ],
  ),
  CategoryModel(
    title: "Electronics",
    svgSrc: "assets/icons/Electronics.svg",
    subCategories: [
      CategoryModel(title: "Phones"),
      CategoryModel(title: "Laptops"),
      CategoryModel(title: "Tablets"),
      CategoryModel(title: "Audio"),
      CategoryModel(title: "Cameras"),
      CategoryModel(title: "Wired Headphones"),
      CategoryModel(title: "Bluetooth Headphones"),
      CategoryModel(title: "USB Cords"),
      CategoryModel(title: "Type C Chargers"),
    ],
  ),
];
