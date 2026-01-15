import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/recipe.dart';
import '../constants/colors.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe.title,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                recipe.imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // CATEGORIES
            if (recipe.categories.isNotEmpty)
              Wrap(
                spacing: 8,
                children: recipe.categories
                    .map((c) => Chip(
                          label: Text(c),
                          backgroundColor: accentColor,
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            // INGREDIENTS
            Text(
              'Ingredients',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var ing in recipe.ingredients)
              Text(
                '- $ing',
                style: GoogleFonts.playfairDisplay(fontSize: 16),
              ),
            const SizedBox(height: 16),
            // INSTRUCTIONS
            Text(
              'Instructions',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < recipe.instructions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${i + 1}. ${recipe.instructions[i]}',
                  style: GoogleFonts.playfairDisplay(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
