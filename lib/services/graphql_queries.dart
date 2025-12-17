class GraphQLQueries {
  // Query to fetch all products
  static const String getAllProducts = '''
    query GetAllProducts {
      products {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
        createdAt
        updatedAt
      }
    }
  ''';

  // Query to fetch a single product by ID
  static const String getProductById = '''
    query GetProductById(\$id: ID!) {
      product(where: {id: \$id}) {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
        createdAt
        updatedAt
      }
    }
  ''';

  // Query to fetch products by category
  static const String getProductsByCategory = '''
    query GetProductsByCategory(\$category: String!) {
      products(where: {category: \$category}) {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
      }
    }
  ''';

  // Query to fetch popular products (you can customize this based on your schema)
  static const String getPopularProducts = '''
    query GetPopularProducts {
      products(where: {isPopular: true}) {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
      }
    }
  ''';

  // Query to fetch flash sale products
  static const String getFlashSaleProducts = '''
    query GetFlashSaleProducts {
      products(where: {isFlashSale: true}) {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
      }
    }
  ''';

  // Query to fetch best sellers
  static const String getBestSellers = '''
    query GetBestSellers {
      products(where: {isBestSeller: true}) {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
      }
    }
  ''';

  // Query to search products
  static const String searchProducts = '''
    query SearchProducts(\$searchTerm: String!) {
      products(where: {_search: \$searchTerm}) {
        id
        title
        brandName
        price
        priceAfterDiscount
        discountPercent
        image {
          url
        }
        description
        category
        inStock
      }
    }
  ''';
}
