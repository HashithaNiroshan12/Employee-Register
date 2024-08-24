import 'dart:io';

import 'package:employee_register_frontend/models/employee.dart';
import 'package:employee_register_frontend/views/employee_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/employee_list_viewmodel.dart';

class EmployeeListScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeListScreen({super.key, this.employee });

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  File? _profileImage;

  Future<void> _downloadProfilePicture() async {
    final viewModel =
        Provider.of<EmployeeListViewModel>(context, listen: false);
    try {
      final profileImage =
          await viewModel.downloadProfilePicture(widget.employee!.id );

      setState(() {
        _profileImage = profileImage;
      });
    } catch (e) {
      //print('Failed to download profile picture: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _downloadProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeeListViewModel()..fetchEmployees(),
      child: Consumer<EmployeeListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Employees'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => viewModel.fetchEmployees(),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: viewModel.employees.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: viewModel.employees.length,
                      itemBuilder: (context, index) {
                        final employee = viewModel.employees[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: _profileImage != null
                                  ? Image.file(_profileImage!).image
                                  : const AssetImage('assets/images/user.png')
                                      as ImageProvider,
                            ),
                            title: Text(
                              '${employee.firstname} ${employee.lastname}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(employee.email.toString()),
                            trailing: PopupMenuButton<String>(
                              onSelected: (String value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EmployeeDetailsScreen(
                                        employee: employee,
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  viewModel.deleteEmployee(employee.id);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployeeDetailsScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
