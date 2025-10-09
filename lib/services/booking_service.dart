import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new booking
  Future<String> createBooking(Booking booking) async {
    try {
      final docRef = _firestore.collection('bookings').doc();
      booking.id = docRef.id; // Use the auto-generated ID
      
      await docRef.set(booking.toMap());
      return booking.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get user's bookings - FIXED VERSION
  Stream<List<Booking>> getUserBookings() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('❌ No user logged in');
        return Stream.value([]);
      }

      print('🔍 Fetching bookings for user: $userId');

      // Use simpler query first (no ordering) to avoid index issues
      return _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .handleError((error) {
            print('❌ Firestore error: $error');
            throw error;
          })
          .map((snapshot) {
            print('📄 Found ${snapshot.docs.length} bookings');
            
            final bookings = snapshot.docs.map((doc) {
              try {
                // Use fromFirestore instead of fromMap to include document ID
                return Booking.fromFirestore(doc);
              } catch (e) {
                print('❌ Error parsing booking ${doc.id}: $e');
                print('📊 Document data: ${doc.data()}');
                return null;
              }
            }).where((booking) => booking != null).cast<Booking>().toList();

            // Sort locally by booking date (newest first)
            bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
            
            print('✅ Successfully parsed ${bookings.length} bookings');
            return bookings;
          });
    } catch (e) {
      print('❌ Error in getUserBookings: $e');
      return Stream.error(e);
    }
  }

  // Get bookings for a hospital
  Stream<List<Booking>> getHospitalBookings(String hospitalId) {
    return _firestore
        .collection('bookings')
        .where('hospitalId', isEqualTo: hospitalId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    });
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(), // Use server timestamp
      });
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelled');
  }

  // Check if time slot is available
  Future<bool> isTimeSlotAvailable(
    String hospitalId, // Using hospitalId instead of specialistId
    DateTime date,
    String timeSlot,
  ) async {
    try {
      // Convert DateTime to start of day for comparison
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final snapshot = await _firestore
          .collection('bookings')
          .where('hospitalId', isEqualTo: hospitalId)
          .where('bookingDate', isGreaterThanOrEqualTo: startOfDay)
          .where('bookingDate', isLessThan: endOfDay)
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      print('❌ Availability check error: $e');
      return false; // Return false on error to be safe
    }
  }

  // Generate available time slots
  List<String> generateTimeSlots() {
    return [
      '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
      '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM',
      '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
    ];
  }
}