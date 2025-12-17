import 'package:bloc/bloc.dart';
import 'package:maa3/features/bookings/data/models/create_booking_model.dart';
import 'package:maa3/features/bookings/data/models/update_booking_model.dart';
import 'package:maa3/features/bookings/domain/use_cases/create_booking.dart';
import 'package:maa3/features/bookings/domain/use_cases/delete_booking.dart';
import 'package:maa3/features/bookings/domain/use_cases/get_all_bookings.dart';
import 'package:maa3/features/bookings/domain/use_cases/update_booking.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetAllBookings getAllBookings;
  final CreateBooking createBooking;
  final UpdateBooking updateBooking;
  final DeleteBooking deleteBooking;

  BookingCubit({
    required this.getAllBookings,
    required this.createBooking,
    required this.updateBooking,
    required this.deleteBooking,
  }) : super(BookingInitial());

  Future<void> loadBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await getAllBookings.call();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> createBookingAction(CreateBookingModel data) async {
    emit(BookingLoading());
    try {
      await createBooking.call(data);
      emit(BookingOperationSuccess('Booking created successfully'));
      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> updateBookingAction(int id, UpdateBookingModel data) async {
    emit(BookingLoading());
    try {
      await updateBooking.call(id, data);
      emit(BookingOperationSuccess('Booking updated successfully'));
      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> deleteBookingAction(int id) async {
    emit(BookingLoading());
    try {
      await deleteBooking.call(id);
      emit(BookingOperationSuccess('Booking deleted successfully'));
      await loadBookings();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}

