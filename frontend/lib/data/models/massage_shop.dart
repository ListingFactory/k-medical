import 'package:cloud_firestore/cloud_firestore.dart';

class MassageShop {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> categories;
  final String phoneNumber;
  final String businessHours;
  final List<Service> services;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  MassageShop({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.categories,
    required this.phoneNumber,
    required this.businessHours,
    required this.services,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore에서 데이터 생성
  factory MassageShop.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return MassageShop(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      phoneNumber: data['phoneNumber'] ?? '',
      businessHours: data['businessHours'] ?? '',
      services: (data['services'] as List<dynamic>? ?? [])
          .map((service) => Service.fromMap(service))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'categories': categories,
      'phoneNumber': phoneNumber,
      'businessHours': businessHours,
      'services': services.map((service) => service.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // 복사본 생성 (isFavorite 변경용)
  MassageShop copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    List<String>? images,
    List<String>? categories,
    String? phoneNumber,
    String? businessHours,
    List<Service>? services,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MassageShop(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      categories: categories ?? this.categories,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessHours: businessHours ?? this.businessHours,
      services: services ?? this.services,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MassageShop(id: $id, name: $name, address: $address, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MassageShop && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Service {
  final String name;
  final String description;
  final int price;
  final int duration; // 분 단위

  Service({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });

  // Map에서 Service 생성
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      duration: map['duration'] ?? 0,
    );
  }

  // Service를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
    };
  }

  @override
  String toString() {
    return 'Service(name: $name, price: $price, duration: $duration)';
  }
} 