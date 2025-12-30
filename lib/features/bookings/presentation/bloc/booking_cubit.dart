import 'package:bloc/bloc.dart';
import 'package:thesavage/features/bookings/data/models/create_booking_model.dart';
import 'package:thesavage/features/bookings/data/models/update_booking_model.dart';
import 'package:thesavage/features/bookings/domain/use_cases/create_booking.dart';
import 'package:thesavage/features/bookings/domain/use_cases/delete_booking.dart';
import 'package:thesavage/features/bookings/domain/use_cases/get_all_bookings.dart';
import 'package:thesavage/features/bookings/domain/use_cases/update_booking.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_state.dart';

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
      print("BookingCubit: Loaded ${bookings.length} bookings");
      for (var b in bookings) {
         print(" - ID: ${b.id}, Member: ${b.memberName} (${b.memberId}), Status: ${b.status}");
      }
      emit(BookingsLoaded(bookings));
    } catch (e) {
      print("BookingCubit Load Error: $e");
      emit(BookingError(e.toString()));
    }
  }

  Future<void> createBookingAction(CreateBookingModel data) async {
    print("BookingCubit: Creating booking for Member: ${data.memberId}, Session: ${data.sessionId}, Status: ${data.status}");
    emit(BookingLoading());
    try {
      await createBooking.call(data);
      emit(BookingOperationSuccess('Booking created successfully'));
      await loadBookings();
    } catch (e) {
      print("BookingCubit Error: $e");
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

