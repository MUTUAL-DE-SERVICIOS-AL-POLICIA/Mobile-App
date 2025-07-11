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
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onPressed,
        child: ContainerComponent(
          width: double.infinity,
          color: const Color(0xffd9e9e7),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 16,
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
