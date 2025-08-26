import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';
import 'home_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                // Dismiss keyboard when tapping outside text fields
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
                    // #051F20round image
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

                    // Top left decorative elements (lanterns)
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

                    // Bottom mosque silhouette
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
                                      MediaQuery.of(context).size.height * 0.12,
                                ),

                                // Title
                                Text(
                                  languageProvider.isArabic
                                      ? 'إنشاء حساب'
                                      : 'Sign Up',
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
                                      ? 'انضم لبدء رحلتك الروحية. تتبع ختمتك وذكرك والمزيد.'
                                      : 'Join to start your spiritual journey. Track your Khitma, Dhikr and more.',
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

                                // Email field
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.email],
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
                                          ? 'البريد الإلكتروني'
                                          : 'Email',
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
                                      AutofillHints.newPassword,
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
                                      MediaQuery.of(context).size.height * 0.04,
                                ),

                                // Sign Up button
                                SizedBox(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      final scaffold = ScaffoldMessenger.of(context);
                                      // Prompt simple dialog to collect name, email, password
                                      String? name;
                                      String? email;
                                      String? password;
                                      await showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (ctx) {
                                          final nameController = TextEditingController();
                                          final emailController = TextEditingController();
                                          final passController = TextEditingController();
                                          return AlertDialog(
                                            title: Text(languageProvider.isArabic ? 'إنشاء حساب' : 'Sign Up'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: nameController,
                                                  decoration: InputDecoration(
                                                    hintText: languageProvider.isArabic ? 'الاسم' : 'Name',
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller: emailController,
                                                  keyboardType: TextInputType.emailAddress,
                                                  decoration: InputDecoration(
                                                    hintText: languageProvider.isArabic ? 'البريد الإلكتروني' : 'Email',
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                TextField(
                                                  controller: passController,
                                                  obscureText: true,
                                                  decoration: InputDecoration(
                                                    hintText: languageProvider.isArabic ? 'كلمة المرور (8 أحرف على الأقل)' : 'Password (min 8 chars)',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                child: Text(languageProvider.isArabic ? 'إلغاء' : 'Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  name = nameController.text.trim();
                                                  email = emailController.text.trim();
                                                  password = passController.text.trim();
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Text(languageProvider.isArabic ? 'إنشاء' : 'Create'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if ((name ?? '').isEmpty || (email ?? '').isEmpty || (password ?? '').length < 8) {
                                        scaffold.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              languageProvider.isArabic
                                                  ? 'يرجى إدخال اسم وبريد إلكتروني صحيح وكلمة مرور لا تقل عن 8 أحرف'
                                                  : 'Please enter a valid name, email and a password of at least 8 characters',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      final resp = await ApiClient.instance.register(name: name!, email: email!, password: password!);
                                      if (!resp.ok) {
                                        scaffold.showSnackBar(
                                          SnackBar(content: Text(resp.error ?? (languageProvider.isArabic ? 'فشل إنشاء الحساب' : 'Sign up failed'))),
                                        );
                                        return;
                                      }
                                      final token = resp.data['token'] as String?;
                                      if (token == null) {
                                        scaffold.showSnackBar(
                                          SnackBar(content: Text(languageProvider.isArabic ? 'استجابة غير متوقعة من الخادم' : 'Unexpected server response')),
                                        );
                                        return;
                                      }
                                      await ApiClient.instance.saveToken(token);
                                      scaffold.showSnackBar(
                                        SnackBar(content: Text(languageProvider.isArabic ? 'تم إنشاء الحساب بنجاح' : 'Account created successfully')),
                                      );
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeProvider.buttonBackgroundColor,
                                      foregroundColor: themeProvider.buttonTextColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      languageProvider.isArabic ? 'إنشاء حساب' : 'Sign Up',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.045,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),

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
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        languageProvider.isArabic
                                            ? 'تسجيل الدخول'
                                            : 'Login',
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
