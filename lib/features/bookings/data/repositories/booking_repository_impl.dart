import 'package:thesavage/features/bookings/data/datasource/booking_api_service.dart';
import 'package:thesavage/features/bookings/data/models/booking_model.dart';
import 'package:thesavage/features/bookings/data/models/create_booking_model.dart';
import 'package:thesavage/features/bookings/data/models/update_booking_model.dart';
import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';
import 'package:thesavage/features/bookings/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingApiService apiService;

  BookingRepositoryImpl(this.apiService);

  BookingEntity _mapModelToEntity(BookingModel m) {
    return BookingEntity(
      id: m.id,
      sessionId: m.sessionId,
      sessionName: m.sessionName,
      memberId: m.memberId,
      memberName: m.memberName,
      bookingTime: m.bookingTime,
      status: m.status,
    );
  }

  @override
  Future<List<BookingEntity>> getAllBookings() async {
    final List<BookingModel> models = await apiService.getAllBookings();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<BookingEntity> getBookingById(int id) async {
    final model = await apiService.getBookingById(id);
    return _mapModelToEntity(model);
  }

  @override
  Future<BookingEntity> createBooking(CreateBookingModel data) async {
    final model = await apiService.createBooking(data);
    return _mapModelToEntity(model);
  }

  @override
  Future<void> updateBooking(int id, UpdateBookingModel data) async {
    await apiService.updateBooking(id, data);
  }

  @override
  Future<void> deleteBooking(int id) async {
    await apiService.deleteBooking(id);
  }

  @override
  Future<BookingEntity> bookSession(int sessionId) async {
    final model = await apiService.bookSession(sessionId);
    return _mapModelToEntity(model);
  }

  @override
  Future<List<BookingEntity>> getMyBookings() async {
    final List<BookingModel> models = await apiService.getMyBookings();
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<void> cancelBooking(int bookingId) async {
    await apiService.cancelBooking(bookingId);
  }
}


