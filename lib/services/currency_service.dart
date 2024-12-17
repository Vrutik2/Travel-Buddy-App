import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyService {
  static const String apiKey = '06342dae5f701f546da8ba30c193c74a';
  static const String baseUrl = 'http://apilayer.net/api';

  static const List<String> supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 
    'CAD', 'CHF', 'CNY', 'HKD', 'NZD', 'SGD'
  ];

  static const Map<String, String> currencySymbols = {
    'USD': '\$',    
    'EUR': '€',   
    'GBP': '£',     
    'JPY': '¥',    
    'AUD': 'A\$',   
    'CAD': 'C\$',  
    'CHF': 'Fr',   
    'CNY': '¥',    
    'HKD': 'HK\$', 
    'NZD': 'NZ\$',  
    'SGD': 'S\$',   
  };

  static const Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'HKD': 'Hong Kong Dollar',
    'NZD': 'New Zealand Dollar',
    'SGD': 'Singapore Dollar',
  };

  Future<Map<String, double>> getExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/live?access_key=$apiKey'
          '&currencies=${supportedCurrencies.join(",")}'
          '&source=USD&format=1'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, double>.from(data['quotes']);
        } else {
          throw Exception(data['error']['info'] ?? 'Failed to load exchange rates');
        }
      }
      throw Exception('Failed to load exchange rates: Status ${response.statusCode}');
    } catch (e) {
      print('Error fetching exchange rates: $e');
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  Future<Map<String, dynamic>> getHistoricalRates(DateTime date) async {
    try {
      final dateStr = date.toString().split(' ')[0];
      final response = await http.get(
        Uri.parse(
          '$baseUrl/historical'
          '?access_key=$apiKey'
          '&date=$dateStr'
          '&currencies=${supportedCurrencies.join(",")}'
          '&source=USD&format=1'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'date': data['date'],
            'rates': Map<String, double>.from(data['quotes']),
          };
        } else {
          throw Exception(data['error']['info'] ?? 'Failed to load historical rates');
        }
      }
      throw Exception('Failed to load historical rates: Status ${response.statusCode}');
    } catch (e) {
      print('Error fetching historical rates: $e');
      throw Exception('Error fetching historical rates: $e');
    }
  }

  Future<double?> convertCurrency(
    String from,
    String to,
    double amount,
    Map<String, double> rates,
  ) async {
    try {
      if (from == to) return amount;

      if (from == 'USD') {
        final rate = rates['USD$to'];
        if (rate == null) throw Exception('Rate not found for $to');
        return amount * rate;
      }

      if (to == 'USD') {
        final rate = rates['USD$from'];
        if (rate == null) throw Exception('Rate not found for $from');
        return amount / rate;
      }

      final fromRate = rates['USD$from'];
      final toRate = rates['USD$to'];
      if (fromRate == null || toRate == null) {
        throw Exception('Rate not found for $from or $to');
      }

      return amount * (toRate / fromRate);
    } catch (e) {
      print('Error converting currency: $e');
      return null;
    }
  }

  String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode] ?? currencyCode;
  }

  String getCurrencyName(String currencyCode) {
    return currencyNames[currencyCode] ?? currencyCode;
  }
}