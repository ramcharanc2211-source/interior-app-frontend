import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = "${ApiConfig.baseUrl}/api";

  // GET Designers
  static Future<List> getDesigners() async {
    final response = await http.get(Uri.parse("$baseUrl/designers"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }

  // POST Booking
  static Future<Map?> bookDesigner(String designerId, String date) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/bookings"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"designerId": designerId, "date": date}),
      );

      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
