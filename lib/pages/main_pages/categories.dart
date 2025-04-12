import 'package:byhands/pages/menus/mainmenu.dart';
import 'package:byhands/pages/pop_up/category_details.dart';
import 'package:byhands/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands/pages/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> displayedCategories = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('categories').select();
      setState(() {
        allCategories =
            (response as List<dynamic>?)
                ?.map(
                  (e) => {
                    'Name': e['Name'] ?? 'Unknown', // Handle null values
                    'Description':
                        e['Description'] ?? 'No description available',
                    'icon': e['icon'],
                  },
                )
                .toList() ??
            [];

        displayedCategories = allCategories;
      });
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  void _requestNewCategory(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descrbtionController = TextEditingController();
    final explainController = TextEditingController();

    Future<void> insertRequest() async {
      try {
        await Supabase.instance.client.from('category_requests').insert({
          'categoryName': nameController.text,
          'Details': descrbtionController.text,
          'Explain': explainController.text,
        });
        print("Data inserted successfully");
      } catch (e) {
        print("Error inserting data: $e");
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Request New Category",
            style: Theme.of(context).textTheme.labelLarge,
          ),
          content: Form(
            key: formfield,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    nameController,
                    "Category Name",
                    "Please enter category name",
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    descrbtionController,
                    "Category Description",
                    "Please enter category description",
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    explainController,
                    "Category request explanation",
                    "Please enter category request explanation",
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Submit"),
              onPressed: () async {
                // Check if name requested before
                bool categorynamerequested = await checkCategorynameExists(
                  nameController.text,
                );
                if (categorynamerequested) {
                  Navigator.of(context).pop();
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      content: Text('Category already exists'),
                    ),
                  );
                  return;
                }

                // Insert Data
                if (formfield.currentState!.validate()) {
                  insertRequest();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    String validatorText,
  ) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        decoration: textInputdecoration(
          context,
          labelText,
        ).copyWith(prefixIcon: Icon(Icons.abc)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText;
          }
          return null;
        },
      ),
    );
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      displayedCategories =
          allCategories
              .where(
                (category) => category['Name']
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text("Categories"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(
                          255,
                          135,
                          128,
                          139,
                        ) // Dark mode color
                        : const Color.fromARGB(
                          255,
                          203,
                          194,
                          205,
                        ), // Light mode color
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: CommonDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextField(
                onChanged: updateSearchQuery,
                decoration: InputDecoration(
                  labelText: 'Search Categories',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child:
                displayedCategories.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: displayedCategories.length,
                      itemBuilder: (context, index) {
                        final category = displayedCategories[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Container(
                            decoration: customContainerDecoration(context),
                            child: ListTile(
                              onTap: () {
                                String CategoryName = category['Name'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CategoryDetailPage(
                                          categoryName: CategoryName,
                                        ),
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              title: Row(
                                children: [
                                  Image.network(
                                    supabase.storage
                                        .from('images')
                                        .getPublicUrl(
                                          'categories/${category['icon']}',
                                        ),
                                    width: 50, // Increased size for visibility
                                    height: 50,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return CircularProgressIndicator(); // Loading spinner
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                      ); // Fallback if image fails to load
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    category['Name'] ?? 'Unknown Category',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 54, 43, 75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          TextButton(
            onPressed: () {
              _requestNewCategory(context);
            },
            child: Text(
              " Request for a new category",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      bottomNavigationBar: mainMenu(1),
    );
  }
}

Future<bool> checkCategorynameExists(String name) async {
  final response =
      await Supabase.instance.client
          .from('categories')
          .select()
          .eq('Name', name)
          .maybeSingle();

  if (response != null) {
    return true; // Username exists
  } else {
    return false; // Username does not exist
  }
}
