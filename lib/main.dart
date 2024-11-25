import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.setLanguageCode('uk'); // Для української мови

  runApp(const StudentApp());
}

class AppColors {
  static const primary = Colors.orange;
  static const primaryDark = Colors.orangeAccent;
  static const appBarBackground = Colors.orange;
  static const scaffoldBackground = Colors.grey;
  static const iconColor = Colors.white;
  static const textPrimary = Colors.orange;
  static const textSecondary = Colors.grey;
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student App',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.scaffoldBackground.shade200,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          titleTextStyle: const TextStyle(
            color: AppColors.iconColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.iconColor),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          buttonColor: AppColors.primaryDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey[800], fontSize: 16),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          titleLarge: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SignInScreen(),
    );
  }
}

class StudentInfo {
  // final String specialty;
  // final String level;
  final int course;

  // StudentInfo({required this.specialty, required this.level, required this.course});
   StudentInfo({ required this.course});
  // StudentInfo({required this.specialty, required this.level});
}


StudentInfo? parseStudentEmail(String email) {
  // Перевіряємо лише домен
  if (!email.endsWith('@kpnu.edu.ua')) {
    return null; // Email не відповідає домену університету
  }

  // Повертаємо порожній об'єкт StudentInfo, якщо перевірка пройдена
  // return StudentInfo(specialty: '', level: '', course: 0);
    return StudentInfo(course: 0);
}

// StudentInfo? parseStudentEmail(String email) {
//   if (!email.endsWith('@kpnu.edu.ua')) {
//     return null;
//   }

//   final parts = email.split('@')[0].split('.');
//   if (parts.length < 2) return null;

//   final groupCode = parts[0];
//  if (groupCode.length < 5) return null; 

//   final specialtyCode = groupCode.substring(0, 2);
//   String specialty = (specialtyCode == 'kn') ? 'Комп\'ютерні науки' : 'Невідома спеціальність';

//   final levelCode = groupCode[2];
//   String level = (levelCode == 'b') ? 'Бакалавр' : 'Магістр';
//   int maxYears = (levelCode == 'b') ? 4 : 2;


//   final yearString = groupCode.substring(3, 5);
//   if (yearString.length != 2 || int.tryParse(yearString) == null) {
//     return null; // Якщо не валідний рік
//   }

//   final year = int.parse('20${groupCode.substring(3, 5)}'); // Не перевіряємо на валідність
//   final currentYear = DateTime.now().year;
//   final course = (currentYear - year + 1).clamp(1, maxYears);

//   return StudentInfo(specialty: specialty, level: level, course: course);
// }

// StudentInfo? parseStudentEmail(String email) {
//   if (!email.endsWith('@kpnu.edu.ua')) {
//     return null; // Email не відповідає домену університету
//   }

//   // Якщо перевірка пройдена, повертаємо порожній об'єкт або обробляємо далі за потреби
//   return StudentInfo(specialty: '', level: '', course: 0);
// }


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _errorMessage = 'Вхід скасовано.';
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final studentInfo = parseStudentEmail(user.email!);
        if (studentInfo == null) {
          setState(() {
            _errorMessage = 'Ваш email не відповідає формату університету.';
          });
          await _auth.signOut();
          await _googleSignIn.signOut();
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(
              groupCode: user.email!,
              studentInfo: studentInfo,
            ),
          ),
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Помилка авторизації: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизація')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: const Text('Увійти через Google'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class MainPage extends StatelessWidget {
  final String groupCode;
  final StudentInfo studentInfo;

  const MainPage({super.key, required this.groupCode, required this.studentInfo});

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete(); // Видалення користувача
        
        await GoogleSignIn().signOut(); // Вихід із Google
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Акаунт успішно видалено')),
        );

        // Повернення на екран авторизації
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      // Обробка помилок, наприклад, якщо потрібно знову увійти перед видаленням
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Головна сторінка')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Група: $groupCode'),
            // Text('Спеціальність: ${studentInfo.specialty}'),
            // Text('Рівень: ${studentInfo.level}'),
            Text('Курс: ${studentInfo.course}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              child: const Text('Видалити акаунт'),
            ),
          ],
        ),
      ),
    );
  }
}
