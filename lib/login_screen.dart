import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgetpass_screen.dart';
import 'services/api_client.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'profile_provider.dart';
import 'services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(LanguageProvider languageProvider) async {
    FocusScope.of(context).unfocus();
    final scaffold = ScaffoldMessenger.of(context);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isArabic
                ? 'يرجى إدخال البريد الإلكتروني وكلمة المرور'
                : 'Please enter email and password',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.login(email: email, password: password);
      if (!resp.ok) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              resp.error ?? (languageProvider.isArabic ? 'فشل تسجيل الدخول' : 'Login failed'),
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
      // Prime in-memory profile with response user
      try {
        final userMap = (resp.data['user'] as Map).cast<String, dynamic>();
        // ignore: use_build_context_synchronously
        Provider.of<ProfileProvider>(context, listen: false).setFromMap(userMap);
      } catch (_) {}
      // Register device token with backend (now that we have auth)
      try {
        // ignore: use_build_context_synchronously
        await NotificationService().registerWithBackend();
      } catch (_) {}
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            languageProvider.isArabic
                ? 'تم تسجيل الدخول بنجاح'
                : 'Logged in successfully',
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
              onTap: () {
                FocusScope.of(context).unfocus();
              },
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
                    // Background image
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
                    // Color overlay based on theme
                    Positioned.fill(
                      child: Container(
                        color: themeProvider.backgroundImageOverlay,
                      ),
                    ),
                    // Top lanterns
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
                    // Bottom mosque
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
                    // Main content
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
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.10,
                                ),
                                // Title
                                Text(
                                  languageProvider.isArabic ? 'تسجيل الدخول' : 'Login',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.08,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.primaryTextColor,
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
                                // Subtitle
                                Text(
                                  languageProvider.isArabic
                                      ? 'مرحبًا بعودتك. واصل طريقك في الذكر والتأمل والعبادة بسهولة.'
                                      : 'Welcome back. Continue your path of remembrance, reflection, and worship with ease.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    color: themeProvider.secondaryTextColor,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.05,
                                ),
                                // Email field
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
                                      labelText:
                                          languageProvider.isArabic ? 'البريد الإلكتروني' : 'Email',
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
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
                                // Password field
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    autofillHints: const [AutofillHints.password],
                                    enableSuggestions: true,
                                    autocorrect: false,
                                    style: TextStyle(
                                      color: themeProvider.primaryTextColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                    decoration: InputDecoration(
                                      labelText:
                                          languageProvider.isArabic ? 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±' : 'Password',
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
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: themeProvider.secondaryTextColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.012,
                                ),
                                // Forget Password link
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgetPassScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: themeProvider.secondaryTextColor,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      languageProvider.isArabic
                                          ? 'نسيت كلمة المرور؟'
                                          : 'Forget Password?',
                                      style: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize: MediaQuery.of(context).size.width * 0.038,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.025,
                                ),
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    onPressed: _loading
                                        ? null
                                        : () => _handleLogin(languageProvider),
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
                                            languageProvider.isArabic
                                                ? 'تسجيل الدخول'
                                                : 'Login',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width * 0.045,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                ),
                                // Sign Up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageProvider.isArabic
                                          ? 'ليس لديك حساب؟ '
                                          : "Don't have account? ",
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
                                            builder: (context) => const SignupScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        languageProvider.isArabic ? 'إنشاء حساب' : 'Sign Up',
                                        style: TextStyle(
                                          color: themeProvider.primaryTextColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.08,
                                ),
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
