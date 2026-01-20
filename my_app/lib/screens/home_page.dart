import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // for parse()
import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../constants/colors.dart'; // for primaryColor, accentColor, etc.
import 'welcome_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
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

  // ------------------------ NEW STATE VARIABLES ------------------------
  List<Recipe> plannedRecipes = [];
  Set<String> autoAddedIngredients = {};
  Set<String> removedAutoIngredients = {};
  bool showOnlyNeeded = true;

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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
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
                child: const Icon(Icons.add, size: 32, color: textColor),
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
                    color: textColor.withOpacity(0.7),
                  ),
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
                          color: isSelected ? backgroundColor : textColor,
                        ),
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
                  final isPlanned = plannedRecipes.contains(r);
                  return Card(
                    color: accentColor.withOpacity(0.4),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              r.imagePath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (isPlanned)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 16,
                                  color: backgroundColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        r.title,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        r.categories.join(', '),
                        style: GoogleFonts.playfairDisplay(color: textColor),
                      ),
                      trailing: Checkbox(
                        value: isPlanned,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              plannedRecipes.add(r);
                              for (var ing in r.ingredients) {
                                if (!groceryItems.any((g) => g.name == ing)) {
                                  groceryItems.add(GroceryItem(name: ing));
                                  autoAddedIngredients.add(ing);
                                }
                              }
                            } else {
                              plannedRecipes.remove(r);
                              for (var ing in r.ingredients) {
                                removedAutoIngredients.add(ing);
                              }
                            }
                          });
                        },
                      ),
                      onTap: () async {
                        // Your existing recipe ingredient selection dialog
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

  // ------------------------ GROCERY TAB ------------------------
  Widget buildGroceryTab() {
    final groceryController = TextEditingController();

    final manualItems = groceryItems
        .where((g) => !autoAddedIngredients.contains(g.name))
        .toList();

    final Map<String, List<String>> recipeIngredientMap = {};
    for (var recipe in plannedRecipes) {
      final ingredients = recipe.ingredients
          .where((ing) =>
              autoAddedIngredients.contains(ing) &&
              !removedAutoIngredients.contains(ing))
          .toList();
      if (ingredients.isNotEmpty) {
        recipeIngredientMap[recipe.title] = ingredients;
      }
    }

    final totalPlannedIngredients =
        recipeIngredientMap.values.fold(0, (sum, list) => sum + list.length);

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${plannedRecipes.length} recipes planned, $totalPlannedIngredients ingredients',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: showOnlyNeeded,
                onChanged: (val) {
                  setState(() {
                    showOnlyNeeded = val;
                  });
                },
              ),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: ListView(
            children: [
              // Auto-added ingredients from planned recipes
              ...recipeIngredientMap.entries.expand((entry) {
                final recipeName = entry.key;
                final ingredients = entry.value;

                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      recipeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...ingredients.map((ing) {
                    final item = groceryItems.firstWhere((g) => g.name == ing);
                    if (showOnlyNeeded && item.bought)
                      return const SizedBox.shrink();

                    return CheckboxListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration:
                              item.bought ? TextDecoration.lineThrough : null,
                          color: item.bought ? Colors.grey : Colors.black,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      value: item.bought,
                      onChanged: (val) {
                        setState(() {
                          item.bought = val ?? false;
                        });
                      },
                    );
                  }).toList(),
                ];
              }),

              // Manual grocery items
              if (manualItems.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Manual Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                ...manualItems.map((item) {
                  if (showOnlyNeeded && item.bought)
                    return const SizedBox.shrink();

                  return Dismissible(
                    key: Key(item.name),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        groceryItems.remove(item);
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration:
                              item.bought ? TextDecoration.lineThrough : null,
                          color: item.bought ? Colors.grey : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: item.bought,
                      onChanged: (val) {
                        setState(() {
                          item.bought = val ?? false;
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ],
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
                      const SnackBar(content: Text('Recipe added from URL!')),
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
                      decoration: const InputDecoration(
                        hintText: 'Add ingredient',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (newIngredientController.text.isNotEmpty) {
                        setState(() {
                          tempIngredients.add(
                            newIngredientController.text.trim(),
                          );
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
                          tempInstructions.add(
                            newInstructionController.text.trim(),
                          );
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
                      recipes[editingRecipeIndex!] = newRecipe;
                      editingRecipeIndex = null;
                    } else {
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
                Center(child: Text('My Recipes: ${recipes.length}')),
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
