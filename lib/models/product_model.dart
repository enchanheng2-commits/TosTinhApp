class ProductRating {
  final double rate;
  final int count;

  const ProductRating({required this.rate, required this.count});

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final ProductRating? rating;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'];

    return ProductModel(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: ratingJson is Map<String, dynamic>
          ? ProductRating.fromJson(ratingJson)
          : null,
    );
  }

  double get displayRating {
    if (rating != null) {
      return rating!.rate;
    }

    final fallback = 3.7 + ((id % 9) * 0.13);
    return fallback.clamp(3.6, 4.8);
  }

  int get reviewCount {
    if (rating != null) {
      return rating!.count;
    }

    return 84 + (id % 360);
  }
}
