import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_app/screens/itinerary_details_screen.dart';
import '../models/itinerary.dart';
import 'package:travel_buddy_app/provider/firebase_provider.dart';
import '../services/auth_service.dart';

class ItineraryPlannerScreen extends StatefulWidget {
  const ItineraryPlannerScreen({super.key});

  @override
  _ItineraryPlannerScreenState createState() => _ItineraryPlannerScreenState();
}

class _ItineraryPlannerScreenState extends State<ItineraryPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String _destination = '';
  DateTime? _startDate;
  DateTime? _endDate;
  List<ItineraryDay> _days = [];
  bool _isPublic = false;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before new start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _generateDays() {
    if (_startDate != null && _endDate != null) {
      final difference = _endDate!.difference(_startDate!).inDays + 1;
      _days = List.generate(
        difference,
        (index) => ItineraryDay(
          dayNumber: index + 1,
          activities: [],
        ),
      );
    }
  }

  Future<void> _createItinerary() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseProvider =
          Provider.of<FirebaseProvider>(context, listen: false);

      final itinerary = Itinerary(
        id: '', // Will be set by Firestore
        userId: authService.user!.uid,
        destination: _destination,
        startDate: _startDate!,
        endDate: _endDate!,
        days: _days,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final itineraryId = await firebaseProvider.createNewItinerary(itinerary);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary created successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItineraryDetailScreen(itineraryId: itineraryId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating itinerary: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _createItinerary();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: [
            Step(
              title: const Text('Destination'),
              content: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Where are you going?',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
                onChanged: (value) => _destination = value,
              ),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Dates'),
              content: Column(
                children: [
                  ListTile(
                    title: Text(_startDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${_startDate!.toLocal().toString().split(' ')[0]}'),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                  ),
                  ListTile(
                    title: Text(_endDate == null
                        ? 'Select End Date'
                        : 'End Date: ${_endDate!.toLocal().toString().split(' ')[0]}'),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () =>
                        _startDate == null ? null : _selectDate(context, false),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _startDate != null && _endDate != null
                  ? StepState.complete
                  : StepState.editing,
            ),
            Step(
              title: const Text('Preferences'),
              content: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Make Itinerary Public'),
                    subtitle: const Text(
                        'Allow other travelers to view and copy your itinerary'),
                    value: _isPublic,
                    onChanged: (bool value) {
                      setState(() => _isPublic = value);
                    },
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }
}
