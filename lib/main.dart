import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

// BRANDCOLORS_001_INITIAL: Official color palette for Amar Pathshala
class BrandColors {
  static const Color darkTeal = Color(0xFF00332E);
  static const Color teal = Color(0xFF004D40);
  static const Color lightTeal = Color(0xFF4DB6AC);
  static const Color veryLightTeal = Color(0xFFB2DFDB);
  static const Color veryDarkGray = Color(0xFF1E1E1E);
  static const Color darkGray = Color(0xFF2E2E2E);
  static const Color mediumGray = Color(0xFF424242);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);
}

// MAIN_001_INITIAL: Entry point with Flutter bindings for async operations
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AmarPathshalaApp());
}

// APP_001_INITIAL: Root widget for the Amar Pathshala app
class AmarPathshalaApp extends StatelessWidget {
  const AmarPathshalaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amar Pathshala',
      theme: ThemeData.dark().copyWith(
        primaryColor: BrandColors.darkTeal,
        scaffoldBackgroundColor: BrandColors.veryDarkGray,
        cardColor: BrandColors.darkGray,
        buttonTheme: ButtonThemeData(
          buttonColor: BrandColors.lightTeal,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/subjects': (context) => const SubjectsScreen(),
        '/lesson': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final subject = args is String ? args : 'Unknown Subject';
          return LessonScreen(subject: subject);
        },
        '/buddies': (context) => const BuddiesScreen(),
        '/games': (context) => const GamesScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/marketplace': (context) => const MarketplaceScreen(),
        '/studyroom': (context) => const StudyRoomScreen(),
        '/challenges':
            (context) => const PlaceholderScreen(title: 'Challenges'),
        '/bookmarks': (context) => const PlaceholderScreen(title: 'Bookmarks'),
        '/ai-tutor': (context) => const PlaceholderScreen(title: 'AI Tutor'),
        '/connect': (context) => const PlaceholderScreen(title: 'Connect'),
        '/play': (context) => const PlaceholderScreen(title: 'Play'),
        '/talk': (context) => const PlaceholderScreen(title: 'Talk'),
        '/gift-shop': (context) => const PlaceholderScreen(title: 'Gift Shop'),
        '/dashboard': (context) => const PlaceholderScreen(title: 'Dashboard'),
        '/profile': (context) => const PlaceholderScreen(title: 'Profile'),
        '/notifications':
            (context) => const PlaceholderScreen(title: 'Notifications'),
      },
    );
  }
}

// USERSTATE_001_INITIAL: Singleton class to manage user state and persistence
class UserState {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;

  int points = 50;
  String tier = 'Explorer';
  List<Map<String, dynamic>> buddies = [
    {
      'name': 'Amina',
      'interests': 'Physics, 21st Century Skills',
      'points': 300,
      'status': 'Online',
    },
    {
      'name': 'Rahim',
      'interests': 'Entrepreneurial Thinking, Civic Responsibilities',
      'points': 450,
      'status': 'Offline',
    },
    {
      'name': 'Fatima',
      'interests': 'Physics, Digital Literacy',
      'points': 200,
      'status': 'Online',
    },
    {
      'name': 'Nurul',
      'interests': 'Civic Responsibilities, Critical Thinking',
      'points': 350,
      'status': 'Offline',
    },
  ];
  List<String> achievements = ['Completed 3 Lessons', 'Earned 50 Points'];
  List<String> items = ['Golden Badge'];

