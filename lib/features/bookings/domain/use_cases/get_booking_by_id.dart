import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';
import 'package:thesavage/features/bookings/domain/repositories/booking_repository.dart';

class GetBookingById {
  final BookingRepository repository;

  GetBookingById(this.repository);

  Future<BookingEntity> call(int id) {
    return repository.getBookingById(id);
  }
}


