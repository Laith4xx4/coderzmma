import 'package:thesavage/features/bookings/domain/repositories/booking_repository.dart';

class DeleteBooking {
  final BookingRepository repository;

  DeleteBooking(this.repository);

  Future<void> call(int id) {
    return repository.deleteBooking(id);
  }
}


