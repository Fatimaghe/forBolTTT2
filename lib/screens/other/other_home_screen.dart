import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/action_card.dart';
import 'contacts_screen.dart';
import 'timesheets_screen.dart';
import 'expenses_screen.dart';
import 'tasks_screen.dart';
import 'messaging_screen.dart';

class OtherHomeScreen extends StatelessWidget {
  const OtherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.other),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.additionalFeatures,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            ActionCard(
              title: l10n.contacts,
              subtitle: l10n.completeAddressBook,
              icon: Icons.contacts,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactsScreen()),
                );
              },
            ),
            
            ActionCard(
              title: l10n.timesheets,
              subtitle: l10n.workingTimeTracking,
              icon: Icons.access_time,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimesheetsScreen()),
                );
              },
            ),
            
            ActionCard(
              title: l10n.expenses,
              subtitle: l10n.addExpensesWithAttachments,
              icon: Icons.receipt_long,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExpensesScreen()),
                );
              },
            ),
            
            ActionCard(
              title: l10n.tasks,
              subtitle: l10n.actionPlanManagement,
              icon: Icons.task,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasksScreen()),
                );
              },
            ),
            
            ActionCard(
              title: l10n.messaging,
              subtitle: l10n.odooMessages,
              icon: Icons.message,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}