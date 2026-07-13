import 'package:flutter/material.dart';

import '../../../domain/entities/brewery.dart';

class BreweryListItem extends StatelessWidget {
  final Brewery brewery;
  final VoidCallback? onTap;

  const BreweryListItem({required this.brewery, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(brewery.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${brewery.breweryType} • ${brewery.city}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
