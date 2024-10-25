import 'package:http/http.dart' as http; // HTTP client for making requests
import 'dart:convert'; 
import 'globalip.dart';// For JSON encoding/decoding

class AuthService {
  final String baseUrl = 'http://$globalP'; // Replace with your server URL

  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Parse the response body to check for success
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      // Server returned an error status code
      print('Server error: ${response.statusCode}');
      return {"message": "Server error"};
    }
  }
}
