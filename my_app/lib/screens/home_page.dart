import 'dart:convert';
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
  String? suggestedCategoryFromUrl;

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

  // ------------------------ GROCERY TAB ------------------------
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
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.bought ? TextDecoration.lineThrough : null,
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
              // Manual form continues unchanged
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
              // Ingredients, Instructions, Save/Cancel buttons unchanged...
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

  // ------------------------ HANDLE URL ------------------------
  Future<void> _handleRecipeUrl(String url) async {
    try {
      final proxyUrl =
          'https://api.allorigins.win/get?url=${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body)['contents'];
        final document = parse(body);

        // --- 1. Title ---
        final title = document.querySelector('title')?.text.trim() ?? 'Recipe';

        // --- 2. Ingredients ---
        List<String> ingredients = [];
        final allRecipesIngredients =
            document.querySelectorAll('li.ingredients-item');
        if (allRecipesIngredients.isNotEmpty) {
          ingredients = allRecipesIngredients
              .map((e) => e.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }

        // --- 3. Instructions ---
        List<String> instructions = [];
        final allRecipesInstructions = document
            .querySelectorAll('li.subcontainer.instructions-section-item');
        if (allRecipesInstructions.isNotEmpty) {
          instructions = allRecipesInstructions
              .map((e) => e.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }

        // --- 4. Image ---
        String imageUrl = 'https://via.placeholder.com/150';
        final allRecipesImage = document.querySelector('img.rec-photo');
        if (allRecipesImage != null) {
          imageUrl = allRecipesImage.attributes['src'] ?? imageUrl;
        }
        newRecipeImagePath = imageUrl;

        // --- 5. Populate form ---
        setState(() {
          titleController.text = title;
          tempIngredients = List.from(ingredients);
          tempInstructions = List.from(instructions);
          _showManualForm = true;
          editingRecipeIndex = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe data loaded!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch recipe')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipe: $e')),
      );
    }
  }
} // <-- End of _MyHomePageState
