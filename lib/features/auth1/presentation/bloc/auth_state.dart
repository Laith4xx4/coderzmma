import 'package:equatable/equatable.dart';
import 'package:thesavage/features/auth1/domain/entities/user.dart';
//import 'package:flutter/foundation.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String token;
  final User user;

  const AuthSuccess({required this.token, required this.user});

  @override
  List<Object> get props => [token, user];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class AuthRegistrationSuccess extends AuthState {
  final String message;
  final String role;

  const AuthRegistrationSuccess({required this.message, required this.role});

  @override
  List<Object> get props => [message, role];
}
