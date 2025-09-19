import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'app_localizations.dart';
import 'dhikr_provider.dart';
import 'start_dhikr_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalDhikrHistoryScreen extends StatelessWidget {
  const PersonalDhikrHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, theme, lang, _) {
        final app = AppLocalizations.of(context)!;
        final isLight = !theme.isDarkMode;
        return Directionality(
          textDirection: lang.textDirection,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: theme.isDarkMode
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF251629), Color(0xFF4C3B6E)],
                      )
                    : null,
                color: theme.isDarkMode ? null : theme.screenBackgroundColor,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: theme.isDarkMode ? 0.03 : 0.12,
                      child: SvgPicture.asset(
                        'assets/background_elements/3_background.svg',
                        fit: BoxFit.cover,
                        colorFilter: theme.isDarkMode
                            ? null
                            : const ColorFilter.mode(Color(0xFF8EB69B), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  if (theme.isDarkMode)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.2)),
                    ),
                  SafeArea(
                    child: Consumer<DhikrProvider>(
                      builder: (context, provider, __) {
                        final ongoing = provider.ongoing;
                        final done = provider.completed;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.arrow_back, color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      app.dhikr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    app.personalKhitma, // reuse label style
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: ongoing.isEmpty && done.isEmpty
                                        ? null
                                        : () async {
                                            await provider.clearHistory();
                                          },
                                    child: Text(
                                      app.delete, // Clear
                                      style: TextStyle(
                                        color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                              child: _AggregateBar(
                                current: provider.aggregateCurrent,
                                target: provider.aggregateTarget,
                                isLight: isLight,
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                children: [
                                  if (ongoing.isNotEmpty)
                                    _SectionTitle(title: app.inProgress, isLight: isLight),
                                  ...ongoing.map((e) => _DhikrCard(entry: e, isLight: isLight)),
                                  if (done.isNotEmpty)
                                    _SectionTitle(title: app.completed, isLight: isLight),
                                  ...done.map((e) => _DhikrCard(entry: e, isLight: isLight)),
                                  if (ongoing.isEmpty && done.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Center(
                                        child: Text(
                                          app.noContentToDisplay,
                                          style: TextStyle(color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0)),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isLight;
  const _SectionTitle({required this.title, required this.isLight});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0),
            ),
          ),
        ],
      ),
    );
  }
}

class _AggregateBar extends StatelessWidget {
  final int current;
  final int target;
  final bool isLight;
  const _AggregateBar({required this.current, required this.target, required this.isLight});
  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? current / target : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFDAF1DE) : const Color(0xFFE3D9F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isLight ? const Color(0xFFB6D1C2) : Colors.transparent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isLight ? const Color(0xFFB6D1C2) : const Color(0xFFB9A9D0).withOpacity(0.35),
            color: isLight ? const Color(0xFF235347) : const Color(0xFFF2EDE0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            '$current / $target',
            style: TextStyle(
              color: isLight ? const Color(0xFF235347) : const Color(0xFF392852),
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  final DhikrData entry;
  final bool isLight;
  const _DhikrCard({required this.entry, required this.isLight});
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final title = lang.isArabic ? entry.titleArabic : entry.title;
    final subtitle = lang.isArabic ? entry.subtitleArabic : entry.subtitle;
    final canContinue = entry.status != 'completed' && entry.currentCount < entry.target;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFDAF1DE) : const Color(0xFFE3D9F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isLight ? const Color(0xFFB6D1C2) : Colors.transparent, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isLight ? const Color(0xFF235347) : const Color(0xFF392852))),
                const SizedBox(height: 2),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: TextStyle(color: isLight ? const Color(0xFF235347).withOpacity(0.7) : const Color(0xFF392852).withOpacity(0.8))),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: entry.progress.clamp(0.0, 1.0),
                  backgroundColor: isLight ? const Color(0xFFB6D1C2) : const Color(0xFFB9A9D0).withOpacity(0.35),
                  color: isLight ? const Color(0xFF235347) : const Color(0xFF392852),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Text('${entry.currentCount} / ${entry.target}', style: TextStyle(color: isLight ? const Color(0xFF235347) : const Color(0xFF392852)))
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canContinue)
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartDhikrScreen(
                      dhikrTitle: entry.title,
                      dhikrTitleArabic: entry.titleArabic,
                      dhikrSubtitle: entry.subtitle,
                      dhikrSubtitleArabic: entry.subtitleArabic,
                      dhikrArabic: entry.arabic,
                      target: entry.target,
                      initialCount: entry.currentCount,
                      entryId: entry.id,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: isLight ? const Color(0xFF235347) : const Color(0xFF392852),
                foregroundColor: isLight ? Colors.white : const Color(0xFFF2EDE0),
              ),
child: Text(AppLocalizations.of(context)!.continueDhikr),
            ),
        ],
      ),
    );
  }
}
