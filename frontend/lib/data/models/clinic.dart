import 'package:cloud_firestore/cloud_firestore.dart';

class Clinic {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> specialties;
  final String phoneNumber;
  final String businessHours;
  final List<ClinicService> services;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? website;
  final List<String> amenities;
  final List<String> doctors;
  final String? chiefDirector;

  Clinic({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.specialties,
    required this.phoneNumber,
    required this.businessHours,
    required this.services,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.website,
    this.amenities = const [],
    this.doctors = const [],
    this.chiefDirector,
  });

  // Firestore에서 데이터 생성
  factory Clinic.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Clinic(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      specialties: List<String>.from(data['specialties'] ?? []),
      phoneNumber: data['phoneNumber'] ?? '',
      businessHours: data['businessHours'] ?? '',
      services: (data['services'] as List<dynamic>? ?? [])
          .map((service) => ClinicService.fromMap(service))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      website: data['website'],
      amenities: List<String>.from(data['amenities'] ?? []),
      doctors: List<String>.from(data['doctors'] ?? []),
      chiefDirector: data['chiefDirector'],
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
      'specialties': specialties,
      'phoneNumber': phoneNumber,
      'businessHours': businessHours,
      'services': services.map((service) => service.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'website': website,
      'amenities': amenities,
      'doctors': doctors,
      'chiefDirector': chiefDirector,
    };
  }

  // 복사본 생성
  Clinic copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    List<String>? images,
    List<String>? specialties,
    String? phoneNumber,
    String? businessHours,
    List<ClinicService>? services,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? website,
    List<String>? amenities,
    List<String>? doctors,
    String? chiefDirector,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      specialties: specialties ?? this.specialties,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessHours: businessHours ?? this.businessHours,
      services: services ?? this.services,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      website: website ?? this.website,
      amenities: amenities ?? this.amenities,
      doctors: doctors ?? this.doctors,
      chiefDirector: chiefDirector ?? this.chiefDirector,
    );
  }
}

class ClinicService {
  final String name;
  final int price;
  final String description;
  final String duration;
  final String recovery;

  ClinicService({
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
    required this.recovery,
  });

  factory ClinicService.fromMap(Map<String, dynamic> map) {
    return ClinicService(
      name: map['name'] ?? '',
      price: map['price'] ?? 0,
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      recovery: map['recovery'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'duration': duration,
      'recovery': recovery,
    };
  }
}




