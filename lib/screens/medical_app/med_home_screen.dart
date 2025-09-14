import 'dart:ui';
import 'package:flutter/material.dart';
import '../../widgets/custom_drawer.dart';
import 'custom_header_drwaer.dart';

class MedHomeScreen extends StatefulWidget {
  const MedHomeScreen({super.key});

  @override
  State<MedHomeScreen> createState() => _MedHomeScreenState();
}

class _MedHomeScreenState extends State<MedHomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0; // State variable for the selected index
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeIn)
    );
    _glowController.repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Mock data for UI elements
  final List<Map<String, dynamic>> categories = [
    {'name': 'Painkillers', 'icon': Icons.local_hospital},
    {'name': 'Vitamins', 'icon': Icons.medical_services},
    {'name': 'Cold & Flu', 'icon': Icons.ac_unit},
    {'name': 'Skin Care', 'icon': Icons.spa},
    {'name': 'First Aid', 'icon': Icons.health_and_safety},
    {'name': 'Supplements', 'icon': Icons.fitness_center},
  ];

  final List<Map<String, dynamic>> popularMedicines = [
    {'name': 'Paracetamol', 'brand': 'Brand A', 'price': '\$5.99', 'imageUrl': 'https://placehold.co/200x150/1e90ff/ffffff?text=Pill'},
    {'name': 'Vitamin C', 'brand': 'Brand B', 'price': '\$12.50', 'imageUrl': 'https://placehold.co/200x150/ff4500/ffffff?text=Capsule'},
    {'name': 'Ibuprofen', 'brand': 'Brand C', 'price': '\$7.25', 'imageUrl': 'https://placehold.co/200x150/32cd32/ffffff?text=Tablets'},
    {'name': 'Cough Syrup', 'brand': 'Brand D', 'price': '\$9.80', 'imageUrl': 'https://placehold.co/200x150/8a2be2/ffffff?text=Liquid'},
  ];

  final List<Map<String, dynamic>> nearbyPharmacies = [
    {'name': 'City Pharmacy', 'distance': '0.5 mi'},
    {'name': 'Wellness Drug', 'distance': '1.2 mi'},
    {'name': 'Quick Meds', 'distance': '0.8 mi'},
  ];

  // A custom reusable widget for the frosted glass effect with an added glow
  Widget _glassmorphicContainer({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  // Categories Carousel
  Widget _buildCategories() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                _glassmorphicContainer(
                  child: Icon(category['icon'] as IconData, size: 40, color: Theme.of(context).colorScheme.primary),
                  padding: const EdgeInsets.all(20),
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Popular Medicines / Offers
  Widget _buildPopularMedicines() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularMedicines.length,
        itemBuilder: (context, index) {
          final medicine = popularMedicines[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _glassmorphicContainer(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medicine Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        medicine['imageUrl'] as String,
                        height: 90,
                        width: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 90,
                            color: Colors.white.withOpacity(0.05),
                            child: const Center(
                              child: Icon(Icons.medication, size: 40, color: Colors.white38),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Text details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            medicine['brand'] as String,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8), // Added some spacing
                    // Price
                    Text(
                      medicine['price'] as String,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.1),
              elevation: 0,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              title: const Text(
                'InstantMed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const MedCustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100), // Spacing for the custom app bar
            // Search Bar with glowing effect
            _glassmorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search medicines...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            // Categories
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCategories(),
            const SizedBox(height: 24),
            // Popular Medicines
            const Text(
              'Popular Medicines',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPopularMedicines(),
            const SizedBox(height: 24),
            // Nearby Pharmacies
            const Text(
              'Nearby Pharmacies',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nearbyPharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = nearbyPharmacies[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _glassmorphicContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.local_pharmacy, size: 40, color: Theme.of(context).colorScheme.secondary),
                          const SizedBox(height: 8),
                          Text(
                            pharmacy['name'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${pharmacy['distance']}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Custom futuristic bottom navigation bar
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 90,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0d1117), Color(0xFF0d1117)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: CustomClipperWidget(),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          center: Alignment.topCenter,
                          radius: 1.0,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navBarItem(0, Icons.home_outlined, Icons.home),
                      _navBarItem(1, Icons.dashboard_outlined, Icons.dashboard),
                      const SizedBox(width: 80),
                      _navBarItem(2, Icons.receipt_outlined, Icons.receipt),
                      _navBarItem(3, Icons.person_outline, Icons.person),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: MediaQuery.of(context).size.width / 2 - 35,
                  child: AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(_glowAnimation.value * 0.8),
                              Theme.of(context).colorScheme.primary,
                            ],
                            center: Alignment.center,
                            radius: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 20 * _glowAnimation.value,
                              spreadRadius: 5 * _glowAnimation.value,
                            )
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 30),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for bottom navigation bar items
  Widget _navBarItem(int index, IconData icon, IconData activeIcon) {
    bool isActive = index == _selectedIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Theme.of(context).colorScheme.primary : Colors.white54,
            size: isActive ? 30 : 25,
          ),
          Text(
            isActive ? _getLabel(index) : '',
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  String _getLabel(int index) {
    switch(index) {
      case 0: return 'Home';
      case 1: return 'Categories';
      case 2: return 'Cart';
      case 3: return 'Orders';
      case 4: return 'Profile';
      default: return '';
    }
  }

  // Custom Drawer Widget
  Widget _buildCustomDrawer() {
    return  MedCustomDrawer();
  }
}

class CustomClipperWidget extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: const Radius.circular(20), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
