import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';
import 'package:thesavage/features/bookings/data/models/create_booking_model.dart';
import 'package:thesavage/features/bookings/data/models/update_booking_model.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getAllBookings();
  Future<BookingEntity> getBookingById(int id);
  Future<BookingEntity> createBooking(CreateBookingModel data);
  Future<void> updateBooking(int id, UpdateBookingModel data);
  Future<void> deleteBooking(int id);
  
  // New methods for smart booking
  Future<BookingEntity> bookSession(int sessionId);
  Future<List<BookingEntity>> getMyBookings();
  Future<void> cancelBooking(int bookingId);
}


