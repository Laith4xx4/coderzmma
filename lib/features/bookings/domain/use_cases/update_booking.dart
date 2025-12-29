import 'package:thesavage/features/bookings/data/models/update_booking_model.dart';
import 'package:thesavage/features/bookings/domain/repositories/booking_repository.dart';

class UpdateBooking {
  final BookingRepository repository;

  UpdateBooking(this.repository);

  Future<void> call(int id, UpdateBookingModel data) {
    return repository.updateBooking(id, data);
  }
}


