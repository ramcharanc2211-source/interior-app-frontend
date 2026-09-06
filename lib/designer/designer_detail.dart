import 'package:flutter/material.dart';

import '../booking/booking_screen.dart';

class DesignerDetailScreen extends StatelessWidget {
  final dynamic designer;

  const DesignerDetailScreen({super.key, required this.designer});

  String getValue(String key, String defaultValue) {
    final value = designer[key];

    if (value == null || value.toString().trim().isEmpty) {
      return defaultValue;
    }

    return value.toString();
  }

  String getImage() {
    final image = designer['image'];

    if (image != null && image.toString().trim().isNotEmpty) {
      return image.toString();
    }

    return 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1200';
  }

  String getRating() {
    return getValue('rating', '4.8');
  }

  String getExperience() {
    return getValue('experience', '5+ Years');
  }

  String getProjects() {
    return getValue('projects', '50+');
  }

  String getPrice() {
    return getValue('price', '₹25,000+');
  }

  String getAbout() {
    return getValue(
      'about',
      'Professional interior designer specializing in beautiful, functional and modern interior spaces. Our goal is to transform your ideas into a comfortable and stylish space that matches your lifestyle.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = getValue('name', 'Interior Designer');

    final specialty = getValue('specialty', 'Interior Design');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: CustomScrollView(
        slivers: [
          // ============================================================
          // TOP IMAGE
          // ============================================================
          SliverAppBar(
            expandedHeight: 390,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF6A11CB),

            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.30),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 55,
                bottom: 16,
                right: 20,
              ),

              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),

              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    getImage(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),

                  // DARK GRADIENT
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black26,
                          Colors.black87,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.25, 0.60, 1.0],
                      ),
                    ),
                  ),

                  // VERIFIED BADGE
                  Positioned(
                    top: 100,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF2575FC),
                            size: 19,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2575FC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // NAME + SPECIALTY
                  // ======================================================
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202124),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.design_services_rounded,
                        color: Color(0xFF6A11CB),
                        size: 20,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          specialty,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ======================================================
                  // RATING
                  // ======================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 21,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                getRating(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          'Highly Rated Designer',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ======================================================
                  // STATS
                  // ======================================================
                  const Text(
                    'Designer Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.workspace_premium_rounded,
                          value: getExperience(),
                          label: 'Experience',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.home_work_rounded,
                          value: getProjects(),
                          label: 'Projects',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.currency_rupee_rounded,
                          value: getPrice(),
                          label: 'Starting',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ======================================================
                  // ABOUT
                  // ======================================================
                  const Text(
                    'About Designer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 11),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      getAbout(),
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ======================================================
                  // SERVICES
                  // ======================================================
                  const Text(
                    'Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      _buildServiceChip(
                        Icons.palette_outlined,
                        'Interior Design',
                      ),
                      _buildServiceChip(Icons.home_outlined, 'Home Interiors'),
                      _buildServiceChip(
                        Icons.business_outlined,
                        'Office Design',
                      ),
                      _buildServiceChip(
                        Icons.lightbulb_outline_rounded,
                        'Space Planning',
                      ),
                      _buildServiceChip(
                        Icons.format_paint_outlined,
                        'Decor & Styling',
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ======================================================
                  // WHY CHOOSE
                  // ======================================================
                  const Text(
                    'Why Choose This Designer?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  _buildFeature(
                    Icons.verified_rounded,
                    'Verified Professional',
                    'Work with a trusted interior design professional.',
                  ),

                  _buildFeature(
                    Icons.design_services_rounded,
                    'Creative Designs',
                    'Beautiful designs tailored to your requirements.',
                  ),

                  _buildFeature(
                    Icons.schedule_rounded,
                    'Flexible Consultation',
                    'Choose a convenient date and time for consultation.',
                  ),

                  _buildFeature(
                    Icons.thumb_up_alt_rounded,
                    'Customer Focused',
                    'Your requirements and satisfaction come first.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================================================================
      // BOOK BUTTON
      // ================================================================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            height: 57,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(designer: designer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor: const Color(0xFF6A11CB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_rounded, size: 23),
                  SizedBox(width: 9),
                  Text(
                    'BOOK CONSULTATION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // STAT CARD
  // ====================================================================

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6A11CB), size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // SERVICE CHIP
  // ====================================================================

  Widget _buildServiceChip(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6A11CB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF6A11CB).withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 1),
          Icon(icon, size: 18, color: const Color(0xFF6A11CB)),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF5B0EAD),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // FEATURE
  // ====================================================================

  Widget _buildFeature(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB).withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF6A11CB), size: 23),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
