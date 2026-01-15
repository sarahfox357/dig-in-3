class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> categories;
  final String imagePath;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.categories,
    required this.imagePath,
  });
}
