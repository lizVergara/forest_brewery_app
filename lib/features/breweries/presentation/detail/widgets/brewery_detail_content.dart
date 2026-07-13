import 'package:flutter/material.dart';

import '../../../domain/entities/brewery.dart';
import 'detail_info_row.dart';

class BreweryDetailContent extends StatelessWidget {
  final Brewery brewery;

  const BreweryDetailContent({required this.brewery, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(brewery.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          brewery.breweryType,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        DetailInfoRow(
          icon: Icons.location_on_outlined,
          label: 'Address',
          value: brewery.address,
        ),
        DetailInfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: brewery.phone,
        ),
        DetailInfoRow(
          icon: Icons.language_outlined,
          label: 'Website',
          value: brewery.websiteUrl,
          selectable: true,
        ),
      ],
    );
  }
}
