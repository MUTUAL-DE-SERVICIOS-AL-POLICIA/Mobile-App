import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:muserpol_pvt/components/containers.dart';

class ServiceOption extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onPressed;

  const ServiceOption({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onPressed,
        child: ContainerComponent(
          width: double.infinity,
          color: const Color(0xffd9e9e7),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 16,
          boxShadow: [
            BoxShadow(
                color: isDarkMode
                    ? Colors.white.withAlpha((0.2 * 255).toInt())
                    : Colors.black.withAlpha((0.4 * 255).toInt()),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4))
          ],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(width: 60, height: 60, child: Image.asset(image)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
