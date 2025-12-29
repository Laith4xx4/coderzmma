import 'package:equatable/equatable.dart';
import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';

abstract class BookingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingOperationSuccess extends BookingState {
  final String message;

  BookingOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
