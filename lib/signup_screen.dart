import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup(LanguageProvider languageProvider) async {
    FocusScope.of(context).unfocus();
    final scaffold = ScaffoldMessenger.of(context);

    final name = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final usernameReg = RegExp(r'^[A-Za-z0-9_]+$');

    if (name.isEmpty || !usernameReg.hasMatch(name)) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isArabic
                ? 'اسم المستخدم يجب أن يحتوي على حروف وأرقام وشرطة سفلية فقط'
                : 'Username may contain only letters, numbers and underscores',
          ),
        ),
      );
      return;
    }
    if (email.isEmpty || password.length < 8) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isArabic
                ? 'يرجى إدخال بريد إلكتروني صحيح وكلمة مرور لا تقل عن 8 أحرف'
                : 'Please enter a valid email and a password of at least 8 characters',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.register(name: name, email: email, password: password);
      if (!resp.ok) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              resp.error ?? (languageProvider.isArabic ? 'فشل إنشاء الحساب' : 'Sign up failed'),
            ),
          ),
        );
        return;
      }
      final token = resp.data['token'] as String?;
      if (token == null) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              languageProvider.isArabic
                  ? 'استجابة غير متوقعة من الخادم'
                  : 'Unexpected server response',
            ),
          ),
        );
        return;
      }
      await ApiClient.instance.saveToken(token);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isArabic
                ? 'تم إنشاء الحساب بنجاح'
                : 'Account created successfully',
          ),
        ),
      );
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isArabic
                ? 'خطأ في الشبكة. يرجى المحاولة لاحقًا.'
                : 'Network error. Please try again later.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: themeProvider.isDarkMode
                        ? themeProvider.gradientColors
                        : [const Color(0xFF163832), const Color(0xFF235347)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: themeProvider.isDarkMode ? 0.5 : 1.0,
                        child: Image.asset(
                          themeProvider.backgroundImage3,
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: themeProvider.backgroundImageOverlay),
                    ),
                    Positioned(
                      top: 0,
                      left: 20,
                      child: Image.asset(
                        themeProvider.backgroundImage1,
                        height: 150,
                        fit: BoxFit.contain,
                        cacheWidth: 300,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        themeProvider.backgroundImage2,
                        height: 300,
                        fit: BoxFit.contain,
                        cacheWidth: 600,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),

                    SafeArea(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.06,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                                Text(
                                  languageProvider.isArabic ? 'إنشاء حساب' : 'Sign Up',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.08,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.primaryTextColor,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Text(
                                  languageProvider.isArabic
                                      ? 'انضم لبدء رحلتك الروحية. تتبع ختمتك وذكرك والمزيد.'
                                      : 'Join to start your spiritual journey. Track your Khitma, Dhikr and more.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    color: themeProvider.secondaryTextColor,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                                // Username
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    controller: _usernameController,
                                    keyboardType: TextInputType.text,
                                    autofillHints: const [],
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    style: TextStyle(
                                      color: themeProvider.primaryTextColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: languageProvider.isArabic ? 'اسم المستخدم' : 'Username',
                                      labelStyle: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: themeProvider.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: themeProvider.primaryTextColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width * 0.05,
                                        vertical: MediaQuery.of(context).size.height * 0.02,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                // Email
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
                                    enableSuggestions: true,
                                    autocorrect: false,
                                    style: TextStyle(
                                      color: themeProvider.primaryTextColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: languageProvider.isArabic ? 'البريد الإلكتروني' : 'Email',
                                      labelStyle: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: themeProvider.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: themeProvider.primaryTextColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width * 0.05,
                                        vertical: MediaQuery.of(context).size.height * 0.02,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                                // Password
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
                                    autofillHints: const [AutofillHints.newPassword],
                                    enableSuggestions: true,
                                    autocorrect: false,
                                    style: TextStyle(
                                      color: themeProvider.primaryTextColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: languageProvider.isArabic ? 'كلمة المرور' : 'Password',
                                      labelStyle: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: themeProvider.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: themeProvider.primaryTextColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: MediaQuery.of(context).size.width * 0.05,
                                        vertical: MediaQuery.of(context).size.height * 0.02,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                                // Sign Up button
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : () => _handleSignup(languageProvider),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeProvider.buttonBackgroundColor,
                                      foregroundColor: themeProvider.buttonTextColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(
                                            languageProvider.isArabic ? 'إنشاء حساب' : 'Sign Up',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width * 0.045,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                                // Login link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageProvider.isArabic
                                          ? 'لديك حساب بالفعل؟ '
                                          : 'Already have account? ',
                                      style: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        languageProvider.isArabic ? 'تسجيل الدخول' : 'Login',
                                        style: TextStyle(
                                          color: themeProvider.primaryTextColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
