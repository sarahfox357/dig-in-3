class Recipe {
  String title;
  List<String> ingredients;
  List<String> instructions;
  List<String> categories;
  String imagePath; // Can be a URL or local asset path

  Recipe({
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.categories,
    required this.imagePath,
  });
}
