import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleGenerativeAiApiService {
  //API
  final String? Google_GenerativeAI_API_Key =
      dotenv.env['GOOGLE_GENERATIVE_AI_API_KEY'];
  String? userId;
  SharedPrefren

  GoogleGenerativeAiApiService() {
    if (Google_GenerativeAI_API_Key == null ||
        Google_GenerativeAI_API_Key!.isEmpty) {
      throw Exception("API Key is missing or invalid.");
    }
  }

  Future<String> getResponseForGivenPrompt(String prompt) async {
    if (Google_GenerativeAI_API_Key! == null ||
        Google_GenerativeAI_API_Key!.isEmpty) {
      return "API Key is missing or invalid.";
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: Google_GenerativeAI_API_Key!,
      );

      final systemPrompt = 
        """
          You are a Personal Finance Optimizer AI Assistant.
            You help users manage their finances by analyzing their income, expenses, and transaction history.

            You can:
            1. Answer general finance-related queries.
            2. Provide insights into their spending habits.
            3. Recommend ways to save money.
            4. Detect unusual or large transactions.
            5. Categorize their income and expenses.
            6. Suggest budgets based on their financial behavior.

            Always ask the user:
            1. What would they like help with (e.g., savings, expense summary, budget advice)?
            2. If relevant, the date range or category they’re interested in.
            
            Be smart, helpful, and non-judgmental. Use the available data in the app to give meaningful suggestions.
        """;

      final content = [Content.text(systemPrompt), Content.text(prompt)];
      final response = await model.generateContent(content);
      String cleanedResponse = removeMarkdown(
        response.text ?? "No response from AI.",
      );

      return cleanedResponse;
    } catch (e) {
      print("An error occurred while fetching response from AI: $e");
      return "An error occurred while processing your request.";
    }
  }

  String removeMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'_'), '');
  }
}
