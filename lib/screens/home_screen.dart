import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_switcher.dart';
import 'crm/crm_home_screen.dart';
import 'sales/sales_home_screen.dart';
import 'invoicing/invoicing_home_screen.dart';
import 'inventory/inventory_home_screen.dart';
import 'other/contacts_screen.dart';
import 'other/timesheets_screen.dart';
import 'other/expenses_screen.dart';
import 'other/tasks_screen.dart';
import 'other/messaging_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CrmHomeScreen(),
    const SalesHomeScreen(),
    const InvoicingHomeScreen(),
    const InventoryHomeScreen(),
    const ContactsScreen(),
    const TimesheetsScreen(),
    const ExpensesScreen(),
    const TasksScreen(),
    const MessagingScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(titleKey: 'crm', color: Color(0xFF1F77B4)),
    NavigationItem(titleKey: 'sales', color: Color(0xFF2CA02C)),
    NavigationItem(titleKey: 'invoicing', color: Color(0xFFFF7F0E)),
    NavigationItem(titleKey: 'inventory', color: Color(0xFFD62728)),
    NavigationItem(titleKey: 'contacts', color: Color(0xFF9467BD)),
    NavigationItem(titleKey: 'timesheets', color: Color(0xFF8C564B)),
    NavigationItem(titleKey: 'expenses', color: Color(0xFFE377C2)),
    NavigationItem(titleKey: 'tasks', color: Color(0xFF7F7F7F)),
    NavigationItem(titleKey: 'messaging', color: Color(0xFFBCBD22)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) => _fallbackIcon(24),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF714B67),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LanguageSwitcher(),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      drawer: _buildSidebar(l10n),
      body: _screens[_selectedIndex],
    );
  }

  Widget _buildSidebar(AppLocalizations l10n) {
    return Drawer(
      child: SafeArea(
        top: false, // Remove default top padding so gradient covers the very top
        child: Column(
          children: [
            Container(
              height: 200 + MediaQuery.of(context).padding.top,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF714B67), Color(0xFF8F5A84)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20 + MediaQuery.of(context).padding.top,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 85, // or 120
                      height: 85,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => _fallbackIcon(50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle, 
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appSubtitle, 
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (int index = 0; index < _navigationItems.length; index++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedIndex == index ? _navigationItems[index].color.withOpacity(0.1) : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedIndex == index ? _navigationItems[index].color : _navigationItems[index].color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/icons/${_navigationItems[index].titleKey.toLowerCase()}.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getFallbackIcon(_navigationItems[index].titleKey),
                              color: _selectedIndex == index ? Colors.white : _navigationItems[index].color,
                              size: 24,
                            ),
                          ),
                        ),
                        title: Text(
                          _getLocalizedTitle(l10n, _navigationItems[index].titleKey),
                          style: TextStyle(
                            fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.w500,
                            color: _selectedIndex == index ? _navigationItems[index].color : Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        trailing: _selectedIndex == index ? Icon(Icons.arrow_forward_ios, color: _navigationItems[index].color, size: 16) : null,
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                ],
              ),
            ),
            // Language Switcher in Drawer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]!))),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF714B67).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.language, color: Color(0xFF714B67), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.language, 
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)
                        ),
                      ),
                      const LanguageSwitcher(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF714B67).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.settings, color: Color(0xFF714B67), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.settings, 
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTitle(AppLocalizations l10n, String titleKey) {
    switch (titleKey) {
      case 'crm': return l10n.crm;
      case 'sales': return l10n.sales;
      case 'invoicing': return l10n.invoicing;
      case 'inventory': return l10n.inventory;
      case 'contacts': return l10n.contacts;
      case 'timesheets': return l10n.timesheets;
      case 'expenses': return l10n.expenses;
      case 'tasks': return l10n.tasks;
      case 'messaging': return l10n.messaging;
      default: return titleKey;
    }
  }

  Widget _fallbackIcon(double size) => Container(
    padding: EdgeInsets.all(size / 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.business, color: Colors.white, size: size),
  );

  IconData _getFallbackIcon(String title) {
    switch (title.toLowerCase()) {
      case 'crm': return Icons.people_alt;
      case 'sales': return Icons.trending_up;
      case 'invoicing': return Icons.receipt_long;
      case 'inventory': return Icons.inventory_2;
      case 'contacts': return Icons.contacts;
      case 'timesheets': return Icons.access_time;
      case 'expenses': return Icons.receipt;
      case 'tasks': return Icons.task_alt;
      case 'messaging': return Icons.chat_bubble;
      default: return Icons.apps;
    }
  }
}

class NavigationItem {
  final String titleKey;
  final Color color;

  NavigationItem({required this.titleKey, required this.color});
}
