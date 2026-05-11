import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize();
  runApp(const MindCareApp());
}

// --- MODELS ---
class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
}

// --- DESIGN SYSTEM: COLORS ---
class AppColors {
  static const sage50 = Color(0xFFF4F7F6);
  static const sage100 = Color(0xFFE8F0EC);
  static const sage200 = Color(0xFFD1E1D9);
  static const sage300 = Color(0xFFA9C5B8);
  static const sage400 = Color(0xFF7CA492);
  static const sage500 = Color(0xFF5A8673);
  static const sage600 = Color(0xFF436A5A);
  static const sage700 = Color(0xFF365548);
  static const sage800 = Color(0xFF2D453B);

  static const sunlight50 = Color(0xFFFFFDF5);
  static const sunlight100 = Color(0xFFFFF9E5);
  static const sunlight200 = Color(0xFFFFEBB8);
  static const sunlight500 = Color(0xFFFFC83D);

  static const blush50 = Color(0xFFFEF6F6);
  static const blush100 = Color(0xFFFDEAE9);
  static const blush600 = Color(0xFFC85C5C);

  static const peach50 = Color(0xFFFFF9F8);
  static const peach100 = Color(0xFFFFEDEA);
  static const peach500 = Color(0xFFFF8E7A);
}

// --- DESIGN SYSTEM: TYPOGRAPHY ---
class AppStyles {
  static const TextStyle serifHeading = TextStyle(
    fontFamily: 'Georgia',
    fontWeight: FontWeight.w600,
    color: AppColors.sage800,
    letterSpacing: -0.5,
  );

  static const TextStyle sansBody = TextStyle(
    fontFamily: 'Segoe UI',
    fontWeight: FontWeight.w400,
    color: AppColors.sage600,
  );
}

// --- APP ENTRY ---
class MindCareApp extends StatelessWidget {
  const MindCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.sunlight50,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.sage600),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(AppColors.sage200),
          thickness: MaterialStateProperty.all(6),
          radius: const Radius.circular(10),
        ),
      ),
      home: const RootController(),
    );
  }
}

// --- ROOT CONTROLLER ---
class RootController extends StatefulWidget {
  const RootController({Key? key}) : super(key: key);

  @override
  State<RootController> createState() => _RootControllerState();
}

