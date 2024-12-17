import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/currency_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController();
  
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double? _result;
  bool _isLoading = false;
  Map<String, double>? _exchangeRates;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    setState(() => _isLoading = true);
    try {
      _exchangeRates = await _currencyService.getExchangeRates();
      _lastUpdated = DateTime.now();
      _convert();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exchange rates: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _convert() {
    if (_amountController.text.isEmpty || _exchangeRates == null) {
      setState(() => _result = null);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() => _result = null);
      return;
    }

    // Since API always returns USD based rates, we need to calculate cross-rates
    if (_fromCurrency == 'USD') {
      final rate = _exchangeRates!['USD$_toCurrency'] ?? 1.0;
      setState(() => _result = amount * rate);
    } else if (_toCurrency == 'USD') {
      final rate = _exchangeRates!['USD$_fromCurrency'] ?? 1.0;
      setState(() => _result = amount / rate);
    } else {
      // Cross rate calculation
      final fromRate = _exchangeRates!['USD$_fromCurrency'] ?? 1.0;
      final toRate = _exchangeRates!['USD$_toCurrency'] ?? 1.0;
      setState(() => _result = amount * (toRate / fromRate));
    }
  }

  String _getFormattedLastUpdated() {
    if (_lastUpdated == null) return '';
    
    final difference = DateTime.now().difference(_lastUpdated!);
    if (difference.inMinutes < 1) {
      return 'Last updated: Just now';
    } else if (difference.inHours < 1) {
      return 'Last updated: ${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return 'Last updated: ${difference.inHours}h ago';
    }
    return 'Last updated: ${_lastUpdated!.toString().split('.')[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadExchangeRates,
              tooltip: 'Refresh rates',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: (_) => _convert(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromCurrency,
                            decoration: const InputDecoration(
                              labelText: 'From',
                              border: OutlineInputBorder(),
                            ),
                            items: CurrencyService.supportedCurrencies
                                .map((currency) => DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _fromCurrency = value;
                                  _convert();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: () {
                            setState(() {
                              final temp = _fromCurrency;
                              _fromCurrency = _toCurrency;
                              _toCurrency = temp;
                              _convert();
                            });
                          },
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _toCurrency,
                            decoration: const InputDecoration(
                              labelText: 'To',
                              border: OutlineInputBorder(),
                            ),
                            items: CurrencyService.supportedCurrencies
                                .map((currency) => DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _toCurrency = value;
                                  _convert();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${_amountController.text} $_fromCurrency =',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_result!.toStringAsFixed(2)} $_toCurrency',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      if (_exchangeRates != null) ...[
                        Text(
                          'Exchange Rate: 1 $_fromCurrency = '
                          '${(_result! / double.parse(_amountController.text.isEmpty ? "1" : _amountController.text)).toStringAsFixed(4)} $_toCurrency',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFormattedLastUpdated(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}