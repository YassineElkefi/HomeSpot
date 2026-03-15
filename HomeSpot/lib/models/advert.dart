class Advert {
  final int id;
  final String description;
  final String adType; // 'Sale' | 'Rent'
  final String estateType; // 'Apartment' | 'House' | 'Office' | 'Field'
  final double surfaceArea;
  final int? nbRooms;
  final String location;
  final double price;
  final String? imageURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Advert({
    required this.id,
    required this.description,
    required this.adType,
    required this.estateType,
    required this.surfaceArea,
    this.nbRooms,
    required this.location,
    required this.price,
    this.imageURL,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Advert.fromJson(Map<String, dynamic> json) {
    return Advert(
      id: json['id'] as int,
      description: json['description'] as String,
      adType: json['adType'] as String,
      estateType: json['estateType'] as String,
      surfaceArea: (json['surfaceArea'] as num).toDouble(),
      nbRooms: json['nbRooms'] as int?,
      location: json['location'] as String,
      price: (json['price'] as num).toDouble(),
      imageURL: json['imageURL'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'adType': adType,
        'estateType': estateType,
        'surfaceArea': surfaceArea,
        'nbRooms': nbRooms,
        'location': location,
        'price': price,
        'imageURL': imageURL,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Advert copyWith({
    int? id,
    String? description,
    String? adType,
    String? estateType,
    double? surfaceArea,
    int? nbRooms,
    String? location,
    double? price,
    String? imageURL,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Advert(
      id: id ?? this.id,
      description: description ?? this.description,
      adType: adType ?? this.adType,
      estateType: estateType ?? this.estateType,
      surfaceArea: surfaceArea ?? this.surfaceArea,
      nbRooms: nbRooms ?? this.nbRooms,
      location: location ?? this.location,
      price: price ?? this.price,
      imageURL: imageURL ?? this.imageURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get imageUri {
    if (imageURL == null) {
      return 'https://picsum.photos/seed/$id/800/450';
    }
    if (imageURL!.startsWith('http')) return imageURL!;
    const baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://192.168.1.6:3000');
    return '$baseUrl$imageURL';
  }

  String get estateIcon {
    switch (estateType) {
      case 'Apartment': return '🏢';
      case 'House': return '🏠';
      case 'Office': return '🏛️';
      case 'Field': return '🌿';
      default: return '🏘️';
    }
  }

  String get formattedPrice {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class AdvertMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdvertMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AdvertMeta.fromJson(Map<String, dynamic> json) {
    return AdvertMeta(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

class AdvertFilters {
  final String? q;
  final String? adType;
  final String? estateType;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final int page;

  const AdvertFilters({
    this.q,
    this.adType,
    this.estateType,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
  });

  AdvertFilters copyWith({
    String? q,
    String? adType,
    String? estateType,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? page,
    bool clearQ = false,
    bool clearAdType = false,
    bool clearEstateType = false,
  }) {
    return AdvertFilters(
      q: clearQ ? null : (q ?? this.q),
      adType: clearAdType ? null : (adType ?? this.adType),
      estateType: clearEstateType ? null : (estateType ?? this.estateType),
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      page: page ?? this.page,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (q != null && q!.isNotEmpty) params['q'] = q!;
    if (adType != null) params['adType'] = adType!;
    if (estateType != null) params['estateType'] = estateType!;
    if (location != null) params['location'] = location!;
    if (minPrice != null) params['minPrice'] = minPrice!.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice!.toString();
    params['page'] = page.toString();
    return params;
  }
}
