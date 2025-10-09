import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingDialog extends StatefulWidget {
  final Map<String, dynamic> hospital;
  final Map<String, dynamic> specialist;

  const BookingDialog({
    super.key,
    required this.hospital,
    required this.specialist,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late DateTime _selectedDate;
  String _selectedTimeSlot = '';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _checkingAvailability = false;
  List<String> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _loadAvailableTimeSlots();
  }

  Future<void> _loadAvailableTimeSlots() async {
    setState(() {
      _checkingAvailability = true;
    });

    final allTimeSlots = _bookingService.generateTimeSlots();
    final availableSlots = <String>[];

    for (final slot in allTimeSlots) {
      final isAvailable = await _bookingService.isTimeSlotAvailable(
        widget.specialist['id'] ?? '',
        _selectedDate,
        slot,
      );
      
      if (isAvailable) {
        availableSlots.add(slot);
      }
    }

    setState(() {
      _availableTimeSlots = availableSlots;
      _checkingAvailability = false;
      if (availableSlots.isNotEmpty) {
        _selectedTimeSlot = availableSlots.first;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadAvailableTimeSlots();
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedTimeSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hospitalId: widget.hospital['id'] ?? '',
        hospitalName: widget.hospital['name'] ?? 'Unknown Hospital',
        userId: user.uid,
        userName: user.displayName ?? 'User',
        userEmail: user.email ?? '',
        userPhone: _phoneController.text,
        specialistId: widget.specialist['id'] ?? '',
        specialistName: widget.specialist['name'] ?? 'Unknown Specialist',
        specialty: widget.specialist['specialty'] ?? '',
        bookingDate: _selectedDate,
        timeSlot: _selectedTimeSlot,
        notes: _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _bookingService.createBooking(booking);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF259450), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'with ${widget.specialist['name']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Hospital Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_hospital, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.hospital['name'] ?? 'Unknown Hospital',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.hospital['location'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Date Selection
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Color(0xFF259450)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Time Slot Selection
            const Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            if (_checkingAvailability)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_availableTimeSlots.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No available slots for selected date',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableTimeSlots.map((slot) {
                  final isSelected = slot == _selectedTimeSlot;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeSlot = slot),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF259450) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF259450) : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 24),
            
            // Phone Number
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: 20),
            
            // Notes
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Any special requirements or notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF259450),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}