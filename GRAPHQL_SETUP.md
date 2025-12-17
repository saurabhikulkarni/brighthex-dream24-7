# GraphQL Integration with Hygraph

This project is now integrated with Hygraph GraphQL API for backend data management.

## Configuration

The Hygraph endpoint is configured in `lib/config/graphql_config.dart`:
```dart
static const String hygraphEndpoint =
    'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master';
```

## Project Structure

```
lib/
├── config/
│   └── graphql_config.dart          # GraphQL endpoint configuration
├── services/
│   ├── graphql_client.dart          # GraphQL client setup
│   ├── graphql_queries.dart         # All GraphQL queries
│   ├── product_service.dart         # Product service with methods
│   └── example_usage.dart          # Usage examples
└── models/
    └── product_model.dart           # Updated with JSON parsing
```

## Usage

### 1. Using ProductService (Recommended)

```dart
import 'package:shop/services/product_service.dart';
import 'package:shop/models/product_model.dart';

final ProductService productService = ProductService();

// Fetch all products
List<ProductModel> products = await productService.getAllProducts();

// Fetch product by ID
ProductModel? product = await productService.getProductById('product-id');

// Fetch products by category
List<ProductModel> categoryProducts = await productService.getProductsByCategory('Electronics');

// Fetch popular products
List<ProductModel> popularProducts = await productService.getPopularProducts();

// Fetch flash sale products
List<ProductModel> flashSaleProducts = await productService.getFlashSaleProducts();

// Fetch best sellers
List<ProductModel> bestSellers = await productService.getBestSellers();

// Search products
List<ProductModel> searchResults = await productService.searchProducts('laptop');
```

### 2. Using GraphQL Query Widget

```dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/models/product_model.dart';

Query(
  options: QueryOptions(
    document: gql(GraphQLQueries.getAllProducts),
    fetchPolicy: FetchPolicy.networkOnly,
  ),
  builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
    if (result.hasException) {
      return Text('Error: ${result.exception}');
    }

    if (result.isLoading) {
      return CircularProgressIndicator();
    }

    final products = result.data?['products'] as List<dynamic>?;
    return ListView.builder(
      itemCount: products?.length ?? 0,
      itemBuilder: (context, index) {
        final product = ProductModel.fromJson(
          products![index] as Map<String, dynamic>
        );
        return ListTile(
          title: Text(product.title),
          subtitle: Text(product.brandName),
        );
      },
    );
  },
)
```

## Important Notes

### Schema Requirements

The GraphQL queries in `lib/services/graphql_queries.dart` assume your Hygraph schema has the following structure:

```graphql
type Product {
  id: ID!
  title: String!
  brandName: String!
  price: Float!
  priceAfterDiscount: Float
  discountPercent: Int
  image: Asset
  description: String
  category: String
  inStock: Boolean
  isPopular: Boolean
  isFlashSale: Boolean
  isBestSeller: Boolean
  createdAt: DateTime
  updatedAt: DateTime
}
```

**You may need to adjust the queries based on your actual Hygraph schema!**

### Common Adjustments

1. **Field Names**: If your schema uses different field names (e.g., `brand` instead of `brandName`), update:
   - `lib/services/graphql_queries.dart` - Update query fields
   - `lib/models/product_model.dart` - Update `fromJson` method

2. **Image Structure**: If images are stored differently, adjust the image parsing in `ProductModel.fromJson()`:
   ```dart
   image: json['image']?['url'] as String? ?? '',
   ```

3. **Filter Fields**: If you don't have `isPopular`, `isFlashSale`, or `isBestSeller` fields, you can:
   - Remove those queries
   - Use tags or categories instead
   - Create custom filters in Hygraph

### Testing Your Schema

You can test your GraphQL queries directly in Hygraph's GraphQL Playground:
1. Go to your Hygraph project
2. Open the API Playground
3. Test the queries from `graphql_queries.dart`

## Next Steps

1. **Verify Schema**: Check your Hygraph schema matches the expected structure
2. **Update Queries**: Adjust queries in `graphql_queries.dart` to match your schema
3. **Test Integration**: Use the ProductService methods in your widgets
4. **Replace Demo Data**: Replace hardcoded product lists with GraphQL calls

## Example: Replacing Demo Data

Instead of using `demoPopularProducts`, you can now fetch from Hygraph:

```dart
// Old way
List<ProductModel> products = demoPopularProducts;

// New way
final ProductService productService = ProductService();
List<ProductModel> products = await productService.getPopularProducts();
```

## Error Handling

All ProductService methods throw exceptions on error. Always wrap calls in try-catch:

```dart
try {
  final products = await productService.getAllProducts();
  // Use products
} catch (e) {
  // Handle error
  print('Error: $e');
}
```

## Support

For Hygraph-specific questions, refer to:
- [Hygraph Documentation](https://hygraph.com/docs)
- [GraphQL Flutter Package](https://pub.dev/packages/graphql_flutter)
