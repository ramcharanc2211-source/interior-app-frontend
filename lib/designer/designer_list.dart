import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../booking/my_bookings.dart';
import '../screens/login_screen.dart';
import 'designer_detail.dart';

class DesignerListScreen extends StatefulWidget {
  const DesignerListScreen({super.key});

  @override
  State<DesignerListScreen> createState() => _DesignerListScreenState();
}

class _DesignerListScreenState extends State<DesignerListScreen> {
  static const String baseUrl = ApiConfig.baseUrl;

  List designers = [];
  List filteredDesigners = [];

  bool isLoading = true;
  bool isRefreshing = false;

  String selectedCategory = 'All';

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Minimalist',
    'Contemporary',
    'Eco-Friendly',
    'Luxury',
    'Classic',
  ];

  @override
  void initState() {
    super.initState();
    fetchDesigners();
  }

  Future<void> fetchDesigners() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/designers'))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            designers = data;
            filteredDesigners = data;
            isLoading = false;
          });

          filterDesigners();
        } else {
          setState(() {
            designers = [];
            filteredDesigners = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });

        showMessage('Failed to load designers', isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Unable to connect to server', isError: true);
    }
  }

  Future<void> refreshDesigners() async {
    setState(() {
      isRefreshing = true;
    });

    await fetchDesigners();

    if (mounted) {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  void filterDesigners() {
    final query = searchController.text.trim().toLowerCase();

    final results = designers.where((designer) {
      final name = (designer['name'] ?? '').toString().toLowerCase();

      final specialty = (designer['specialty'] ?? '').toString().toLowerCase();

      final matchesSearch = name.contains(query) || specialty.contains(query);

      final matchesCategory =
          selectedCategory == 'All' ||
          specialty == selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    if (mounted) {
      setState(() {
        filteredDesigners = results;
      });
    }
  }

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF6A11CB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String getDesignerImage(dynamic designer) {
    final image = designer['image'];

    if (image != null && image.toString().trim().isNotEmpty) {
      return image.toString();
    }

    return 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1000';
  }

  String getDesignerName(dynamic designer) {
    return (designer['name'] ?? 'Interior Designer').toString();
  }

  String getDesignerSpecialty(dynamic designer) {
    return (designer['specialty'] ?? 'Interior Design').toString();
  }

  String getDesignerRating(dynamic designer) {
    final rating = designer['rating'];

    if (rating == null) {
      return '4.8';
    }

    return rating.toString();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Row(
            children: [
              Icon(Icons.home_work_rounded, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text(
                'Interior Designers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Profile',
              icon: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF6A11CB),
                ),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  logout();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
            )
          : RefreshIndicator(
              onRefresh: refreshDesigners,
              color: const Color(0xFF6A11CB),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) {
                          filterDesigners();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search designers or styles...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF6A11CB),
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    searchController.clear();
                                    filterDesigners();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = category;
                              });

                              filterDesigners();
                            },
                            selectedColor: const Color(0xFF6A11CB),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        const Text(
                          'Discover Designers',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF202124),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredDesigners.length} found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filteredDesigners.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 70),
                              Icon(
                                Icons.search_off_rounded,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 15),
                              const Center(
                                child: Text(
                                  'No designers found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Try another search or category',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 5, bottom: 25),
                            itemCount: filteredDesigners.length,
                            itemBuilder: (context, index) {
                              final designer = filteredDesigners[index];

                              return _buildDesignerCard(designer);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDesignerCard(dynamic designer) {
    final imageUrl = getDesignerImage(designer);
    final name = getDesignerName(designer);
    final specialty = getDesignerSpecialty(designer);
    final rating = getDesignerRating(designer);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DesignerDetailScreen(designer: designer),
          ),
        );
      },
      child: Container(
        height: 215,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.78),
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 17,
                right: 17,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.design_services_rounded,
                          color: Colors.white70,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            specialty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
