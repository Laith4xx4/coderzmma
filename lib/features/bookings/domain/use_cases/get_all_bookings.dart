import 'package:maa3/features/bookings/domain/entities/booking_entity.dart';
import 'package:maa3/features/bookings/domain/repositories/booking_repository.dart';

class GetAllBookings {
  final BookingRepository repository;

  GetAllBookings(this.repository);

  Future<List<BookingEntity>> call() {
    return repository.getAllBookings();
  }
}


