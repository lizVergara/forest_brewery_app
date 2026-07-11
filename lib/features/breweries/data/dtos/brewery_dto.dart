import '../../domain/entities/brewery.dart';

class BreweryDto {
  final String id;
  final String name;
  final String breweryType;
  final String? address1;
  final String? address2;
  final String? address3;
  final String city;
  final String? stateProvince;
  final String? postalCode;
  final String? country;
  final String? phone;
  final String? websiteUrl;
  final Object? latitude;
  final Object? longitude;

  const BreweryDto({
    required this.id,
    required this.name,
    required this.breweryType,
    required this.city,
    this.address1,
    this.address2,
    this.address3,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.phone,
    this.websiteUrl,
    this.latitude,
    this.longitude,
  });

  factory BreweryDto.fromJson(Map<String, dynamic> json) {
    return BreweryDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown brewery',
      breweryType: json['brewery_type'] as String? ?? 'unknown',
      address1: json['address_1'] as String?,
      address2: json['address_2'] as String?,
      address3: json['address_3'] as String?,
      city: json['city'] as String? ?? '',
      stateProvince: json['state_province'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
      websiteUrl: json['website_url'] as String?,
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Brewery toEntity() {
    return Brewery(
      id: id,
      name: name,
      breweryType: breweryType,
      city: city,
      address: _buildAddress(),
      phone: phone,
      websiteUrl: websiteUrl,
      latitude: _parseCoordinate(latitude),
      longitude: _parseCoordinate(longitude),
    );
  }

  String? _buildAddress() {
    final parts =
        [address1, address2, address3, city, stateProvince, postalCode, country]
            .where((part) => part != null && part.trim().isNotEmpty)
            .map((part) => part!.trim())
            .toList();

    if (parts.isEmpty) return null;

    return parts.join(', ');
  }

  double? _parseCoordinate(Object? value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      if (value.trim().isEmpty) return null;

      return double.tryParse(value);
    }

    return null;
  }
}
