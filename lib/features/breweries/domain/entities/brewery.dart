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
  });

  bool get hasCoordinates => latitude != null && longitude != null;
}
