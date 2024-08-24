import 'dart:io';
import 'package:employee_register_frontend/models/employee.dart';
// import 'package:employee_register_frontend/service/api_service.dart';
import 'package:employee_register_frontend/viewmodels/employee_list_viewmodel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeDetailsScreen({super.key, this.employee});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  late String _lastName;
  late String _email;
  File? _profileImage; // To store the picked image file

  Future<void> _pickImage() async {
    const typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      setState(() {
        _profileImage = File(file.path);
      });
    }
  }

  // Future<void> _uploadProfilePicture(int employeeId) async {
  //   if (_profileImage != null) {
  //     final apiService = ApiService();
  //     final response = await apiService.uploadProfilePicture(
  //         employeeId, _profileImage!.path);
  //     if (response.statusCode == 200) {
  //       //print('Profile picture uploaded successfully!');
  //       // Optionally handle any success response here
  //     } else {
  //       //print('Failed to upload profile picture: ${response.reasonPhrase}');
  //     }
  //   }
  // }

  
  Future<void> _downloadProfilePicture() async {
    final viewModel =
        Provider.of<EmployeeListViewModel>(context, listen: false);
    try {
      final profileImage =
          await viewModel.downloadProfilePicture(widget.employee!.id);

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
    if (widget.employee != null) {
      _firstName = widget.employee!.firstname!;
      _lastName = widget.employee!.lastname!;
      _email = widget.employee!.email!;
    } else {
      _firstName = '';
      _lastName = '';
      _email = '';
    }

    _downloadProfilePicture();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_profileImage != null) {
        final viewModel =
            Provider.of<EmployeeListViewModel>(context, listen: false);
        viewModel.uploadProfilePicture(
            widget.employee!.id, _profileImage!.toString());
      }

      final newEmployee = Employee(
        id: widget.employee?.id ?? 0, // ID for new employee
        firstname: _firstName,
        lastname: _lastName,
        email: _email,
        profilePicturePath: _profileImage != null
            ? _profileImage!.path
            : widget.employee?.profilePicturePath ?? '',
      );

      final viewModel =
          Provider.of<EmployeeListViewModel>(context, listen: false);
      if (widget.employee == null) {
        viewModel.createEmployee(newEmployee);
      } else {
        viewModel.updateEmployee(newEmployee.id, newEmployee);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee == null ? 'Add Employee' : 'Edit Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? Image.file(_profileImage!).image
                      : const AssetImage('assets/images/user.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _firstName = value!;
                },
              ),
              TextFormField(
                initialValue: _lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _lastName = value!;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.employee == null
                    ? 'Add Employee'
                    : 'Update Employee'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
