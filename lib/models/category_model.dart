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

/// Category banner data for home screen with shop now buttons
class CategoryBannerData {
  final String id;
  final String categoryName;
  final String subtitle;
  final String bannerImageUrl;

  CategoryBannerData({
    required this.id,
    required this.categoryName,
    required this.subtitle,
    required this.bannerImageUrl,
  });
}

final List<CategoryBannerData> demoCategoryBanners = [
  CategoryBannerData(
    id: 'mens',
    categoryName: "Men's Collection",
    subtitle: "Premium styles for men",
    bannerImageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop',
  ),
  CategoryBannerData(
    id: 'womens',
    categoryName: "Women's Collection",
    subtitle: "Elegant fashion for women",
    bannerImageUrl:
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&h=600&fit=crop',
  ),
  CategoryBannerData(
    id: 'accessories',
    categoryName: "Accessories",
    subtitle: "Complete your look",
    bannerImageUrl:
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=800&h=600&fit=crop',
  ),
  CategoryBannerData(
    id: 'electronics',
    categoryName: "Electronics & Gadgets",
    subtitle: "Latest tech gadgets",
    bannerImageUrl:
        'https://images.unsplash.com/photo-1505228395891-9a51e7e86e81?w=800&h=600&fit=crop',
  ),
];

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
