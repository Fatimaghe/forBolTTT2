import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final l10n = AppLocalizations.of(context);
    
    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            languageService.getLanguageFlag(languageService.currentLocale),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      tooltip: l10n.selectLanguage,
      onSelected: (Locale locale) {
        languageService.changeLanguage(locale);
      },
      itemBuilder: (BuildContext context) {
        return languageService.supportedLocales.map((Locale locale) {
          final isSelected = languageService.currentLocale == locale;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(
                  languageService.getLanguageFlag(locale),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    languageService.getLanguageName(locale),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}