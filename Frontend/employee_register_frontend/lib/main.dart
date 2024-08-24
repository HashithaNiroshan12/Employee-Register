import 'package:employee_register_frontend/viewmodels/employee_list_viewmodel.dart';
import 'package:employee_register_frontend/views/employee_list_screen.dart';
import 'package:employee_register_frontend/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmployeeListViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Employee Register',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/employees': (context) => const EmployeeListScreen(),
        },
      ),
    );
  }
}
