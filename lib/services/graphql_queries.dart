class GraphQLQueries {
  // Query to fetch all products
  static const String getAllProducts = '''
    query GetAllProducts {
      products {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Query to fetch a single product by ID
  static const String getProductById = '''
    query GetProductById(\$id: ID!) {
      product(where: {id: \$id}) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Query to fetch products by category
  static const String getProductsByCategory = '''
    query GetProductsByCategory(\$categoryName: String!) {
      products(where: {category: {categoryName: \$categoryName}}) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Query to fetch all categories
  static const String getAllCategories = '''
    query GetAllCategories {
      categories {
        id
        categoryName
        slug
      }
    }
  ''';

  // Query to fetch sizes for a product
  static const String getSizesByProduct = '''
    query GetSizesByProduct(\$productId: ID!) {
      sizes(where: {product: {id: \$productId}}) {
        id
        sizeName
        quantity
        product {
          id
        }
      }
    }
  ''';

  // Query to fetch cart items for a user
  static const String getCartByUser = '''
    query GetCartByUser(\$userId: ID!) {
      carts(where: {userDetail: {id: \$userId}}) {
        id
        quantity
        product {
          id
          productName
          slug
          description
          price
          image {
            url
          }
          category {
            id
            categoryName
          }
        }
        size {
          id
          sizeName
        }
      }
    }
  ''';

  // Query to fetch user details
  static const String getUserById = '''
    query GetUserById(\$id: ID!) {
      userDetail(where: {id: \$id}) {
        id
        firstName
        lastName
        username
      }
    }
  ''';

  // Query to fetch user by username (for login)
  static const String getUserByUsername = '''
    query GetUserByUsername(\$username: String!) {
      userDetails(where: {username: \$username}) {
        id
        firstName
        lastName
        username
        password
      }
    }
  ''';

  // Search products by name
  static const String searchProducts = '''
    query SearchProducts(\$searchTerm: String!) {
      products(where: {productName_contains: \$searchTerm}) {
        id
        productName
        slug
        description
        price
        image {
          url
        }
        category {
          id
          categoryName
          slug
        }
      }
    }
  ''';

  // Mutations

  // Create a new cart item
  static const String createCartItem = '''
    mutation CreateCartItem(\$quantity: Int!, \$userId: ID!, \$productId: ID!, \$sizeId: ID) {
      createCart(
        data: {
          quantity: \$quantity
          userDetail: {connect: {id: \$userId}}
          product: {connect: {id: \$productId}}
          size: {connect: {id: \$sizeId}}
        }
      ) {
        id
        quantity
      }
    }
  ''';

  // Update cart item quantity
  static const String updateCartItem = '''
    mutation UpdateCartItem(\$cartId: ID!, \$quantity: Int!) {
      updateCart(
        where: {id: \$cartId}
        data: {quantity: \$quantity}
      ) {
        id
        quantity
      }
    }
  ''';

  // Delete cart item
  static const String deleteCartItem = '''
    mutation DeleteCartItem(\$cartId: ID!) {
      deleteCart(where: {id: \$cartId}) {
        id
      }
    }
  ''';

  // Create new user
  static const String createUser = '''
    mutation CreateUser(\$firstName: String!, \$lastName: String!, \$username: String!, \$password: String!) {
      createUserDetail(
        data: {
          firstName: \$firstName
          lastName: \$lastName
          username: \$username
          password: \$password
        }
      ) {
        id
        firstName
        lastName
        username
      }
    }
  ''';

  // Publish user (required for Hygraph)
  static const String publishUser = '''
    mutation PublishUser(\$id: ID!) {
      publishUserDetail(where: {id: \$id}) {
        id
      }
    }
  ''';

  // Publish cart item
  static const String publishCart = '''
    mutation PublishCart(\$id: ID!) {
      publishCart(where: {id: \$id}) {
        id
      }
    }
  ''';
}
