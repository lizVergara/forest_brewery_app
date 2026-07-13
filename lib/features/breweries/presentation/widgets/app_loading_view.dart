import 'package:flutter/material.dart';

class AppLoadingView extends StatelessWidget {
  final String? message;

  const AppLoadingView({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: message == null
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message!, textAlign: TextAlign.center),
              ],
            ),
    );
  }
}