class _RootControllerState extends State<RootController> {
  User? _user;
  String _currentView = 'home';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final age = prefs.getInt('user_age');
    if (name != null && age != null) {
      setState(() {
        _user = User(name: name, age: age);
      });
    }
    setState(() => _isLoading = false);
  }

  void _login(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name);
    await prefs.setInt('user_age', user.age);
    setState(() {
      _user = user;
      _currentView = 'home';
    });
  }

  void _setView(String view) {
    setState(() => _currentView = view);
  }

  void _showHelpline() {
    showDialog(context: context, builder: (context) => const HelplineModal());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.sunlight50,
        body: Center(child: CircularProgressIndicator(color: AppColors.sage600)),
      );
    }

    if (_user == null) {
      return LoginScreen(onLogin: _login);
    }

    return Scaffold(
      backgroundColor: AppColors.sunlight50,
      body: Stack(
        children: [
          // Ambient Background Blobs
          Positioned(
            top: -150,
            left: 200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sunlight100.withOpacity(0.6),
              ),
            ).blurred(sigma: 80),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.peach50.withOpacity(0.8),
              ),
            ).blurred(sigma: 100),
          ),

          Row(
            children: [
              DesktopSidebar(
                currentView: _currentView,
                onViewSelected: _setView,
                onEmergencyTap: _showHelpline,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        bottomLeft: Radius.circular(32),
                      ),
                      child: Container(
                        color: Colors.transparent,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildMainContent(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentView) {
      case 'home':
        return HomeScreen(user: _user!, onViewSelected: _setView);
      case 'diary':
        return const DiaryScreen();
      case 'insights':
        return const InsightsScreen();
      case 'screening':
        return ScreeningScreen(user: _user!);
      case 'chat':
        return const ChatScreen();
      case 'profile':
        return ProfileScreen(user: _user!);
      default:
        return HomeScreen(user: _user!, onViewSelected: _setView);
    }
  }
}

// --- DESKTOP SIDEBAR ---
class DesktopSidebar extends StatelessWidget {
  final String currentView;
  final Function(String) onViewSelected;
  final VoidCallback onEmergencyTap;

  const DesktopSidebar({
    Key? key,
    required this.currentView,
    required this.onViewSelected,
    required this.onEmergencyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white.withOpacity(0.6),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.sunlight100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.air, color: AppColors.sage600),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Nav Items
          _NavItem(
            icon: Icons.auto_awesome,
            label: 'Home',
            id: 'home',
            currentView: currentView,
            onTap: onViewSelected,
          ),
          _NavItem(
            icon: Icons.menu_book,
            label: 'Diary',
            id: 'diary',
            currentView: currentView,
            onTap: onViewSelected,
          ),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'Insights',
            id: 'insights',
            currentView: currentView,
            onTap: onViewSelected,
          ),
          _NavItem(
            icon: Icons.assignment,
            label: 'Screening',
            id: 'screening',
            currentView: currentView,
            onTap: onViewSelected,
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Guide',
            id: 'chat',
            currentView: currentView,
            onTap: onViewSelected,
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            id: 'profile',
            currentView: currentView,
            onTap: onViewSelected,
          ),

          const Spacer(),

          // Emergency Help Button
          InkWell(
            onTap: onEmergencyTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.peach50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.peach100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: AppColors.blush600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Emergency Help',
                    style: AppStyles.sansBody.copyWith(
                      color: AppColors.blush600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String id;
  final String currentView;
  final Function(String) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.id,
    required this.currentView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentView == id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onTap(id),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 24 : 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.sage600 : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.sage600.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.sage500,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: AppStyles.sansBody.copyWith(
                  color: isActive ? Colors.white : AppColors.sage500,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- UTILS & COMPONENTS ---

extension BlurExtension on Widget {
  Widget blurred({double sigma = 10}) {
    return ImageFilterWidget(sigma: sigma, child: this);
  }
}

class ImageFilterWidget extends StatelessWidget {
  final double sigma;
  final Widget child;
  const ImageFilterWidget({Key? key, required this.sigma, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }
}

class OrganicCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool isGlassy;

  const OrganicCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.onTap,
    this.padding = const EdgeInsets.all(24.0),
    this.isGlassy = true,
  }) : super(key: key);

  @override
  State<OrganicCard> createState() => _OrganicCardState();
}

class _OrganicCardState extends State<OrganicCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(
            0,
            _isHovered && widget.onTap != null ? -4 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ??
                (widget.isGlassy
                    ? Colors.white.withOpacity(0.85)
                    : Colors.white),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sage600.withOpacity(_isHovered ? 0.12 : 0.06),
                blurRadius: _isHovered ? 40 : 20,
                offset: Offset(0, _isHovered ? 15 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: widget.isGlassy && widget.backgroundColor == null
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  )
                : Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

// --- MODALS ---
class HelplineModal extends StatelessWidget {
  const HelplineModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.sage800.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.blush100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.phone, color: AppColors.blush600),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.sage400),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.sunlight50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'You are not alone',
              style: AppStyles.serifHeading.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              'Free, confidential support is available 24/7. Please reach out.',
              style: AppStyles.sansBody.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 32),

            _buildContactCard(
              'Crisis Lifeline',
              'Call or text 988',
              Icons.chevron_right,
              AppColors.peach50,
              AppColors.peach100,
              AppColors.blush600,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              'Crisis Text Line',
              'Text HOME to 741741',
              Icons.chat_bubble,
              AppColors.sunlight50,
              AppColors.sunlight100,
              AppColors.sage600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    String title,
    String subtitle,
    IconData icon,
    Color bg,
    Color border,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.sansBody.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.sage800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppStyles.sansBody.copyWith(color: accent, fontSize: 14),
              ),
            ],
          ),
          Icon(icon, color: accent),
        ],
      ),
    );
  }
}

// --- SCREENS (except ChatScreen, which is replaced with AI version below) ---

