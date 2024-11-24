import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ініціалізація Firebase
  runApp(StudentApp());
}

// Клас з визначенням кольорів
class AppColors {
  static const primary = Colors.orange;
  static const primaryDark = Colors.orangeAccent;
  static const appBarBackground = Colors.orange;
  static const scaffoldBackground = Colors.grey;
  static const iconColor = Colors.white;
  static const textPrimary = Colors.orange;
  static const textSecondary = Colors.grey;
  static const cardBackground = Colors.grey;
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      theme: ThemeData(
        primaryColor: AppColors.primary, // Заміна для 'primary'
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackground[100],
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBarBackground[700],
          titleTextStyle: TextStyle(
            color: AppColors.iconColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.iconColor),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          buttonColor: AppColors.primaryDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryDark, // Заміна для 'primary'
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    textStyle: TextStyle(fontSize: 18),
  ),
),

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800], fontSize: 16), // Заміна для 'bodyText1'
          bodyMedium: TextStyle(color: AppColors.textSecondary[700]), // Заміна для 'bodyText2'
          titleLarge: TextStyle( // Заміна для 'headline6'
            color: AppColors.textPrimary[800],
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: SignInScreen(), // Початковий екран з авторизацією
    );
  }
}


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _errorMessage;

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (error) {
      setState(() {
        _errorMessage = "Error signing in with Google: $error";
      });
      return null;
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Авторизація')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                User? user = await _signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainPage(groupCode: user.email ?? '')),
                  );
                }
              },
              child: Text('Увійти через Google'),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(_errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final String groupCode;

  const MainPage({super.key, required this.groupCode});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CoursesPage(),
    ElectivesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Додаток Студент'),
      ),
      body: _selectedIndex == 3
          ? ProfilePage(groupCode: widget.groupCode)
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.appBarBackground[600],
        selectedItemColor: AppColors.iconColor,
        unselectedItemColor: AppColors.iconColor.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Дисципліни',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Вибіркові',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профіль',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
      ),
    );
  }
}

// Інші сторінки, як у вашому попередньому коді

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Тут буде розклад занять',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimary[800]),
      ),
    );
  }
}

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Тут буде список дисциплін по курсам',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimary[800]),
      ),
    );
  }
}

class ElectivesPage extends StatelessWidget {
  const ElectivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Тут буде вибір вибіркових дисциплін',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimary[800]),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String groupCode;

  const ProfilePage({super.key, required this.groupCode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Група: $groupCode',
        style: TextStyle(fontSize: 24, color: AppColors.textPrimary[800]),
      ),
    );
  }
}
