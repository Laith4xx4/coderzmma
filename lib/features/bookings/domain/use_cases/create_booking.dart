import 'package:thesavage/features/bookings/data/models/create_booking_model.dart';
import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';
import 'package:thesavage/features/bookings/domain/repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<BookingEntity> call(CreateBookingModel data) {
    return repository.createBooking(data);
  }
}