  UserState._internal() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      points = prefs.getInt('points') ?? 50;
      tier = _calculateTier();
      String? buddiesString = prefs.getString('buddies');
      if (buddiesString != null) {
        buddies =
            (jsonDecode(buddiesString) as List)
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
      }
      achievements = prefs.getStringList('achievements') ?? achievements;
      items = prefs.getStringList('items') ?? items;
    } catch (e) {
      debugPrint('Error loading user state: $e');
      points = 50;
      tier = 'Explorer';
    }
  }

  String _calculateTier() {
    if (points < 100) return 'Explorer';
    if (points < 300) return 'Learner';
    if (points < 500) return 'Challenger';
    if (points < 700) return 'Achiever';
    return 'Scholar';
  }

  Future<void> updatePoints(int delta) async {
    try {
      points += delta;
      tier = _calculateTier();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('points', points);
      await prefs.setString('buddies', jsonEncode(buddies));
      await prefs.setStringList('achievements', achievements);
      await prefs.setStringList('items', items);
    } catch (e) {
      debugPrint('Error updating points: $e');
      throw Exception('Failed to update points: $e');
    }
  }

  Future<void> addBuddy(Map<String, dynamic> buddy) async {
    try {
      if (!buddies.any((b) => b['name'] == buddy['name']) && points >= 20) {
        buddies.add(buddy);
        await updatePoints(-20);
      } else {
        throw Exception('Not enough points or buddy already added!');
      }
    } catch (e) {
      debugPrint('Error adding buddy: $e');
      throw Exception('Failed to add buddy: $e');
    }
  }

  Future<void> removeBuddy(String buddyName) async {
    try {
      buddies.removeWhere((b) => b['name'] == buddyName);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('buddies', jsonEncode(buddies));
    } catch (e) {
      debugPrint('Error removing buddy: $e');
      throw Exception('Failed to remove buddy: $e');
    }
  }

  Future<void> addAchievement(String achievement) async {
    try {
      if (!achievements.contains(achievement)) {
        achievements.add(achievement);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('achievements', achievements);
      }
    } catch (e) {
      debugPrint('Error adding achievement: $e');
      throw Exception('Failed to add achievement: $e');
    }
  }

  Future<void> addItem(String item) async {
    try {
      if (points >= 50) {
        items.add(item);
        await updatePoints(-50);
      } else {
        throw Exception('Not enough points!');
      }
    } catch (e) {
      debugPrint('Error adding item: $e');
      throw Exception('Failed to add item: $e');
    }
  }

  Future<void> playGame(String game, int cost, int reward) async {
    try {
      if (points >= cost) {
        await updatePoints(-cost + reward);
      } else {
        throw Exception('Not enough points to play!');
      }
    } catch (e) {
      debugPrint('Error playing game: $e');
      throw Exception('Failed to play game: $e');
    }
  }
}

