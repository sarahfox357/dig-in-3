import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // for parse()

void main() {
  runApp(const MyApp());
}

// ------------------------ COLORS ------------------------
const Color primaryColor = Color(0xFFC7D6BB);
const Color accentColor = Color(0xFFC7D6BB);
const Color backgroundColor = Color.fromARGB(190, 252, 252, 252);
const Color textColor = Color.fromARGB(255, 2, 8, 13);

// ------------------------ MODELS ------------------------
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

class GroceryItem {
  String name;
  bool bought;
  GroceryItem({required this.name, this.bought = false});
}

// ------------------------ MAIN APP ------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Recipe App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: GoogleFonts.playfairDisplayTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: backgroundColor,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ------------------------ WELCOME SCREEN ------------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dig in',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your all-in-one recipe storage',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: textColor.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MyHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: textColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Let's Dig In",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------ HOME PAGE ------------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  int? editRecipeIndex;
  int? editingRecipeIndex;
  bool _showManualForm = false;

  List<Recipe> recipes = [];
  List<GroceryItem> groceryItems = [];
  String? newRecipeImagePath;

  final titleController = TextEditingController();
  final usernameController = TextEditingController();
  final newIngredientController = TextEditingController();
  final newInstructionController = TextEditingController();
  String username = "ChefMaster";
  List<String> selectedCategories = [];
  List<String> tempIngredients = [];
  List<String> tempInstructions = [];

  // ------------------------ TABS ------------------------
  List<Widget> _widgetOptions() => <Widget>[
        buildRecipesTab(),
        buildGroceryTab(),
        buildNewRecipeTab(),
        buildSearchTab(),
        buildAccountTab(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showManualForm = false;
    });
  }

  Widget _navItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        size: 26,
        color: isSelected ? textColor : textColor.withOpacity(0.4),
      ),
    );
  }

  // ------------------------ BUILD ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          'What next, chef?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, 0),
            _navItem(Icons.receipt_long, 1),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: textColor,
                ),
              ),
            ),
            _navItem(Icons.search, 3),
            _navItem(Icons.account_circle, 4),
          ],
        ),
      ),
    );
  }

  // ------------------------ RECIPES TAB ------------------------
  Widget buildRecipesTab() {
    List<String> categories = [
      'All',
      'Breakfast',
      'Lunch',
      'Dinner',
      '30 mins or less',
      'Sheet pan',
      'Desserts',
    ];

    final searchController = TextEditingController();
    String selectedCategory = 'All';

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        List<Recipe> filteredRecipes = recipes.where((recipe) {
          final query = searchController.text.toLowerCase();
          final matchesSearch = recipe.title.toLowerCase().contains(query);
          final matchesCategory = selectedCategory == 'All' ||
              recipe.categories.contains(selectedCategory);
          return matchesSearch && matchesCategory;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                style: GoogleFonts.playfairDisplay(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: accentColor,
                  hintText: 'Search recipes...',
                  hintStyle: GoogleFonts.playfairDisplay(
                      color: textColor.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setStateLocal(() {}),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.playfairDisplay(
                            color: isSelected ? backgroundColor : textColor),
                      ),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: accentColor,
                      onSelected: (bool selected) {
                        setStateLocal(() {
                          selectedCategory = selected ? cat : 'All';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView(
                children: filteredRecipes.map((r) {
                  return Card(
                    color: accentColor.withOpacity(0.4),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          r.imagePath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(r.title,
                          style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.bold,
                              color: primaryColor)),
                      subtitle: Text(r.categories.join(', '),
                          style: GoogleFonts.playfairDisplay(color: textColor)),
                      onTap: () async {
                        final selectedIngredients =
                            await showDialog<List<String>>(
                          context: context,
                          builder: (context) {
                            final Map<String, bool> selection = {
                              for (var ing in r.ingredients) ing: true
                            };
                            return AlertDialog(
                              title:
                                  const Text('Add ingredients to Grocery List'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: selection.keys.map((ingredient) {
                                    return StatefulBuilder(
                                      builder: (context, setStateSB) {
                                        return CheckboxListTile(
                                          title: Text(ingredient),
                                          value: selection[ingredient],
                                          onChanged: (val) {
                                            setStateSB(() {
                                              selection[ingredient] =
                                                  val ?? false;
                                            });
                                          },
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, []),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    final chosen = selection.entries
                                        .where((e) => e.value)
                                        .map((e) => e.key)
                                        .toList();
                                    Navigator.pop(context, chosen);
                                  },
                                  child: const Text('Add Selected'),
                                ),
                              ],
                            );
                          },
                        );

                        if (selectedIngredients != null &&
                            selectedIngredients.isNotEmpty) {
                          setState(() {
                            groceryItems.addAll(selectedIngredients
                                .map((i) => GroceryItem(name: i)));
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------ NEW RECIPE TAB ------------------------
  Widget buildNewRecipeTab() {
    List<String> categories = [
      'Breakfast',
      'Lunch',
      'Dinner',
      '30 mins or less',
      'Sheet pan',
      'Desserts',
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_showManualForm) ...[
              const Text(
                'Choose how to add a new recipe:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final url = await _urlInputDialog();
                  if (url != null && url.isNotEmpty) {
                    await _handleRecipeUrl(url);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recipe added from URL!'),
                      ),
                    );
                  }
                },
                child: const Text('Upload from URL or Social Media'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showManualForm = true;
                    editingRecipeIndex = null;
                    titleController.clear();
                    tempIngredients.clear();
                    tempInstructions.clear();
                    selectedCategories.clear();
                  });
                },
                child: const Text('Upload Manually'),
              ),
            ] else ...[
              // ---------------- MANUAL FORM ----------------

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Recipe Title'),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: categories.map((cat) {
                  final selected = selectedCategories.contains(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (bool val) {
                      setState(() {
                        if (val) {
                          selectedCategories.add(cat);
                        } else {
                          selectedCategories.remove(cat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // INGREDIENTS
              const Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              for (var ing in tempIngredients)
                ListTile(
                  title: Text(ing),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        tempIngredients.remove(ing);
                      });
                    },
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: newIngredientController,
                      decoration:
                          const InputDecoration(hintText: 'Add ingredient'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (newIngredientController.text.isNotEmpty) {
                        setState(() {
                          tempIngredients
                              .add(newIngredientController.text.trim());
                          newIngredientController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // INSTRUCTIONS
              const Text(
                'Instructions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              for (var i = 0; i < tempInstructions.length; i++)
                ListTile(
                  title: Text('${i + 1}. ${tempInstructions[i]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        tempInstructions.removeAt(i);
                      });
                    },
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: newInstructionController,
                      decoration: const InputDecoration(
                        hintText: 'Add instruction step',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (newInstructionController.text.isNotEmpty) {
                        setState(() {
                          tempInstructions
                              .add(newInstructionController.text.trim());
                          newInstructionController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // SAVE / UPDATE BUTTON
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      tempIngredients.isEmpty ||
                      tempInstructions.isEmpty) return;

                  setState(() {
                    final newRecipe = Recipe(
                      title: titleController.text.trim(),
                      ingredients: List.from(tempIngredients),
                      instructions: List.from(tempInstructions),
                      categories: List.from(selectedCategories),
                      imagePath: 'https://via.placeholder.com/150',
                    );

                    if (editingRecipeIndex != null) {
                      // UPDATE EXISTING
                      recipes[editingRecipeIndex!] = newRecipe;
                      editingRecipeIndex = null;
                    } else {
                      // CREATE NEW
                      recipes.add(newRecipe);
                    }

                    titleController.clear();
                    tempIngredients.clear();
                    tempInstructions.clear();
                    selectedCategories.clear();
                    _showManualForm = false;
                  });
                },
                child: Text(
                  editingRecipeIndex == null ? 'Save Recipe' : 'Update Recipe',
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  setState(() {
                    editingRecipeIndex = null;
                    _showManualForm = false;
                  });
                },
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ------------------------ GROCERY LIST ------------------------
  Widget buildGroceryTab() {
    final groceryController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: groceryController,
                  decoration:
                      const InputDecoration(hintText: 'Add grocery item'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (groceryController.text.isNotEmpty) {
                    setState(() {
                      groceryItems
                          .add(GroceryItem(name: groceryController.text));
                      groceryController.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: groceryItems.map((item) {
              return CheckboxListTile(
                title: Text(item.name),
                value: item.bought,
                onChanged: (val) {
                  setState(() {
                    item.bought = val ?? false;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ------------------------ SEARCH TAB ------------------------
  Widget buildSearchTab() => const Center(child: Text('Search Tab'));

  // ------------------------ ACCOUNT TAB ------------------------
  Widget buildAccountTab() {
    usernameController.text = username;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: primaryColor,
            child: const TabBar(
              labelColor: backgroundColor,
              unselectedLabelColor: textColor,
              indicatorColor: backgroundColor,
              tabs: [
                Tab(text: 'Username'),
                Tab(text: 'My Recipes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            username = usernameController.text;
                          });
                        },
                        child: const Text('Save Username'),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    'My Recipes: ${recipes.length}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------ URL DIALOG ------------------------
  Future<String?> _urlInputDialog() async {
    final urlController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paste Recipe URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: 'Enter URL'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, urlController.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRecipeUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final title = document.querySelector('title')?.text ?? 'Recipe';
        setState(() {
          recipes.add(
            Recipe(
              title: title,
              ingredients: [],
              instructions: [],
              categories: [],
              imagePath: 'https://via.placeholder.com/150',
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching recipe: $e');
    }
  }
}

// ------------------------ RECIPE DETAIL SCREEN ------------------------
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final Function(List<String>) onAddToGrocery;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.onAddToGrocery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe.title,
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: textColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              recipe.imagePath,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: accentColor.withOpacity(0.3),
                child: const Icon(Icons.image, size: 60),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ingredients',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (recipe.ingredients.isEmpty)
            const Text('No ingredients added.')
          else
            ...recipe.ingredients.map(
              (ing) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('• $ing'),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Add Ingredients to Grocery List'),
            onPressed: recipe.ingredients.isEmpty
                ? null
                : () {
                    onAddToGrocery(recipe.ingredients);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingredients added to grocery list 🛒'),
                      ),
                    );
                  },
          ),
          const SizedBox(height: 32),
          Text(
            'Instructions',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (recipe.instructions.isEmpty)
            const Text('No instructions added.')
          else
            ...List.generate(
              recipe.instructions.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${i + 1}. ${recipe.instructions[i]}',
                  style: const TextStyle(height: 1.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
