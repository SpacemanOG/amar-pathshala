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

// MAIN_001_INITIAL: Entry point with Flutter bindings
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AmarPathshalaApp());
}

// APP_001_INITIAL: Root widget for the Amar Pathshala app in Light Theme
class AmarPathshalaApp extends StatelessWidget {
  const AmarPathshalaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amar Pathshala',
      theme: ThemeData.light().copyWith(
        primaryColor: BrandColors.darkTeal,
        scaffoldBackgroundColor: BrandColors.veryLightTeal,
        cardColor: BrandColors.white,
        buttonTheme: const ButtonThemeData(
          buttonColor: BrandColors.teal,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/subjects': (context) => const SubjectsScreen(),
        '/lesson': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return LessonScreen(subject: args ?? 'Unknown Subject');
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
        '/profile': (context) => const PlaceholderScreen(title: 'Profile'),
        '/notifications':
            (context) => const PlaceholderScreen(title: 'Notifications'),
        '/dashboard': (context) => const PlaceholderScreen(title: 'Dashboard'),
      },
    );
  }
}

// USERSTATE_001_INITIAL: Singleton for managing user state and persistence
class UserState {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;

  int points = 50;
  String tier = 'Explorer';
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
      achievements = prefs.getStringList('achievements') ?? achievements;
      items = prefs.getStringList('items') ?? items;
    } catch (e) {
      debugPrint('Error loading user state: $e');
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
      await prefs.setStringList('achievements', achievements);
      await prefs.setStringList('items', items);
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  Future<void> addAchievement(String achievement) async {
    if (!achievements.contains(achievement)) {
      achievements.add(achievement);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('achievements', achievements);
    }
  }

  Future<void> addItem(String item) async {
    if (points >= 50) {
      items.add(item);
      await updatePoints(-50);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('items', items);
    } else {
      throw Exception('Not enough points!');
    }
  }

  Future<void> playGame(String game, int cost, int reward) async {
    if (points >= cost) {
      await updatePoints(-cost + reward);
    } else {
      throw Exception('Not enough points to play!');
    }
  }
}