// APPBAR_001_ICONS_PADDING_UPDATE: Reusable AppBar widget for all screens with larger icons and uniform edge padding
PreferredSizeWidget buildAppBar(BuildContext context, {String? title}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(
      100.0,
    ), // Increased height for thicker bar (approx. 100px to mimic mobile safe area + content)
    child: SafeArea(
      child: Container(
        color: BrandColors.veryDarkGray, // Changed to veryDarkGray background
        child: Padding(
          padding: EdgeInsets.only(
            top: 24.0,
          ), // Space for iPhone notch/dynamic island (approx. 24-44px)
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Uniform spacing with padding
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                ), // Uniform padding from left edge
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: BrandColors.white,
                    size: 36.0,
                  ), // Larger icon size
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      title == null
                          ? Image.asset(
                            'assets/logo.png',
                            height: 60.0, // Larger logo size
                            fit: BoxFit.contain,
                          )
                          : Text(
                            title,
                            style: TextStyle(
                              color: BrandColors.white,
                              fontSize: 20,
                            ),
                          ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: BrandColors.white,
                  size: 36.0,
                ), // Larger icon size
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 24.0,
                ), // Uniform padding from right edge
                child: badges.Badge(
                  badgeContent: Text(
                    '2',
                    style: TextStyle(color: BrandColors.white),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: BrandColors.white,
                      size: 36.0,
                    ), // Larger icon size
                    onPressed:
                        () => Navigator.pushNamed(context, '/notifications'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// DRAWER_001_INITIAL: Reusable Drawer widget for navigation
Widget buildDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: BrandColors.darkGray,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: BrandColors.darkTeal),
          child: Text(
            'Amar Pathshala',
            style: TextStyle(color: BrandColors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home, color: BrandColors.white),
          title: Text('Home', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        ListTile(
          leading: Icon(Icons.book, color: BrandColors.white),
          title: Text('Subjects', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/subjects'),
        ),
        ListTile(
          leading: Icon(Icons.people, color: BrandColors.white),
          title: Text('Buddies', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/buddies'),
        ),
        ListTile(
          leading: Icon(Icons.videogame_asset, color: BrandColors.white),
          title: Text('Games', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/games'),
        ),
        ListTile(
          leading: Icon(Icons.bar_chart, color: BrandColors.white),
          title: Text('Progress', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/progress'),
        ),
        ListTile(
          leading: Icon(Icons.store, color: BrandColors.white),
          title: Text(
            'Marketplace',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/marketplace'),
        ),
        ListTile(
          leading: Icon(Icons.school, color: BrandColors.white),
          title: Text('Study Room', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/studyroom'),
        ),
      ],
    ),
  );
}

// HOMESCREEN_001_INITIAL: Home Screen widget with six sections
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For bottom navigation

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/progress');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/studyroom');
        break;
    }
  }

  // HOMESCREEN_002_INITIAL: Circular button widget for navigation
  Widget _buildCircularButton(
    IconData icon,
    String label,
    BuildContext context,
    String route,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, route),
          style: ElevatedButton.styleFrom(
            backgroundColor: BrandColors.teal,
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
            minimumSize: Size(80, 80),
            elevation: 8,
          ),
          child: Icon(icon, color: BrandColors.white, size: 40),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: BrandColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // HOMESCREEN_003_ICONS_PADDING_UPDATE: Thicker AppBar with veryDarkGray background, larger logo, bigger icons, and uniform edge padding, accounting for iPhone notches
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          100.0,
        ), // Increased height for thicker bar (approx. 100px to mimic mobile safe area + content)
        child: SafeArea(
          child: Container(
            color:
                BrandColors.veryDarkGray, // Changed to veryDarkGray background
            child: Padding(
              padding: EdgeInsets.only(
                top: 24.0,
              ), // Space for iPhone notch/dynamic island (approx. 24-44px)
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween, // Adjust for uniform padding
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.0,
                    ), // More padding from left edge
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: BrandColors.white,
                        size: 36.0,
                      ), // Larger icon size
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        height: 60.0, // Keep logo size (already doubled)
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: BrandColors.white,
                      size: 36.0,
                    ), // Larger icon size
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 24.0,
                    ), // More padding from right edge
                    child: badges.Badge(
                      badgeContent: Text(
                        '2',
                        style: TextStyle(color: BrandColors.white),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications,
                          color: BrandColors.white,
                          size: 36.0,
                        ), // Larger icon size
                        onPressed:
                            () =>
                                Navigator.pushNamed(context, '/notifications'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            // HOMESCREEN_004_INITIAL: Avatar and greeting section (fixed for overflow)
            Card(
              color: BrandColors.veryLightTeal,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/avatar.png'),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      // HOMESCREEN_004_OVERFLOW_FIX: Prevent RenderFlex overflow by expanding Column
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Sahar!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: BrandColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Ready for more adventures?',
                            style: TextStyle(
                              fontSize: 18,
                              color: BrandColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            // HOMESCREEN_005_INITIAL: Explore & Learn section
            Card(
              color: BrandColors.lightTeal,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Explore & Learn',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCircularButton(
                          Icons.category,
                          'Topics',
                          context,
                          '/subjects',
                        ),
                        _buildCircularButton(
                          Icons.bolt,
                          'Challenges',
                          context,
                          '/challenges',
                        ),
                        _buildCircularButton(
                          Icons.bookmark,
                          'Bookmarks',
                          context,
                          '/bookmarks',
                        ),
                        _buildCircularButton(
                          Icons.lightbulb,
                          'AI Tutor',
                          context,
                          '/ai-tutor',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            // HOMESCREEN_006_INITIAL: Spend Time with Friends section
            Card(
              color: BrandColors.lightTeal,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Spend Time with Friends',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildCircularButton(
                          Icons.people,
                          'Connect',
                          context,
                          '/connect',
                        ),
                        _buildCircularButton(
                          Icons.play_arrow,
                          'Play',
                          context,
                          '/play',
                        ),
                        _buildCircularButton(
                          Icons.chat,
                          'Talk',
                          context,
                          '/talk',
                        ),
                        _buildCircularButton(
                          Icons.card_giftcard,
                          'Gift',
                          context,
                          '/gift-shop',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            // HOMESCREEN_007_INITIAL: Checkout the Gift Shop section with horizontal scrolling
            Card(
              color: BrandColors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/gift-shop'),
                child: Container(
                  height: 150,
                  padding: EdgeInsets.all(20.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: BrandColors.lightTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Promo Card ${index + 1}',
                            style: TextStyle(
                              color: BrandColors.veryDarkGray,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // HOMESCREEN_008_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// SUBJECTS_001_INITIAL: Subjects Screen widget for displaying learning topics
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  // SUBJECTS_002_INITIAL: Build subject card for grid display
  Widget _buildSubjectCard(
    String title,
    String description,
    BuildContext context,
  ) {
    return Card(
      color: BrandColors.darkGray,
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/lesson', arguments: title),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: BrandColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: BrandColors.lightGray, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SUBJECTS_003_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Subjects'),
      drawer: buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Explore Topics',
                style: TextStyle(
                  fontSize: 24,
                  color: BrandColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildSubjectCard(
                    'Physics',
                    'Explore the laws of the universe.',
                    context,
                  ),
                  _buildSubjectCard(
                    'Entrepreneurial Thinking',
                    'Develop skills to innovate.',
                    context,
                  ),
                  _buildSubjectCard(
                    '21st Century Skills',
                    'Master modern digital skills.',
                    context,
                  ),
                  _buildSubjectCard(
                    'Civic Responsibilities',
                    'Understand your societal role.',
                    context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // SUBJECTS_004_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// LESSON_001_INITIAL: Lesson Screen widget with AI explanations and quizzes
class LessonScreen extends StatefulWidget {
  final String subject;
  const LessonScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final UserState user = UserState();
  String aiResponse = 'Loading AI explanation...';
  int currentQuestionIndex = 0;
  final List<Map<String, String>> questions = [
    {
      'question': 'What is Newton\'s First Law?',
      'answer':
          'An object at rest stays at rest, and an object in motion stays in motion unless acted upon by an external force.',
    },
    {
      'question': 'How does this apply to real life?',
      'answer':
          'A ball won’t move unless you kick it, demonstrating inertia in sports like cricket.',
    },
  ];
  final TextEditingController _quizController = TextEditingController();

  Future<void> getAIAnswer() async {
    if (user.points < 5) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough points to get an AI answer!')),
      );
      return;
    }
    setState(() {
      aiResponse = 'Thinking...';
    });
    await Future.delayed(Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      aiResponse = questions[currentQuestionIndex]['answer']!;
    });
    await user.updatePoints(-5);
  }

  Future<void> submitQuiz() async {
    final answer = _quizController.text.trim().toLowerCase();
    if (answer.isNotEmpty &&
        answer.contains(
          questions[currentQuestionIndex]['answer']!.toLowerCase(),
        )) {
      await user.updatePoints(10);
      await user.addAchievement('Completed ${widget.subject} Lesson');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! You earned 10 points. Check your progress.'),
        ),
      );
      Navigator.pushReplacementNamed(context, '/progress');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Try again! Check the AI response for hints.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _quizController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // LESSON_002_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Lesson: ${widget.subject}'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson: ${widget.subject} Basics',
              style: TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Explore motion and forces with curated questions...',
              style: TextStyle(color: BrandColors.lightGray, fontSize: 16),
            ),
            SizedBox(height: 10),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}: ${questions[currentQuestionIndex]['question']}',
                      style: TextStyle(color: BrandColors.white, fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: getAIAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.lightTeal,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Get AI Answer (5 points)',
                        style: TextStyle(
                          color: BrandColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      aiResponse,
                      style: TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz',
                      style: TextStyle(
                        color: BrandColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _quizController,
                      decoration: InputDecoration(
                        hintText: 'Your answer',
                        hintStyle: TextStyle(color: BrandColors.lightGray),
                        filled: true,
                        fillColor: BrandColors.mediumGray,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: BrandColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: BrandColors.lightTeal),
                        ),
                      ),
                      style: TextStyle(color: BrandColors.white),
                      onSubmitted: (_) => submitQuiz(),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: submitQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.lightTeal,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Submit & Earn Points',
                        style: TextStyle(
                          color: BrandColors.white,
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
      // LESSON_003_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        unselectedItemColor: BrandColors.white,
        selectedItemColor: BrandColors.lightTeal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
      ),
    );
  }
}

// BUDDIES_001_INITIAL: Buddies Screen widget for connecting with users
class BuddiesScreen extends StatefulWidget {
  const BuddiesScreen({Key? key}) : super(key: key);

  @override
  _BuddiesScreenState createState() => _BuddiesScreenState();
}

class _BuddiesScreenState extends State<BuddiesScreen> {
  final UserState user = UserState();
  int currentBuddyIndex = 0;
  late List<Map<String, dynamic>> buddies;

  @override
  void initState() {
    super.initState();
    buddies = user.buddies;
  }

  void swipeLeft() {
    setState(() {
      currentBuddyIndex = (currentBuddyIndex + 1) % buddies.length;
    });
  }

  Future<void> swipeRight() async {
    try {
      await user.addBuddy(buddies[currentBuddyIndex]);
      if (!mounted) return;
      setState(() {
        currentBuddyIndex = (currentBuddyIndex + 1) % buddies.length;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> removeBuddy(String buddyName) async {
    try {
      await user.removeBuddy(buddyName);
      if (!mounted) return;
      setState(() {
        buddies = user.buddies;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BUDDIES_002_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Study Buddies'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Find a Study Buddy',
              style: TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      buddies[currentBuddyIndex]['name'] as String,
                      style: TextStyle(
                        color: BrandColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Interests: ${buddies[currentBuddyIndex]['interests']}',
                      style: TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Points: ${buddies[currentBuddyIndex]['points']} | Status: ${buddies[currentBuddyIndex]['status']}',
                      style: TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: swipeLeft,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Pass',
                    style: TextStyle(color: BrandColors.white, fontSize: 16),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: swipeRight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.lightTeal,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Connect (20 points)',
                    style: TextStyle(color: BrandColors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'My Buddies',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: user.buddies.length,
              itemBuilder: (context, index) {
                final buddyName = user.buddies[index]['name'] as String;
                return Card(
                  color: BrandColors.darkGray,
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      buddyName,
                      style: TextStyle(color: BrandColors.white),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: BrandColors.teal),
                      onPressed: () => removeBuddy(buddyName),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Chat with Buddies',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: null,
              hint: Text(
                'Select a Buddy',
                style: TextStyle(color: BrandColors.lightGray),
              ),
              dropdownColor: BrandColors.darkGray,
              items:
                  user.buddies.map((buddy) {
                    return DropdownMenuItem<String>(
                      value: buddy['name'] as String,
                      child: Text(
                        buddy['name'] as String,
                        style: TextStyle(color: BrandColors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: BrandColors.darkGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                padding: EdgeInsets.all(8.0),
                children: [
                  Text(
                    'Buddy (Mock): Great point! Let\'s discuss more.',
                    style: TextStyle(color: BrandColors.lightGray),
                  ),
                  Text(
                    'You: Sure, I agree!',
                    style: TextStyle(color: BrandColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: BrandColors.lightGray),
                      filled: true,
                      fillColor: BrandColors.mediumGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BrandColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: BrandColors.lightTeal),
                      ),
                    ),
                    style: TextStyle(color: BrandColors.white),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message sent!')),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.lightTeal,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Icon(Icons.send, color: BrandColors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      // BUDDIES_003_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        unselectedItemColor: BrandColors.white,
        selectedItemColor: BrandColors.lightTeal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
      ),
    );
  }
}

// GAMES_001_INITIAL: Games Screen widget for mini-games
class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  // GAMES_002_INITIAL: Build game card for grid display
  Widget _buildGameCard(
    String title,
    String description,
    BuildContext context,
  ) {
    return Card(
      color: BrandColors.darkGray,
      elevation: 4,
      child: InkWell(
        onTap:
            () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Playing $title...'))),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: BrandColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: BrandColors.lightGray, fontSize: 14),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = UserState();
                    await user.playGame(
                      title,
                      title == 'Tic Tac Toe'
                          ? 10
                          : title == 'Ludo'
                          ? 15
                          : 5,
                      title == 'Tic Tac Toe'
                          ? 15
                          : title == 'Ludo'
                          ? 20
                          : 10,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Play $title for points!')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.lightTeal,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Play',
                  style: TextStyle(color: BrandColors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // GAMES_003_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Mini-Games'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Mini-Games',
              style: TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildGameCard(
                  'Tic Tac Toe',
                  'Play solo or with a buddy (10 points, +15 on win)',
                  context,
                ),
                _buildGameCard(
                  'Ludo',
                  'Multiplayer fun with friends (15 points, +20 on win)',
                  context,
                ),
                _buildGameCard(
                  'Trivia Challenge',
                  'Test your knowledge solo (5 points, +10 on win)',
                  context,
                ),
              ],
            ),
          ],
        ),
      ),
      // GAMES_004_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        unselectedItemColor: BrandColors.white,
        selectedItemColor: BrandColors.lightTeal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
      ),
    );
  }
}

// PROGRESS_001_INITIAL: Progress Screen widget for user progress tracking
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserState user = UserState();
    return Scaffold(
      // PROGRESS_002_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Dashboard'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tier: ${user.tier}',
                      style: TextStyle(
                        color: BrandColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Points: ${user.points.toString().padLeft(5, "0")}',
                      style: TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: user.points / 700,
                      backgroundColor: BrandColors.mediumGray,
                      color: BrandColors.lightTeal,
                      minHeight: 10,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'To reach ${user.tier == "Scholar" ? "Master" : user.tier + " Plus"}: ${700 - user.points} more points',
                      style: TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...user.achievements.map(
              (achievement) => Card(
                color: BrandColors.darkGray,
                elevation: 4,
                child: ListTile(
                  title: Text(
                    achievement,
                    style: TextStyle(color: BrandColors.white),
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: BrandColors.lightTeal,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: ListTile(
                title: Text(
                  'Completed Physics Lesson (+10 points)',
                  style: TextStyle(color: BrandColors.white),
                ),
                trailing: Icon(Icons.access_time, color: BrandColors.lightGray),
              ),
            ),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: ListTile(
                title: Text(
                  'Connected with Buddy',
                  style: TextStyle(color: BrandColors.white),
                ),
                trailing: Icon(Icons.person_add, color: BrandColors.lightGray),
              ),
            ),
          ],
        ),
      ),
      // PROGRESS_003_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        unselectedItemColor: BrandColors.white,
        selectedItemColor: BrandColors.lightTeal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
      ),
    );
  }
}

// MARKETPLACE_001_INITIAL: Marketplace Screen widget for purchasing items
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  // MARKETPLACE_002_INITIAL: Build marketplace item card for grid display
  Widget _buildMarketplaceItem(
    String title,
    String description,
    BuildContext context,
  ) {
    return Card(
      color: BrandColors.darkGray,
      elevation: 4,
      child: InkWell(
        onTap:
            () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Purchasing $title...'))),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: BrandColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: BrandColors.lightGray, fontSize: 14),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = UserState();
                    await user.addItem(title);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Purchased $title!')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.lightTeal,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Buy',
                  style: TextStyle(color: BrandColors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MARKETPLACE_003_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Marketplace'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Marketplace',
              style: TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      color: BrandColors.lightTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Promo Card ${index + 1}',
                        style: TextStyle(
                          color: BrandColors.veryDarkGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildMarketplaceItem(
                  'Bangla Tiger Badge',
                  'Show your Bangladeshi pride (50 points, Premium: ৳200)',
                  context,
                ),
                _buildMarketplaceItem(
                  'Study Desk Theme (Rangpur)',
                  'Customize with local Bangla design (30 points, Premium: ৳150)',
                  context,
                ),
                _buildMarketplaceItem(
                  'Star Sticker (Eid Special)',
                  'Celebrate Eid with flair (20 points, Premium: ৳100)',
                  context,
                ),
                _buildMarketplaceItem(
                  'Cricket Bat Icon',
                  'Honor Bangladesh’s cricket passion (40 points, Premium: ৳180)',
                  context,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Premium users can purchase items with real money via bKash or card!',
              style: TextStyle(fontSize: 14, color: BrandColors.lightGray),
            ),
          ],
        ),
      ),
      // MARKETPLACE_004_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        unselectedItemColor: BrandColors.white,
        selectedItemColor: BrandColors.lightTeal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
      ),
    );
  }
}

// STUDYROOM_001_INITIAL: Study Room Screen widget for displaying user achievements
class StudyRoomScreen extends StatelessWidget {
  const StudyRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserState user = UserState();
    return Scaffold(
      // STUDYROOM_002_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: 'Study Room'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Study Room',
              style: TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...user.achievements.map(
              (achievement) => Card(
                color: BrandColors.darkGray,
                elevation: 4,
                child: ListTile(
                  title: Text(
                    achievement,
                    style: TextStyle(color: BrandColors.white),
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: BrandColors.lightTeal,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Badges',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: ListTile(
                title: Text(
                  'Explorer Badge',
                  style: TextStyle(color: BrandColors.white),
                ),
                trailing: Icon(Icons.badge, color: BrandColors.teal),
              ),
            ),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: ListTile(
                title: Text(
                  'Learner Badge',
                  style: TextStyle(color: BrandColors.white),
                ),
                trailing: Icon(Icons.badge, color: BrandColors.lightTeal),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Marketplace Items',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...user.items.map(
              (item) => Card(
                color: BrandColors.darkGray,
                elevation: 4,
                child: ListTile(
                  title: Text(item, style: TextStyle(color: BrandColors.white)),
                  trailing: Icon(Icons.star, color: BrandColors.lightTeal),
                ),
              ),
            ),
          ],
        ),
      ),
      // STUDYROOM_003_INITIAL: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        unselectedItemColor: BrandColors.white,
        selectedItemColor: BrandColors.lightTeal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/studyroom');
              break;
          }
        },
      ),
    );
  }
}

// PLACEHOLDER_001_INITIAL: Placeholder Screen for unimplemented routes
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PLACEHOLDER_002_INITIAL: App bar with navigation and notifications
      appBar: buildAppBar(context, title: title),
      drawer: buildDrawer(context),
      body: Center(
        child: Text(
          'This is the $title screen',
          style: TextStyle(fontSize: 20, color: BrandColors.white),
        ),
      ),
    );
  }
}
