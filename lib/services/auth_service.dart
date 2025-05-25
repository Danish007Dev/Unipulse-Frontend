import 'package:dio/dio.dart';
import '../../utils/logger.dart';
import '../../services/dio_client.dart';
import '../../services/api_config.dart';


class AuthService {

  static final Dio _dio = DioClient().client;

  static Future<bool> requestOTP({
    required String userType,
    required String email,
    String? enrollmentNumber,
    String? department,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.requestOtp,
        data: {
          'user_type': userType,
          'email': email,
          if (enrollmentNumber != null) 'enrollment_number': enrollmentNumber,
          if (department != null) 'department': department,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      appLogger.e('OTP request failed: $e');
      return false;
    }
  }

  static Future<Map<String, String>?> verifyOTP({
    required String email,
    required String otp,
    required String userType,
  }) async {
    try {
      final response = await _dio.post(ApiConfig.verifyOtp, data: {
        'email': email,
        'otp': otp,
        'user_type': userType,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        
        
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        appLogger.i('🧪 OTP verified successfully:');
        appLogger.i('🪪 accessToken: $accessToken');
        appLogger.i('🔁 refreshToken: $refreshToken');
        appLogger.i('👤 userType: $userType');
        appLogger.i('📧 email: $email');

        return {
          'accessToken': data['access_token'],
          'refreshToken': data['refresh_token'],
          'user_type': userType,
          'email': email,
        };
      } else {
        appLogger.w('OTP verification failed: ${response.data}');
        return null;
      }
    } catch (e) {
      appLogger.e('Error verifying OTP: $e');
      return null;
    }
  }

  static Future<List<String>> getAllDepartments() async {
  // final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000'; 
  try {
    // final response = await _dio.get('$baseUrl/views/departments/');
    final response = await _dio.get(ApiConfig.departments);
   
      if (response.statusCode == 200) {
        return List<String>.from(response.data.map((item) => item['name']));
      } else {
        appLogger.w('Failed to load departments: ${response.data}');
        return [];
      }
    } catch (e) {
      appLogger.e('Error fetching departments: $e');
      return [];  
    }
  }
  // Be mindful of using .contains() vs exact match. If your route was dynamic like /views/departments/1/,
  // using .contains('/views/departments/') would still work. But since you're likely using a flat GET endpoint like /views/departments/, this is fine.
}


  // WORKING FUNCTION 
  // static Future<List<String>> getAllDepartments() async {
  // final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000'; 
  // try {
  //   final response = await _dio.get('$baseUrl/views/departments/');
  //   
   
  //     if (response.statusCode == 200) {
  //       return List<String>.from(response.data.map((item) => item['name']));
  //     } else {
  //       appLogger.w('Failed to load departments: ${response.data}');
  //       return [];
  //     }
  //   } catch (e) {
  //     appLogger.e('Error fetching departments: $e');
  //     return [];  
  //   }
  // }
















// import 'dart:convert';
// //import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import '../../utils/token_manager.dart';
// import '../models/post.dart';
// import 'dio_client.dart';
// import '../../utils/logger.dart';
// //import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class ApiService {
//   static const String baseUrl = "http://127.0.0.1:8000";

//   // Request OTP
//   static Future<bool> requestOTP({
//   required String userType, // Fix field name
//   required String email,
//   String? enrollmentNumber, // Fix field name
//   String? department,
// }) async {
//   final response = await http.post(
//     Uri.parse('$baseUrl/views/request-otp/'), // Ensure correct URL
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({
//       'user_type': userType, // Correct field
//       'email': email,
//       if (enrollmentNumber != null) 'enrollment_number': enrollmentNumber, // Correct field
//       if (department != null) 'department': department,
      
//     }),
//   );
  

//   print("Status Code: ${response.statusCode}");
//   print("Response Body: ${response.body}");

//   return response.statusCode == 200;
// }


// static Future<Map<String, String>?> verifyOTP({
//   required String email,
//   required String otp,
//   required String userType, // NEW PARAM
// }) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/views/verify-otp/'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'email': email,
//         'otp': otp,
//         'user_type': userType, // 🟢 Include user_type here
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
      
//       final accessToken = data['access_token'];
//       final refreshToken = data['refresh_token'];
//       await TokenManager.saveTokens(accessToken, refreshToken, userType);


//       return {
//         'accessToken': data['access_token'],
//         'refreshToken': data['refresh_token'],
//       };
//     } else {
//       debugPrint("OTP verification failed: ${response.body}");
//       return null;
//     }
//   } catch (e) {
//     debugPrint("Error verifying OTP: $e");
//     return null;
//   }
// }
// }