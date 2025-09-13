import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';
import 'home_screen.dart';
import 'profile_provider.dart';
import 'app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
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
    final l = AppLocalizations.of(context)!;

    // Normalize username: collapse multiple spaces and trim
    final username = _usernameController.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Allow Latin (incl. extended) and Arabic letter ranges, with spaces
    final usernamePattern = RegExp(
        r'^[A-Za-z\u00C0-\u024F\u1E00-\u1EFF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+(?: [A-Za-z\u00C0-\u024F\u1E00-\u1EFF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]+)*$',
        unicode: true);

    if (username.isEmpty || username.length > 255 || !usernamePattern.hasMatch(username)) {
      scaffold.showSnackBar(
        SnackBar(
            content: Text(
              l.invalidUsername,
            ),
        ),
      );
      return;
    }
    if (email.isEmpty || password.length < 8) {
      scaffold.showSnackBar(
        SnackBar(
            content: Text(
              l.enterValidEmailPassword8,
            ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.register(username: username, email: email, password: password);
      if (!resp.ok) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              resp.error ?? l.signUpFailed,
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
              l.unexpectedServerResponse,
            ),
          ),
        );
        return;
      }
      await ApiClient.instance.saveToken(token);
      // Prime in-memory profile with response user (no extra network hop)
      try {
        final userMap = (resp.data['user'] as Map).cast<String, dynamic>();
        if (mounted) {
          // ignore: use_build_context_synchronously
          Provider.of<ProfileProvider>(context, listen: false).setFromMap(userMap);
        }
      } catch (_) {}
      // Register device token with backend (now that we have auth)
      try {
        await NotificationService().registerWithBackend();
      } catch (_) {}
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            l.accountCreatedSuccessfully,
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
            l.networkErrorTryLater,
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
        final appLocalizations = AppLocalizations.of(context)!;
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
                    // Background SVG (subtle): 3% (dark), 4% (light)
                    Positioned.fill(
                      child: Opacity(
                        opacity: themeProvider.isDarkMode ? 0.03 : 0.05,
                        child: SvgPicture.asset(
                          'assets/background_elements/3_background.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
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
                                  appLocalizations.signupTitle,
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.08,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.primaryTextColor,
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                Text(
                                  appLocalizations.signupSubtitle,
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
                                      labelText: appLocalizations.username,
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
                                      labelText: appLocalizations.password,
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
                                    obscureText: _obscurePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    autofillHints: const [AutofillHints.newPassword],
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
