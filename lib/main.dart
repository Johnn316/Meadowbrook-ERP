import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/drift/app_database.dart';
import 'core/theme/theme_provider.dart';
import 'features/crm/contacts/data/contacts_provider.dart';
import 'features/crm/invoices/data/invoices_provider.dart';
import 'features/crm/leads/data/leads_provider.dart';
import 'features/farm/farms/data/farms_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ContactsProvider()),
        ChangeNotifierProvider(create: (_) => LeadsProvider()),
        ChangeNotifierProvider(create: (_) => InvoicesProvider()),
        ChangeNotifierProvider(create: (_) => FarmsProvider()),
      ],
      child: const ErpApp(),
    ),
  );
}
