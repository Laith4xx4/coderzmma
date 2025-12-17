class UpdateBookingModel {
  final int status;

  UpdateBookingModel({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}