// APPBAR_001_LIGHT_THEME_UPDATE: Custom AppBar for Light Theme with hamburger fix
PreferredSizeWidget buildAppBar(BuildContext context, {String? title}) {
  final statusBarHeight = MediaQuery.of(context).padding.top;
  return PreferredSize(
    preferredSize: Size.fromHeight(80 + statusBarHeight),
    child: SafeArea(
      child: Container(
        color: BrandColors.darkTeal,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: BrandColors.white,
                      size: 30,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
            if (title == null)
              Image.asset('assets/logo.png', height: 40, fit: BoxFit.contain)
            else
              Text(
                title,
                style: const TextStyle(color: BrandColors.white, fontSize: 20),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: BrandColors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                ),
                badges.Badge(
                  badgeContent: const Text(
                    '2',
                    style: TextStyle(color: BrandColors.white),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: BrandColors.white,
                      size: 30,
                    ),
                    onPressed:
                        () => Navigator.pushNamed(context, '/notifications'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// DRAWER_001_SHARP_CORNERS_UPDATE: Reusable Drawer with sharp corners
Widget buildDrawer(BuildContext context) {
  return Drawer(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    backgroundColor: BrandColors.darkGray,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: BrandColors.darkTeal),
          child: const Text(
            'Amar Pathshala',
            style: TextStyle(color: BrandColors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: BrandColors.white),
          title: const Text('Home', style: TextStyle(color: BrandColors.white)),
          onTap: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        ListTile(
          leading: const Icon(Icons.book, color: BrandColors.white),
          title: const Text(
            'Subjects',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/subjects'),
        ),
        ListTile(
          leading: const Icon(Icons.people, color: BrandColors.white),
          title: const Text(
            'Buddies',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/buddies'),
        ),
        ListTile(
          leading: const Icon(Icons.videogame_asset, color: BrandColors.white),
          title: const Text(
            'Games',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/games'),
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart, color: BrandColors.white),
          title: const Text(
            'Progress',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/progress'),
        ),
        ListTile(
          leading: const Icon(Icons.store, color: BrandColors.white),
          title: const Text(
            'Marketplace',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/marketplace'),
        ),
        ListTile(
          leading: const Icon(Icons.school, color: BrandColors.white),
          title: const Text(
            'Study Room',
            style: TextStyle(color: BrandColors.white),
          ),
          onTap: () => Navigator.pushReplacementNamed(context, '/studyroom'),
        ),
      ],
    ),
  );
}

// HOMESCREEN_001_LIGHT_THEME_UPDATE: Home Screen in Light Theme
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/progress');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  // HOMESCREEN_002_TEXTCOLOR_UPDATE: Reusable circular button with dynamic text color
  Widget _buildCircularButton(
    IconData icon,
    String label,
    BuildContext context,
    String route,
    Color textColor,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, route),
          style: ElevatedButton.styleFrom(
            backgroundColor: BrandColors.teal,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            minimumSize: const Size(80, 80),
            elevation: 8,
          ),
          child: Icon(icon, color: BrandColors.white, size: 40),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: textColor,
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
      backgroundColor: BrandColors.veryLightTeal,
      appBar: buildAppBar(context),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // HOMESCREEN_003_AVATAR_GREETING: Section 2 - Avatar and Greeting
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Sahar!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: BrandColors.veryDarkGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'Ready for more adventures?',
                          style: TextStyle(
                            fontSize: 18,
                            color: BrandColors.veryDarkGray,
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
            const SizedBox(height: 40),
            // HOMESCREEN_004_EXPLORE_LEARN: Section 3 - Explore & Learn
            Card(
              color: BrandColors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Explore & Learn',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.veryDarkGray,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          BrandColors.veryDarkGray,
                        ),
                        _buildCircularButton(
                          Icons.bolt,
                          'Challenges',
                          context,
                          '/challenges',
                          BrandColors.veryDarkGray,
                        ),
                        _buildCircularButton(
                          Icons.bookmark,
                          'Bookmarks',
                          context,
                          '/bookmarks',
                          BrandColors.veryDarkGray,
                        ),
                        _buildCircularButton(
                          Icons.lightbulb,
                          'AI Tutor',
                          context,
                          '/ai-tutor',
                          BrandColors.veryDarkGray,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // HOMESCREEN_005_SPEND_WITH_FRIENDS: Section 4 - Spend Time with Friends
            Card(
              color: BrandColors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Spend Time with Friends',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.veryDarkGray,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          BrandColors.veryDarkGray,
                        ),
                        _buildCircularButton(
                          Icons.play_arrow,
                          'Play',
                          context,
                          '/play',
                          BrandColors.veryDarkGray,
                        ),
                        _buildCircularButton(
                          Icons.chat,
                          'Talk',
                          context,
                          '/talk',
                          BrandColors.veryDarkGray,
                        ),
                        _buildCircularButton(
                          Icons.card_giftcard,
                          'Gift',
                          context,
                          '/gift-shop',
                          BrandColors.veryDarkGray,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // HOMESCREEN_006_GIFTSHOP: Section 5 - Checkout the Gift Shop
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
                  padding: const EdgeInsets.all(20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: BrandColors.white,
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
      // HOMESCREEN_007_BOTTOMNAV: Bottom navigation bar for persistent navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// SUBJECTS_001_INITIAL: Subjects Screen widget
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: BrandColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: BrandColors.lightGray,
                  fontSize: 14,
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
      appBar: buildAppBar(context, title: 'Subjects'),
      drawer: buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Explore Topics',
                style: TextStyle(
                  fontSize: 24,
                  color: BrandColors.veryDarkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
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
    setState(() => aiResponse = 'Thinking...');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => aiResponse = questions[currentQuestionIndex]['answer']!);
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
      appBar: buildAppBar(context, title: 'Lesson: ${widget.subject}'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson: ${widget.subject} Basics',
              style: const TextStyle(
                fontSize: 24,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Explore motion and forces with curated questions...',
              style: const TextStyle(
                color: BrandColors.lightGray,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1}: ${questions[currentQuestionIndex]['question']}',
                      style: const TextStyle(
                        color: BrandColors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: getAIAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.lightTeal,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Get AI Answer (5 points)',
                        style: TextStyle(
                          color: BrandColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      aiResponse,
                      style: const TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiz',
                      style: TextStyle(
                        color: BrandColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _quizController,
                      decoration: InputDecoration(
                        hintText: 'Your answer',
                        hintStyle: const TextStyle(
                          color: BrandColors.lightGray,
                        ),
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
                      style: const TextStyle(color: BrandColors.white),
                      onSubmitted: (_) => submitQuiz(),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: submitQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.lightTeal,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

// BUDDIES_001_INITIAL: Buddies Screen widget
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
    buddies = [
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
  }

  void swipeLeft() {
    setState(
      () => currentBuddyIndex = (currentBuddyIndex + 1) % buddies.length,
    );
  }

  Future<void> swipeRight() async {
    try {
      await user.updatePoints(-20);
      if (!mounted) return;
      setState(
        () => currentBuddyIndex = (currentBuddyIndex + 1) % buddies.length,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> removeBuddy(String buddyName) async {
    try {
      setState(() => buddies.removeWhere((b) => b['name'] == buddyName));
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
      appBar: buildAppBar(context, title: 'Study Buddies'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: swipeLeft,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.teal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Pass',
                    style: TextStyle(color: BrandColors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: swipeRight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.lightTeal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Connect (20 points)',
                    style: TextStyle(color: BrandColors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buddies.length,
              itemBuilder: (context, index) {
                final buddyName = buddies[index]['name'] as String;
                return Card(
                  color: BrandColors.darkGray,
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      buddyName,
                      style: TextStyle(color: BrandColors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: BrandColors.teal),
                      onPressed: () => removeBuddy(buddyName),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
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
                  buddies
                      .map(
                        (buddy) => DropdownMenuItem<String>(
                          value: buddy['name'] as String,
                          child: Text(
                            buddy['name'] as String,
                            style: TextStyle(color: BrandColors.white),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (String? newValue) => setState(() {}),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: BrandColors.darkGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: const [
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
            const SizedBox(height: 10),
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
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed:
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message sent!')),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.lightTeal,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Icon(Icons.send, color: BrandColors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

// GAMES_001_INITIAL: Games Screen widget
class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: BrandColors.lightGray, fontSize: 14),
              ),
              const SizedBox(height: 10),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
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
      appBar: buildAppBar(context, title: 'Mini-Games'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

// PROGRESS_001_INITIAL: Progress Screen widget
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = UserState();
    return Scaffold(
      appBar: buildAppBar(context, title: 'Dashboard'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),
            Card(
              color: BrandColors.darkGray,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tier: ${user.tier}',
                      style: const TextStyle(
                        color: BrandColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Points: ${user.points.toString().padLeft(5, "0")}',
                      style: const TextStyle(
                        color: BrandColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: user.points / 700,
                      backgroundColor: BrandColors.mediumGray,
                      color: BrandColors.lightTeal,
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

// MARKETPLACE_001_INITIAL: Marketplace Screen widget
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

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
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: BrandColors.lightGray, fontSize: 14),
              ),
              const SizedBox(height: 10),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
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
      appBar: buildAppBar(context, title: 'Marketplace'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
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
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 10),
            Text(
              'Premium users can purchase items with real money via bKash or card!',
              style: TextStyle(fontSize: 14, color: BrandColors.lightGray),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

// STUDYROOM_001_INITIAL: Study Room Screen widget
class StudyRoomScreen extends StatelessWidget {
  const StudyRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = UserState();
    return Scaffold(
      appBar: buildAppBar(context, title: 'Study Room'),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 20),
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Text(
              'Badges',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Text(
              'Marketplace Items',
              style: TextStyle(
                fontSize: 20,
                color: BrandColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: BrandColors.darkTeal,
        selectedItemColor: BrandColors.white,
        unselectedItemColor: BrandColors.lightGray,
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
              Navigator.pushReplacementNamed(context, '/profile');
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
      appBar: buildAppBar(context, title: title),
      drawer: buildDrawer(context),
      body: Center(
        child: Text(
          'This is the $title screen',
          style: const TextStyle(fontSize: 20, color: BrandColors.veryDarkGray),
        ),
      ),
    );
  }
}
