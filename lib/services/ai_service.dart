import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = "AIzaSyAICkcGahdxHzUpymXj1ELVa1r5RmisY30";

  static Future<String> getResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(
          ("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey"),
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "You are a compassionate mental health assistant. Provide supportive, empathetic responses. User says: $prompt",
                },
              ],
            },
          ],
          "generationConfig": {"temperature": 0.7, "maxOutputTokens": 500},
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text']
              .toString()
              .trim();
        } else {
          return "I'm here to help, but couldn't generate a response right now. Please try again.";
        }
      } else {
        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        return "Error: Failed to get response - Status: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
