import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'dhikr_provider.dart';
import 'dart:math';
import 'services/api_client.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_localizations.dart';

class StartDhikrScreen extends StatefulWidget {
  final String dhikrTitle;
  final String dhikrTitleArabic;
  final String dhikrSubtitle;
  final String dhikrSubtitleArabic;
  final String dhikrArabic;
  final int target;
  final bool isGroupMode;
  final int? groupId;
  final int? initialCount;

  const StartDhikrScreen({
    super.key,
    required this.dhikrTitle,
    required this.dhikrTitleArabic,
    required this.dhikrSubtitle,
    required this.dhikrSubtitleArabic,
    required this.dhikrArabic,
    required this.target,
    this.isGroupMode = false,
    this.groupId,
    this.initialCount,
  });

  @override
  State<StartDhikrScreen> createState() => _StartDhikrScreenState();
}

class _StartDhikrScreenState extends State<StartDhikrScreen> with WidgetsBindingObserver {
  int _currentCount = 0;
  int _lastSavedCount = 0;
  bool _autoCompleted = false;
  bool _draftSaving = false;

  void _incrementCounter() {
    if (_currentCount < widget.target) {
      setState(() {
        _currentCount++;
      });
      // Auto-complete on reaching target (personal or group)
      if (!_autoCompleted && _currentCount >= widget.target) {
        _autoCompleted = true;
        _autoCompleteAndExit();
      }
    }
  }