class LoginScreen extends StatefulWidget {
  final Function(User) onLogin;
  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: "Amiy",
  );
  final TextEditingController _ageController = TextEditingController(
    text: "32",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sunlight50,
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                color: AppColors.sunlight200,
                shape: BoxShape.circle,
              ),
            ).blurred(sigma: 100),
          ),
          Positioned(
            bottom: 100,
            right: 100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: AppColors.peach100,
                shape: BoxShape.circle,
              ),
            ).blurred(sigma: 80),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sage600.withOpacity(0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.air,
                      size: 48,
                      color: AppColors.sage600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'MindCare',
                    style: AppStyles.serifHeading.copyWith(fontSize: 56),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A gentle, responsive space for your mind.\nAccessible everywhere.',
                    textAlign: TextAlign.center,
                    style: AppStyles.sansBody.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 48),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: OrganicCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Welcome',
                            style: AppStyles.serifHeading.copyWith(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _nameController,
                            style: AppStyles.sansBody,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: AppStyles.sansBody.copyWith(
                                color: AppColors.sage400,
                              ),
                              filled: true,
                              fillColor: AppColors.sage50.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.sage400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            style: AppStyles.sansBody,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              labelStyle: AppStyles.sansBody.copyWith(
                                color: AppColors.sage400,
                              ),
                              filled: true,
                              fillColor: AppColors.sage50.withOpacity(0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.cake_outlined,
                                color: AppColors.sage400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {
                              final name = _nameController.text;
                              final age =
                                  int.tryParse(_ageController.text) ?? 0;
                              if (name.isNotEmpty) {
                                widget.onLogin(User(name: name, age: age));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sage600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              minimumSize: const Size(double.infinity, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Enter Sanctuary',
                              style: AppStyles.sansBody.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
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
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User user;
  final Function(String) onViewSelected;
  const HomeScreen({Key? key, required this.user, required this.onViewSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(48.0),
      children: [
        Row(
          children: [
            const Icon(Icons.wb_sunny, color: AppColors.sunlight500, size: 20),
            const SizedBox(width: 8),
            Text(
              'Good morning, ${user.name}',
              style: AppStyles.sansBody.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'How is your heart feeling today?',
          style: AppStyles.serifHeading.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 48),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Focus
            Expanded(
              flex: 2,
              child: OrganicCard(
                backgroundColor: AppColors.sage600,
                padding: const EdgeInsets.all(32),
                onTap: () => onViewSelected('diary'),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DAILY ROUTINE',
                            style: AppStyles.sansBody.copyWith(
                              color: AppColors.sunlight100,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Morning Reflection',
                            style: AppStyles.serifHeading.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Take 3 minutes to clear your mind and ground yourself before the day begins.',
                            style: AppStyles.sansBody.copyWith(
                              color: AppColors.sage50.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Secondary Actions
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  OrganicCard(
                    onTap: () => onViewSelected('screening'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.peach50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.assignment,
                            color: AppColors.peach500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Wellness Check',
                          style: AppStyles.serifHeading.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periodic emotional screening',
                          style: AppStyles.sansBody.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OrganicCard(
                    onTap: () => onViewSelected('chat'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.sunlight100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.chat_bubble,
                            color: AppColors.sunlight500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mindful Guide',
                          style: AppStyles.serifHeading.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chat securely anytime',
                          style: AppStyles.sansBody.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Tertiary Action
        OrganicCard(
          onTap: () => onViewSelected('insights'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Insights',
                    style: AppStyles.serifHeading.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View your emotional growth and mood patterns over time.',
                    style: AppStyles.sansBody,
                  ),
                ],
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.sage50),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.sage600,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  double _moodValue = 50;
  final TextEditingController _noteController = TextEditingController();

  Map<String, dynamic> get _moodState {
    if (_moodValue < 20)
      return {
        "emoji": "🌧️",
        "label": "Depleted",
        "scale": 0.8,
        "bg": AppColors.sage100,
      };
    if (_moodValue < 45)
      return {
        "emoji": "☁️",
        "label": "Tired",
        "scale": 0.9,
        "bg": AppColors.sage50,
      };
    if (_moodValue < 65)
      return {
        "emoji": "🌤️",
        "label": "Okay",
        "scale": 1.0,
        "bg": Colors.white,
      };
    if (_moodValue < 85)
      return {
        "emoji": "☀️",
        "label": "Good",
        "scale": 1.1,
        "bg": AppColors.sunlight50,
      };
    return {
      "emoji": "✨",
      "label": "Radiant",
      "scale": 1.2,
      "bg": AppColors.sunlight100,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = _moodState;
    return ListView(
      padding: const EdgeInsets.all(48.0),
      children: [
        Text(
          'Reflection',
          style: AppStyles.serifHeading.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 32),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: (state["bg"] as Color).withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.sage600.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              AnimatedScale(
                scale: state["scale"] as double,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Text(
                  state["emoji"] as String,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ENERGY LEVEL',
                style: AppStyles.sansBody.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.sage400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state["label"] as String,
                style: AppStyles.serifHeading.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 48),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Colors.white,
                  trackHeight: 14.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 18.0,
                    elevation: 4,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 28.0,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.sage200,
                        AppColors.sunlight200,
                        AppColors.peach100,
                      ],
                    ),
                  ),
                  child: Slider(
                    value: _moodValue,
                    min: 0,
                    max: 100,
                    onChanged: (val) => setState(() => _moodValue = val),
                  ),
                ),
              ),

              const SizedBox(height: 48),
              TextField(
                controller: _noteController,
                maxLines: 6,
                style: AppStyles.serifHeading.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText:
                      "Let your thoughts flow freely here. What's on your mind today?",
                  hintStyle: AppStyles.serifHeading.copyWith(
                    color: AppColors.sage300,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Past Entries',
          style: AppStyles.serifHeading.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 16),
        OrganicCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YESTERDAY',
                style: AppStyles.sansBody.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.sage400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The park was quiet today. I felt a sense of stillness I haven\'t felt in weeks. Watched the leaves move. It was exactly what I needed after the heavy work calls.',
                style: AppStyles.sansBody.copyWith(
                  fontSize: 16,
                  color: AppColors.sage700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScreeningScreen extends StatefulWidget {
  final User user;
  const ScreeningScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  final List<Map<String, String>> questions = [
    {'id': 'sad', 'label': 'Feeling sad or tearful'},
    {'id': 'irritable', 'label': 'Irritable towards baby & partner'},
    {'id': 'sleep', 'label': 'Trouble sleeping at night'},
    {
      'id': 'concentration',
      'label': 'Problems concentrating or making decisions',
    },
    {'id': 'appetite', 'label': 'Overeating or loss of appetite'},
    {'id': 'guilt', 'label': 'Feeling of guilt'},
    {'id': 'bonding', 'label': 'Problems of bonding with baby'},
    {'id': 'suicide', 'label': 'Suicide attempt'},
  ];

  Map<String, int> responses = {};
  Map<String, dynamic>? result;
  String errorMsg = '';

  void _computeScore() {
    setState(() {
      errorMsg = '';
      if (responses.length < questions.length) {
        errorMsg = 'Please gently answer all questions to get a clear result.';
        return;
      }

      int total = responses.values.fold(0, (sum, val) => sum + val);
      String severity = '';
      String category = '';

      if (total <= 4) {
        severity = 'No immediate concern';
        category = 'no-depression';
      } else if (total <= 10) {
        severity = 'Moderate Concern';
        category = 'moderate';
      } else {
        severity = 'Elevated Concern';
        category = 'severe';
      }

      bool hasDepression = total >= 5;
      bool suicideRisk = (responses['suicide'] ?? 0) >= 1;

      result = {
        'total': total,
        'severity': severity,
        'hasDepression': hasDepression,
        'category': category,
        'suicideRisk': suicideRisk,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(48.0),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.peach50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.assignment, color: AppColors.peach500),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Check',
                  style: AppStyles.serifHeading.copyWith(fontSize: 32),
                ),
                Text(
                  'Confidential screening – your answers are private & gentle',
                  style: AppStyles.sansBody,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        OrganicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.sunlight50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sunlight100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.security,
                      color: AppColors.sunlight500,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'This is based on standard assessment patterns. Your age (${widget.user.age}) is securely linked to this check-in. Please answer honestly; there is no judgment here.',
                        style: AppStyles.sansBody.copyWith(
                          color: AppColors.sage700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              ...questions.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, String> q = entry.value;
                return _buildQuestionRow('${idx + 1}. ${q['label']}', q['id']!);
              }).toList(),

              if (errorMsg.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.peach50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.peach100),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.blush600,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        errorMsg,
                        style: AppStyles.sansBody.copyWith(
                          color: AppColors.blush600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _computeScore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Complete Check-in',
                    style: AppStyles.sansBody.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (result != null) _buildResultCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionRow(String question, String id) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppStyles.serifHeading.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRadioOption('No (0)', 0, id),
              const SizedBox(width: 16),
              _buildRadioOption('Maybe (1)', 1, id),
              const SizedBox(width: 16),
              _buildRadioOption('Yes (2)', 2, id),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.sage50, height: 1),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, int value, String qId) {
    bool isSelected = responses[qId] == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => responses[qId] = value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sage600 : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.sage600 : AppColors.sage100,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.sage600.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppStyles.sansBody.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.sage700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    Color bgColor = AppColors.sage50;
    Color borderColor = AppColors.sage100;
    if (result!['category'] == 'severe') {
      bgColor = AppColors.peach50;
      borderColor = AppColors.peach100;
    } else if (result!['category'] == 'moderate') {
      bgColor = AppColors.sunlight50;
      borderColor = AppColors.sunlight100;
    }

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.favorite,
                  color: result!['hasDepression']
                      ? AppColors.blush600
                      : AppColors.sage600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                result!['severity'],
                style: AppStyles.serifHeading.copyWith(fontSize: 28),
              ),
            ],
          ),
          if (result!['suicideRisk'])
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.blush100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.blush600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'If you’re having thoughts of self-harm, please contact emergency services immediately. You deserve care right now.',
                      style: AppStyles.sansBody.copyWith(
                        color: AppColors.blush600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            !result!['hasDepression']
                ? "Your responses suggest you are navigating this season with resilience. Remember to continue practicing self-compassion and taking moments for yourself."
                : "These feelings are real, valid, and highly treatable. You are not alone in this journey. We strongly recommend sharing these results with your healthcare provider.",
            style: AppStyles.sansBody.copyWith(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> weeklyData = [
      {'day': 'Mon', 'val': 40},
      {'day': 'Tue', 'val': 55},
      {'day': 'Wed', 'val': 50},
      {'day': 'Thu', 'val': 75},
      {'day': 'Fri', 'val': 85},
      {'day': 'Sat', 'val': 90},
      {'day': 'Sun', 'val': 80},
    ];
    final List<String> themes = [
      "Nature",
      "Work Stress",
      "Gratitude",
      "Restless",
      "Postpartum adjustment",
    ];

    return ListView(
      padding: const EdgeInsets.all(48.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: AppStyles.serifHeading.copyWith(fontSize: 40),
                ),
                Text(
                  'Understanding your emotional landscape.',
                  style: AppStyles.sansBody.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sage50),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppColors.sage600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last 7 Days',
                    style: AppStyles.sansBody.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: OrganicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Energy & Mood Flow',
                      style: AppStyles.serifHeading.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 250,
                      child: Stack(
                        children: [
                          // Grid lines
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              4,
                              (index) =>
                                  const Divider(color: AppColors.sage100),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: weeklyData.map((data) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: data['val'] / 100.0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: AppColors.sage400,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(12),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        data['day'],
                                        style: AppStyles.sansBody.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  OrganicCard(
                    backgroundColor: AppColors.sage600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: AppColors.sunlight200,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Observation',
                              style: AppStyles.serifHeading.copyWith(
                                color: AppColors.sunlight50,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You consistently report higher energy and better mood on days where you complete your "Step outside" intention. Consider making it a non-negotiable daily habit.',
                          style: AppStyles.sansBody.copyWith(
                            color: AppColors.sage50.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OrganicCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recurring Themes',
                          style: AppStyles.serifHeading.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: themes
                              .map(
                                (theme) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sunlight50,
                                    border: Border.all(
                                      color: AppColors.sunlight100,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    theme,
                                    style: AppStyles.sansBody.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> tasks = [
    {'id': 1, 'text': 'Morning meditation (5 min)', 'completed': true},
    {'id': 2, 'text': 'Drink a glass of water', 'completed': true},
    {'id': 3, 'text': 'Step outside for fresh air', 'completed': false},
    {
      'id': 4,
      'text': 'Jot down one thing you are grateful for',
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(48.0),
      children: [
        OrganicCard(
          padding: const EdgeInsets.all(32),
          child: Row(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.sunlight100,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.sunlight500,
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.user.name}, ${widget.user.age}',
                      style: AppStyles.serifHeading.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Joined May 2025',
                      style: AppStyles.sansBody.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit, color: AppColors.sage600),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.sage50,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gentle Intentions',
                    style: AppStyles.serifHeading.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  OrganicCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: tasks
                          .map(
                            (t) => InkWell(
                              onTap: () => setState(
                                () => t['completed'] = !t['completed'],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: AppColors.sage50),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: t['completed']
                                            ? AppColors.sage500
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: t['completed']
                                              ? AppColors.sage500
                                              : AppColors.sage200,
                                          width: 2,
                                        ),
                                      ),
                                      child: t['completed']
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      t['text'],
                                      style: AppStyles.sansBody.copyWith(
                                        fontSize: 16,
                                        color: t['completed']
                                            ? AppColors.sage300
                                            : AppColors.sage700,
                                        decoration: t['completed']
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wellness Journey',
                    style: AppStyles.serifHeading.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  OrganicCard(
                    child: Column(
                      children: [
                        _buildJourneyItem(
                          'Therapy Session',
                          'Dr. Emily Chen',
                          'May 12',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: AppColors.sage50),
                        ),
                        _buildJourneyItem(
                          'Anxiety Check-in',
                          'Self-guided module',
                          'Apr 28',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJourneyItem(String title, String subtitle, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.sansBody.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.sage800,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppStyles.sansBody.copyWith(fontSize: 14)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.sunlight50,
            border: Border.all(color: AppColors.sunlight100),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            date,
            style: AppStyles.sansBody.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.sage700,
            ),
          ),
        ),
      ],
    );
  }
}

// ======================
// AI-POWERED CHAT SCREEN (using FlutterGemma)
// ======================

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text:
          "Welcome to your safe space. I'm here to listen without judgment. How are things feeling right now?",
      isUser: false,
    ),
  ];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isInitializing = true;
  bool _isGenerating = false;
  String _initStatus = 'Waking up the Mindful Guide...';
  double _downloadProgress = 0.0;
  String _currentThought = '';
  String _currentResponse = '';

  late dynamic _model;
  late dynamic _chat;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      const url =
          'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/main/Qwen3-0.6B.litertlm';

      setState(() {
        _initStatus = 'Verifying local model...';
      });

      await FlutterGemma.installModel(
        modelType: ModelType.qwen3,
      ).fromNetwork(url).withProgress((p) {
        if (p < 100) {
          setState(() {
            _downloadProgress = p / 100;
            _initStatus = 'Installing Mindful Brain: $p%';
          });
        }
      }).install();

      setState(() {
        _initStatus = 'Loading model into memory...';
        _downloadProgress = 0.0;
      });

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 2048,
        preferredBackend: PreferredBackend.gpu,
      );

      _chat = await _model.createChat(
        systemInstruction:
            'You are a calm, empathetic, and supportive mental health companion named "Mindful Guide". '
            'Your responses should be gentle, non-judgmental, and focused on emotional well-being. '
            'Use warm, soothing language. Never give medical advice; instead, encourage professional help when needed. '
            'Always respond in the same language the user uses.',
      );

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _initStatus = 'Initialization Error: $e';
        _isInitializing = false;
        _messages.add(
          ChatMessage(
            text:
                "I'm having trouble connecting right now. Please try again later.",
            isUser: false,
          ),
        );
      });
    }
  }

  Future<void> _sendMessage(String userText) async {
    if (userText.trim().isEmpty || _isGenerating || _isInitializing) return;

    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _currentThought = '';
      _currentResponse = '';
      _isGenerating = true;
    });
    _scrollToBottom();
    _textController.clear();

    try {
      await _chat.addQueryChunk(Message.text(text: userText, isUser: true));

      _chat.generateChatResponseAsync().listen(
        (response) {
          setState(() {
            if (response is ThinkingResponse) {
              _currentThought += response.content;
            } else if (response is TextResponse) {
              _currentResponse += response.token;
            }
          });
          _scrollToBottom();
        },
        onDone: () {
          setState(() {
            _messages.add(
              ChatMessage(
                text: _currentResponse,
                isUser: false,
                thoughtProcess: _currentThought.isNotEmpty
                    ? _currentThought
                    : null,
              ),
            );
            _currentThought = '';
            _currentResponse = '';
            _isGenerating = false;
          });
          _scrollToBottom();
        },
        onError: (e) {
          setState(() {
            _messages.add(
              ChatMessage(
                text: "I'm having trouble responding. Please try again.",
                isUser: false,
              ),
            );
            _isGenerating = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Something went wrong. Please try again.",
            isUser: false,
          ),
        );
        _isGenerating = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _model?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      "I feel overwhelmed",
      "Need a breathing exercise",
      "Just wanted to vent",
    ];

    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.sage600),
            const SizedBox(height: 24),
            Text(
              _initStatus,
              style: AppStyles.sansBody.copyWith(fontWeight: FontWeight.w500),
            ),
            if (_downloadProgress > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: AppColors.sage100,
                  color: AppColors.sage600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: const Border(bottom: BorderSide(color: AppColors.sage50)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.sunlight100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.air, color: AppColors.sage700),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mindful Guide',
                    style: AppStyles.serifHeading.copyWith(fontSize: 24),
                  ),
                  Text(
                    'Secure & private companion',
                    style: AppStyles.sansBody.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(48),
            itemCount: _messages.length + (_isGenerating ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildActiveGeneration();
              }
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.sunlight50,
                AppColors.sunlight50.withOpacity(0),
              ],
            ),
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                children: chips
                    .map(
                      (chip) => ActionChip(
                        label: Text(chip),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.sage100),
                        labelStyle: AppStyles.sansBody.copyWith(
                          color: AppColors.sage600,
                        ),
                        onPressed: () => _sendMessage(chip),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 8,
                  top: 8,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.sage100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sage600.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _sendMessage(_textController.text),
                        decoration: const InputDecoration(
                          hintText: "Type your thoughts...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.sage300),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isGenerating
                          ? null
                          : () => _sendMessage(_textController.text),
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.sage600,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveGeneration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentThought.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8, left: 16, right: 64),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "Gently reflecting...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentThought,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        if (_currentResponse.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, right: 64),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  16,
                ).copyWith(topLeft: const Radius.circular(4)),
                border: Border.all(color: AppColors.sage50),
              ),
              child: Text(
                _currentResponse,
                style: AppStyles.sansBody.copyWith(
                  color: AppColors.sage800,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!message.isUser && message.thoughtProcess != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8, left: 16, right: 64),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Row(
                    children: [
                      Icon(Icons.psychology, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Inner reflection",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  children: [
                    Text(
                      message.thoughtProcess!,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          Container(
            margin: EdgeInsets.only(
              bottom: 16,
              left: message.isUser ? 64 : 0,
              right: message.isUser ? 0 : 64,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: message.isUser ? AppColors.sage600 : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: message.isUser
                    ? const Radius.circular(24)
                    : const Radius.circular(4),
                bottomRight: message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(24),
              ),
              border: message.isUser
                  ? null
                  : Border.all(color: AppColors.sage50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              message.text,
              style: AppStyles.sansBody.copyWith(
                color: message.isUser ? Colors.white : AppColors.sage800,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? thoughtProcess;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.thoughtProcess,
  });
}
