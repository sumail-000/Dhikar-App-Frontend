import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'services/api_client.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  // Steps: 0 = email entry, 1 = code entry, 2 = new password
  int _step = 0;
  String _email = '';
  String _code = '';

  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocus = List.generate(6, (_) => FocusNode());
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocus) {
      f.dispose();
    }
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _sendCode(LanguageProvider lang) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack(
        context,
        lang.isArabic ? 'يرجى إدخال بريد إلكتروني صالح' : 'Please enter a valid email',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.forgotPassword(email: email);
      if (resp.ok) {
        setState(() {
          _email = email;
          _step = 1;
        });
        _showSnack(
          context,
          lang.isArabic
              ? 'تم إرسال رمز إعادة التعيين إلى بريدك الإلكتروني'
              : 'A reset code has been sent to your email',
        );
      } else {
        _showSnack(
          context,
          resp.error ?? (lang.isArabic ? 'تعذر إرسال الرمز' : 'Failed to send code'),
        );
      }
    } catch (_) {
      _showSnack(
        context,
        lang.isArabic ? 'خطأ في الشبكة. يرجى المحاولة لاحقًا.' : 'Network error. Please try again later.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode(LanguageProvider lang) async {
    final code = _codeControllers.map((c) => c.text.trim()).join();
    if (code.length != 6) {
      _showSnack(
        context,
        lang.isArabic ? 'يرجى إدخال رمز مكون من 6 أرقام' : 'Please enter the 6-digit code',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.verifyCode(email: _email, code: code);
      if (resp.ok) {
        setState(() {
          _code = code;
          _step = 2;
        });
        _showSnack(
          context,
          lang.isArabic ? 'تم التحقق من الرمز' : 'Code verified',
        );
      } else {
        _showSnack(
          context,
          resp.error ?? (lang.isArabic ? 'رمز غير صالح' : 'Invalid code'),
        );
      }
    } catch (_) {
      _showSnack(
        context,
        lang.isArabic ? 'خطأ في الشبكة. يرجى المحاولة لاحقًا.' : 'Network error. Please try again later.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword(LanguageProvider lang) async {
    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pass.length < 8) {
      _showSnack(
        context,
        lang.isArabic ? 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل' : 'Password must be at least 8 characters',
      );
      return;
    }
    if (pass != confirm) {
      _showSnack(
        context,
        lang.isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await ApiClient.instance.resetPassword(
        email: _email,
        code: _code,
        password: pass,
        passwordConfirmation: confirm,
      );
      if (resp.ok) {
        _showSnack(
          context,
          lang.isArabic ? 'تم إعادة تعيين كلمة المرور' : 'Password has been reset',
        );
        if (mounted) Navigator.pop(context);
      } else {
        _showSnack(
          context,
          resp.error ?? (lang.isArabic ? 'تعذر إعادة تعيين كلمة المرور' : 'Failed to reset password'),
        );
      }
    } catch (_) {
      _showSnack(
        context,
        lang.isArabic ? 'خطأ في الشبكة. يرجى المحاولة لاحقًا.' : 'Network error. Please try again later.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildHeader(ThemeProvider themeProvider, LanguageProvider lang) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF205C3B),
            size: 20,
          ),
        ),
        Expanded(
          child: Text(
            lang.isArabic ? 'نسيت كلمة المرور' : 'Forget Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildSubtitle(ThemeProvider themeProvider, LanguageProvider lang) {
    final color = themeProvider.isDarkMode ? const Color(0xFFF7F3E8).withOpacity(0.8) : const Color(0xFF205C3B).withOpacity(0.8);
    String text;
    if (_step == 0) {
      text = lang.isArabic
          ? 'هل نسيت كلمة المرور؟ لا تقلق، أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.'
          : "Forgot your password? Enter your email and we'll send you a verification code.";
    } else if (_step == 1) {
      text = lang.isArabic
          ? 'أدخل الرمز المكون من 6 أرقام الذي أُرسل إلى بريدك الإلكتروني'
          : 'Enter the 6-digit code sent to your email';
    } else {
      text = lang.isArabic
          ? 'أدخل كلمة المرور الجديدة وقم بتأكيدها'
          : 'Enter your new password and confirm it';
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: 14),
    );
  }

  Widget _buildEmailInput(ThemeProvider themeProvider, LanguageProvider lang) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFFB9A9D0).withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode ? const Color(0xFFB9A9D0).withOpacity(0.35) : const Color(0xFFB6D1C2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: lang.isArabic ? 'البريد الإلكتروني' : 'Email',
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8).withOpacity(0.7) : const Color(0xFF205C3B).withOpacity(0.7),
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : () => _sendCode(lang),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
              foregroundColor: themeProvider.isDarkMode ? const Color(0xFF2D1B69) : const Color(0xFFF7F3E8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(lang.isArabic ? 'إرسال الرمز' : 'Send Code', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBox(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 46,
          child: TextField(
            controller: _codeControllers[i],
            focusNode: _codeFocus[i],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: isDark ? const Color(0xFFF7F3E8) : const Color(0xFF2D1B69),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: isDark ? const Color(0xFFB9A9D0).withOpacity(0.18) : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFFB9A9D0).withOpacity(0.35) : const Color(0xFFB6D1C2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
                  width: 2,
                ),
              ),
            ),
            onChanged: (val) {
              if (val.length == 1 && i < 5) {
                _codeFocus[i + 1].requestFocus();
              }
              if (val.isEmpty && i > 0) {
                _codeFocus[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildCodeInput(ThemeProvider themeProvider, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCodeBox(themeProvider),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : () => _verifyCode(lang),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
              foregroundColor: themeProvider.isDarkMode ? const Color(0xFF2D1B69) : const Color(0xFFF7F3E8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(lang.isArabic ? 'تحقق من الرمز' : 'Verify Code', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPassword(ThemeProvider themeProvider, LanguageProvider lang) {
    return Column(
      children: [
        // Password
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFFB9A9D0).withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode ? const Color(0xFFB9A9D0).withOpacity(0.35) : const Color(0xFFB6D1C2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: TextStyle(
              color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: lang.isArabic ? 'كلمة المرور الجديدة' : 'New Password',
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8).withOpacity(0.7) : const Color(0xFF205C3B).withOpacity(0.7),
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Confirm
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFFB9A9D0).withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode ? const Color(0xFFB9A9D0).withOpacity(0.35) : const Color(0xFFB6D1C2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _confirmController,
            obscureText: true,
            style: TextStyle(
              color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: lang.isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
              hintStyle: TextStyle(
                color: themeProvider.isDarkMode ? const Color(0xFFF7F3E8).withOpacity(0.7) : const Color(0xFF205C3B).withOpacity(0.7),
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _loading ? null : () => _resetPassword(lang),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.isDarkMode ? const Color(0xFFF7F3E8) : const Color(0xFF205C3B),
              foregroundColor: themeProvider.isDarkMode ? const Color(0xFF2D1B69) : const Color(0xFFF7F3E8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(lang.isArabic ? 'إعادة تعيين كلمة المرور' : 'Reset Password', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
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
                  // Decorations
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
                  // Main content
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.06,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildHeader(themeProvider, languageProvider),
                            const SizedBox(height: 12),
                            _buildSubtitle(themeProvider, languageProvider),
                            const SizedBox(height: 24),
                            if (_step == 0)
                              _buildEmailInput(themeProvider, languageProvider)
                            else if (_step == 1)
                              _buildCodeInput(themeProvider, languageProvider)
                            else
                              _buildNewPassword(themeProvider, languageProvider),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
