import 'package:flutter/material.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/utils/logger.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  final String user_type;
  const LoginScreen({super.key, required this.user_type});
  

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

List<String> departments = [];
String? selectedDepartment;
bool isLoadingDepartments = false;




class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController enrollmentController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();

  void fetchDepartments() async {
      setState(() => isLoadingDepartments = true);
      try {
        // Fetch the list of departments from the server
        final response = await AuthService.getAllDepartments(); 
        setState(() {
          departments = response;
          selectedDepartment = departments.isNotEmpty ? departments.first : null;
        });
      } catch (e) {
        debugPrint('Failed to fetch departments: $e');
      } finally {
        setState(() => isLoadingDepartments = false);
      }
    }

  void requestOTP() async {
    String email = emailController.text.trim();
    String? enrollmentNumber = widget.user_type == 'student' ? enrollmentController.text.trim().toUpperCase() : null;
    //String? department = widget.user_type == 'student' ? null : departmentController.text.trim();
    // String? department = widget.user_type == 'faculty' || widget.user_type == 'admin' ? departments.isNotEmpty ? departments.first : selectedDepartment : null;
    String? department;

    if (widget.user_type == 'faculty' || widget.user_type == 'admin') {
      department = selectedDepartment;
    } 

      bool success = await AuthService.requestOTP(
      userType: widget.user_type,
      email: email,
      enrollmentNumber: enrollmentNumber,
      department: department,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(email: email, userType: widget.user_type),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  @override
  void initState() {
      super.initState();
      if (widget.user_type == 'faculty' || widget.user_type == 'admin') {
        fetchDepartments();
      }
    }

  @override
  Widget build(BuildContext context) {
    appLogger.w("🧾 LoginScreen opened for user_type: ${widget.user_type}");

    return Scaffold(
      appBar: AppBar(title: Text('Login as ${widget.user_type}')),
      body: Column(
        children: [
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          if (widget.user_type == 'student')
            TextField(controller: enrollmentController, decoration: const InputDecoration(labelText: 'Enrollment Number')),

          if (widget.user_type == 'faculty' || widget.user_type == 'admin')
         
            //TextField(controller: departmentController, decoration: const InputDecoration(labelText: 'Department')),
              DropdownButtonFormField<String>(
              value: selectedDepartment,
              items: departments.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Department'),
            ),

          ElevatedButton(onPressed: requestOTP, child: const Text('Request OTP'))
        ],
      ),
    );
  }
}