  void _decrementCounter() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
    }
  }

  void _resetCounter() {
    setState(() {
      _currentCount = 0;
    });
  }

  Future<void> _saveDhikr() async {
    final app = AppLocalizations.of(context)!;

    if (widget.isGroupMode && widget.groupId != null) {
      // Save only the delta (new taps since last save) to avoid double counting
      final delta = _currentCount - _lastSavedCount;
      if (delta > 0) {
        final resp = await ApiClient.instance.saveDhikrGroupProgress(widget.groupId!, delta);
        if (!mounted) return;
        if (resp.ok) {
          _lastSavedCount = _currentCount;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(app.savedToGroup)),
          );
          Navigator.pop(context, true);
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp.error ?? app.saveFailed)),
          );
        }
      } else {
        // Nothing new to save; just exit
        Navigator.pop(context, true);
      }
      return;
    }

    final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
    await dhikrProvider.saveDhikr(
      title: widget.dhikrTitle,
      titleArabic: widget.dhikrTitleArabic,
      subtitle: widget.dhikrSubtitle,
      subtitleArabic: widget.dhikrSubtitleArabic,
      arabic: widget.dhikrArabic,
      target: widget.target,
      currentCount: _currentCount,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(app.dhikrSaved)),
    );
    Navigator.pop(context, true);
  }

  // Auto-complete flow upon reaching target
  Future<void> _autoCompleteAndExit() async {
    final app = AppLocalizations.of(context)!;

    if (widget.isGroupMode && widget.groupId != null) {
      final delta = widget.target - _lastSavedCount;
      if (delta > 0) {
        final resp = await ApiClient.instance.saveDhikrGroupProgress(widget.groupId!, delta);
        if (!mounted) return;
        if (!resp.ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp.error ?? app.saveFailed)),
          );
          Navigator.pop(context, true);
          return;
        }
        _lastSavedCount = widget.target;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.dhikrCompletedCongrats)),
      );
      Navigator.pop(context, true);
      return;
    }

    final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);

    // Persist completion at target count
    await dhikrProvider.saveDhikr(
      title: widget.dhikrTitle,
      titleArabic: widget.dhikrTitleArabic,
      subtitle: widget.dhikrSubtitle,
      subtitleArabic: widget.dhikrSubtitleArabic,
      arabic: widget.dhikrArabic,
      target: widget.target,
      currentCount: widget.target,
    );

    if (!mounted) return;
    // Show localized congratulations
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(app.dhikrCompletedCongrats)),
    );

    // Navigate back to Dhikr screen
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialCount != null) {
      _currentCount = widget.initialCount!.clamp(0, widget.target);
      _lastSavedCount = widget.initialCount!.clamp(0, widget.target);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // ignore: discarded_futures
      _autoSaveDraftIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _autoSaveDraftIfNeeded();
        return true;
      },
      child: Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isLightMode = !themeProvider.isDarkMode;
        final isArabic = languageProvider.isArabic;
        final amiriFont = isArabic ? 'Amiri' : null;

        // Theme colors
        final greenColor = const Color(0xFF2E7D32);
        final creamColor = const Color(0xFFF5F5DC);
        final textColor = isLightMode ? greenColor : creamColor;

        // 🌸 Select correct flower asset
        final flowerAsset = isLightMode
            ? 'assets/background_elements/Flower.png'
            : 'assets/background_elements/purpleFlower.png';

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  // Background SVG overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: themeProvider.isDarkMode ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        colorFilter: isLightMode ? const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn) : null,
                      ),
                    ),
                  ),
                  // Color overlay for dark mode only
                  if (!isLightMode)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await _autoSaveDraftIfNeeded();
                                  if (mounted) Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back, color: textColor),
                              ),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.dhikr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontFamily: amiriFont,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance the back button
                            ],
                          ),
                        ),
                        // Descriptive text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            AppLocalizations.of(context)!.dhikrIntro,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.8),
                              fontFamily: amiriFont,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Dhikr Card (cream with four corner decorations)
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final s = constraints.maxWidth / 408.0;
                                    final corner = 50 * s;
                                    final offset = 0 * s;
                                    return Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: isLightMode ? const Color(0xFFDAF1DE) : const Color(0xFFF7F3E8),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isLightMode ? const Color(0xFFB6D1C2) : const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              top: offset,
                                              left: offset,
                                              child: Image.asset(
                                                flowerAsset,
                                                width: corner,
                                                height: corner,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.medium,
                                              ),
                                            ),
                                            Positioned(
                                              top: offset,
                                              right: offset,
                                              child: Transform.rotate(
                                                angle: pi / 2,
                                                child: Image.asset(
                                                  flowerAsset,
                                                  width: corner,
                                                  height: corner,
                                                  fit: BoxFit.contain,
                                                  filterQuality: FilterQuality.medium,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: offset,
                                              left: offset,
                                              child: Transform.rotate(
                                                angle: -pi / 2,
                                                child: Image.asset(
                                                  flowerAsset,
                                                  width: corner,
                                                  height: corner,
                                                  fit: BoxFit.contain,
                                                  filterQuality: FilterQuality.medium,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: offset,
                                              right: offset,
                                              child: Transform.rotate(
                                                angle: pi,
                                                child: Image.asset(
                                                  flowerAsset,
                                                  width: corner,
                                                  height: corner,
                                                  fit: BoxFit.contain,
                                                  filterQuality: FilterQuality.medium,
                                                ),
                                              ),
                                            ),
                                            // Center the card content both vertically and horizontally
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(24),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      widget.dhikrArabic,
                                                      style: TextStyle(
                                                        fontSize: 32,
                                                        fontFamily: 'Amiri',
                                                        color: isLightMode ? const Color(0xFF1F1F1F) : const Color(0xFF392852),
                                                        height: 1.5,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                      textDirection: TextDirection.rtl,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      isArabic ? widget.dhikrTitleArabic : widget.dhikrTitle,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: isLightMode ? const Color(0xFF1F1F1F) : const Color(0xFF392852),
                                                        fontFamily: amiriFont,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      isArabic ? widget.dhikrSubtitleArabic : widget.dhikrSubtitle,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isLightMode ? const Color(0xFF1F1F1F).withOpacity(0.7) : const Color(0xFF392852).withOpacity(0.7),
                                                        fontFamily: amiriFont,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 40),
                                // Counter
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isLightMode ? const Color(0xFF235347) : Color(0xFFF2EDE0),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: _decrementCounter,
                                        icon: Icon(
                                          Icons.remove,
                                          color: isLightMode ? Colors.white : const Color(0xFF392852),
                                          size: 24,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Text(
                                      _currentCount.toString(),
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: isLightMode ? const Color(0xFF1F1F1F) : Color(0xFFF2EDE0),
                                        fontFamily: amiriFont,
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isLightMode ? const Color(0xFF235347) : Color(0xFFF2EDE0),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: _incrementCounter,
                                        icon: Icon(
                                          Icons.add,
                                          color: isLightMode ? Colors.white : const Color(0xFF392852),
                                          size: 24,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                // Action buttons
                                Column(
                                  children: [
                                    // Save Dhikr button
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isLightMode ? const Color(0xFF235347) : Color(0xFFF2EDE0),
                                        foregroundColor: isLightMode ? Colors.white : const Color(0xFF392852),
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: _saveDhikr,
                                      child: Text(
                                        AppLocalizations.of(context)!.saveDhikr,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: amiriFont,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Reset button (hide in group mode)
                                    if (!widget.isGroupMode)
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: isLightMode ? const Color(0xFF235347) : Color(0xFFF2EDE0),
                                            width: 1.5,
                                          ),
                                          foregroundColor: isLightMode ? const Color(0xFF235347) : Color(0xFFF2EDE0),
                                          minimumSize: const Size.fromHeight(48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        ),
                                        onPressed: _resetCounter,
                                        child: Text(
                                          AppLocalizations.of(context)!.reset,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: isLightMode ? const Color(0xFF235347) : Color(0xFFF2EDE0),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: amiriFont,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }

// Best-effort auto-save of personal or group dhikr draft (skips after auto-complete)
  Future<void> _autoSaveDraftIfNeeded() async {
    if (_autoCompleted) return;
    if (_currentCount < 0) return;
    // Avoid concurrent saves
    if (_draftSaving) return;
    _draftSaving = true;
    try {
      if (widget.isGroupMode && widget.groupId != null) {
        final delta = _currentCount - _lastSavedCount;
        if (delta > 0) {
          final resp = await ApiClient.instance.saveDhikrGroupProgress(widget.groupId!, delta);
          if (resp.ok) {
            _lastSavedCount = _currentCount;
          }
        }
      } else {
        final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
        await dhikrProvider.saveDhikr(
          title: widget.dhikrTitle,
          titleArabic: widget.dhikrTitleArabic,
          subtitle: widget.dhikrSubtitle,
          subtitleArabic: widget.dhikrSubtitleArabic,
          arabic: widget.dhikrArabic,
          target: widget.target,
          currentCount: _currentCount,
        );
      }
    } catch (_) {
      // ignore any errors during background save
    } finally {
      _draftSaving = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Final safety save on dispose
    // ignore: discarded_futures
    _autoSaveDraftIfNeeded();
    super.dispose();
  }
}
