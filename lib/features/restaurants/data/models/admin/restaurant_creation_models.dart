// No imports needed for models only

/// Sub-model for gallery images
class GalleryImageModel {
  final String url;
  final String alt;

  GalleryImageModel({required this.url, required this.alt});

  Map<String, dynamic> toJson() => {'url': url, 'alt': alt};
}

/// Sub-model for coordinates
class CoordinatesModel {
  final String type;
  final List<double> coordinates;
  final String address;

  CoordinatesModel({
    this.type = 'Point',
    required this.coordinates,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'coordinates': coordinates,
    'address': address,
  };
}

/// Sub-model for weekly timings
class WeeklyTimingModel {
  final String day;
  final String hours;

  WeeklyTimingModel({required this.day, required this.hours});

  Map<String, dynamic> toJson() => {'day': day, 'hours': hours};
}

/// Sub-model for menu categories
class MenuCategoryModel {
  final String name;
  final String image;
  final List<dynamic> items;

  MenuCategoryModel({
    required this.name,
    required this.image,
    this.items = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'items': items,
  };
}

/// Sub-model for buffets
class BuffetModel {
  final String name;
  final String type;
  final List<String> days;
  final String hours;
  final num price;

  BuffetModel({
    required this.name,
    required this.type,
    required this.days,
    required this.hours,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'days': days,
    'hours': hours,
    'price': price,
  };
}

/// Sub-model for reviews
class ReviewModel {
  final String name;
  final num rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'rating': rating,
    'comment': comment,
    'date': date,
  };
}

/// Sub-model for pre-book offers
class PreBookOfferModel {
  final String title;
  final String description;
  final String slots;
  final String buttonText;

  PreBookOfferModel({
    required this.title,
    required this.description,
    required this.slots,
    required this.buttonText,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'slots': slots,
    'buttonText': buttonText,
  };
}

/// Sub-model for walk-in offers
class WalkInOfferModel {
  final String title;
  final String description;
  final String validTime;
  final String icon;

  WalkInOfferModel({
    required this.title,
    required this.description,
    required this.validTime,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'validTime': validTime,
    'icon': icon,
  };
}

/// Sub-model for bank benefits
class BankBenefitModel {
  final String bankName;
  final String description;
  final String code;
  final String bgColor;

  BankBenefitModel({
    required this.bankName,
    required this.description,
    required this.code,
    required this.bgColor,
  });

  Map<String, dynamic> toJson() => {
    'bankName': bankName,
    'description': description,
    'code': code,
    'bgColor': bgColor,
  };
}

/// Sub-model for featured in info
class FeaturedInModel {
  final String title;
  final String image;

  FeaturedInModel({required this.title, required this.image});

  Map<String, dynamic> toJson() => {'title': title, 'image': image};
}

/// Sub-model for about info
class AboutInfoModel {
  final String established;
  final String location;
  final String priceForTwo;
  final List<String> cuisineTypes;
  final List<String> facilities;
  final FeaturedInModel featuredIn;

  AboutInfoModel({
    required this.established,
    required this.location,
    required this.priceForTwo,
    required this.cuisineTypes,
    required this.facilities,
    required this.featuredIn,
  });

  Map<String, dynamic> toJson() => {
    'established': established,
    'location': location,
    'priceForTwo': priceForTwo,
    'cuisineTypes': cuisineTypes,
    'facilities': facilities,
    'featuredIn': featuredIn.toJson(),
  };
}

/// Main request model for creating a restaurant (hotel)
class RestaurantCreateRequestModel {
  final String name;
  final String cuisine;
  final double? rating;
  final String description;
  final String? offer;
  final String? mainImage;
  final List<GalleryImageModel>? galleryImages;
  final String location;
  final String? googlePlaceId;
  final CoordinatesModel? coordinates;
  final String distance;
  final String price;
  final List<WeeklyTimingModel>? weeklyTimings;
  final List<MenuCategoryModel>? menuCategories;
  final List<BuffetModel>? buffets;
  final List<ReviewModel>? reviews;
  final List<PreBookOfferModel>? preBookOffers;
  final List<WalkInOfferModel>? walkInOffers;
  final List<BankBenefitModel>? bankBenefits;
  final AboutInfoModel? aboutInfo;
  final String? vendorId;
  final String? mallId;
  final num? cgstRate;
  final num? sgstRate;
  final num? serviceCharge;

  RestaurantCreateRequestModel({
    required this.name,
    required this.cuisine,
    this.rating,
    required this.description,
    this.offer,
    this.mainImage,
    this.galleryImages,
    required this.location,
    this.googlePlaceId,
    this.coordinates,
    required this.distance,
    required this.price,
    this.weeklyTimings,
    this.menuCategories,
    this.buffets,
    this.reviews,
    this.preBookOffers,
    this.walkInOffers,
    this.bankBenefits,
    this.aboutInfo,
    this.vendorId,
    this.mallId,
    this.cgstRate,
    this.sgstRate,
    this.serviceCharge,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cuisine': cuisine,
      if (rating != null) 'rating': rating,
      'description': description,
      if (offer != null) 'offer': offer,
      if (mainImage != null) 'main_image': mainImage,
      if (galleryImages != null)
        'gallery_images': galleryImages!.map((e) => e.toJson()).toList(),
      'location': location,
      if (googlePlaceId != null) 'google_place_id': googlePlaceId,
      if (coordinates != null) 'coordinates': coordinates!.toJson(),
      'distance': distance,
      'price': price,
      if (weeklyTimings != null)
        'weekly_timings': weeklyTimings!.map((e) => e.toJson()).toList(),
      if (menuCategories != null)
        'menu_categories': menuCategories!.map((e) => e.toJson()).toList(),
      if (buffets != null) 'buffets': buffets!.map((e) => e.toJson()).toList(),
      if (reviews != null) 'reviews': reviews!.map((e) => e.toJson()).toList(),
      if (preBookOffers != null)
        'pre_book_offers': preBookOffers!.map((e) => e.toJson()).toList(),
      if (walkInOffers != null)
        'walk_in_offers': walkInOffers!.map((e) => e.toJson()).toList(),
      if (bankBenefits != null)
        'bank_benefits': bankBenefits!.map((e) => e.toJson()).toList(),
      if (aboutInfo != null) 'about_info': aboutInfo!.toJson(),
      if (vendorId != null) 'vendor_id': vendorId,
      if (mallId != null) 'mall_id': mallId,
      if (cgstRate != null) 'cgst_rate': cgstRate,
      if (sgstRate != null) 'sgst_rate': sgstRate,
      if (serviceCharge != null) 'service_charge': serviceCharge,
    };
  }
}

/// Model for place autocomplete suggestion
class PlaceAutocompleteModel {
  final String description;
  final String placeId;

  PlaceAutocompleteModel({required this.description, required this.placeId});

  factory PlaceAutocompleteModel.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteModel(
      description: json['description'] as String? ?? '',
      placeId: json['placeId'] as String? ?? json['place_id'] as String? ?? '',
    );
  }
}
