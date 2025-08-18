import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'forgetpass_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.06,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.10,
                                ),
                                // Title
                                Text(
                                  languageProvider.isArabic
                                      ? 'تسجيل الدخول'
                                      : 'Login',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                        0.08,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.primaryTextColor,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                // Subtitle
                                Text(
                                  languageProvider.isArabic
                                      ? 'مرحبًا بعودتك. واصل طريقك في الذكر والتأمل والعبادة بسهولة.'
                                      : 'Welcome back. Continue your path of remembrance, reflection, and worship with ease.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                        0.04,
                                    color: themeProvider.secondaryTextColor,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                ),
                                // Username field
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    autofillHints: const [],
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    style: TextStyle(
                                      color: themeProvider.primaryTextColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: languageProvider.isArabic
                                          ? 'اسم المستخدم'
                                          : 'Username',
                                      labelStyle: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.04,
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
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                            0.05,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                // Password field
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    obscureText: true,
                                    keyboardType: TextInputType.visiblePassword,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    enableSuggestions: true,
                                    autocorrect: false,
                                    style: TextStyle(
                                      color: themeProvider.primaryTextColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: languageProvider.isArabic
                                          ? 'كلمة المرور'
                                          : 'Password',
                                      labelStyle: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.04,
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
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                            0.05,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                            0.02,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.012,
                                ),
                                // Forget Password link
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgetPassScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          themeProvider.secondaryTextColor,
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      languageProvider.isArabic
                                          ? 'نسيت كلمة المرور؟'
                                          : 'Forget Password?',
                                      style: TextStyle(
                                        color: themeProvider.secondaryTextColor,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.038,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.025,
                                ),
                                // Login button
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HomeScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          themeProvider.buttonBackgroundColor,
                                      foregroundColor:
                                          themeProvider.buttonTextColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      languageProvider.isArabic
                                          ? 'تسجيل الدخول'
                                          : 'Login',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.045,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
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
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.04,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        languageProvider.isArabic
                                            ? 'إنشاء حساب'
                                            : 'Sign Up',
                                        style: TextStyle(
                                          color: themeProvider.primaryTextColor,
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.04,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
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
