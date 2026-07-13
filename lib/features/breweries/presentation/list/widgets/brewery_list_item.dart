import 'package:flutter/material.dart';

import '../../../domain/entities/brewery.dart';

class BreweryListItem extends StatelessWidget {
  final Brewery brewery;
  final VoidCallback? onTap;

  const BreweryListItem({required this.brewery, this.onTap, super.key});

  String get _subtitle {
    final parts = [
      brewery.breweryType,
      if (brewery.city.isNotEmpty) brewery.city,
      if (brewery.distanceInKm != null)
        '${brewery.distanceInKm!.toStringAsFixed(1)} km away',
    ];

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(brewery.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(_subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
