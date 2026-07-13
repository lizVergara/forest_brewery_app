class Brewery {
  final String id;
  final String name;
  final String breweryType;
  final String city;
  final String? address;
  final String? phone;
  final String? websiteUrl;
  final double? latitude;
  final double? longitude;
  final double? distanceInKm;

  const Brewery({
    required this.id,
    required this.name,
    required this.breweryType,
    required this.city,
    this.address,
    this.phone,
    this.websiteUrl,
    this.latitude,
    this.longitude,
    this.distanceInKm,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  Brewery copyWith({
    String? id,
    String? name,
    String? breweryType,
    String? city,
    String? address,
    String? phone,
    String? websiteUrl,
    double? latitude,
    double? longitude,
    double? distanceInKm,
  }) {
    return Brewery(
      id: id ?? this.id,
      name: name ?? this.name,
      breweryType: breweryType ?? this.breweryType,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceInKm: distanceInKm ?? this.distanceInKm,
    );
  }
}
