// Add this to your models file
class BookingResponse {
  final String? error;
  final List<dynamic> formErrors;
  final bool status;
  final int statusCode;
  final BookingResult? result;

  BookingResponse({
    this.error,
    required this.formErrors,
    required this.status,
    required this.statusCode,
    this.result,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      error: json['error'],
      formErrors: json['formErrors'] ?? [],
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 400,
      result: json['result'] != null ? BookingResult.fromJson(json['result']) : null,
    );
  }
}

class BookingResult {
  final String bookingUuid;
  final String nfcHolderCode;
  final String bookingStatusName;
  final String bookingStatusCode;
  final List<Rental> rentals;

  BookingResult({
    required this.bookingUuid,
    required this.nfcHolderCode,
    required this.bookingStatusName,
    required this.bookingStatusCode,
    required this.rentals,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    return BookingResult(
      bookingUuid: json['bookingUuid'] ?? '',
      nfcHolderCode: json['nfcHolderCode'] ?? '',
      bookingStatusName: json['bookingStatusName'] ?? '',
      bookingStatusCode: json['bookingStatusCode'] ?? '',
      rentals: (json['rentals'] as List? ?? []).map((e) => Rental.fromJson(e)).toList(),
    );
  }
}

class Rental {
  final String uuid;
  final String rentalStatusName;
  final String rentalStatusCode;

  Rental({
    required this.uuid,
    required this.rentalStatusName,
    required this.rentalStatusCode,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      uuid: json['uuid'] ?? '',
      rentalStatusName: json['rentalStatusName'] ?? '',
      rentalStatusCode: json['rentalStatusCode'] ?? '',
    );
  }
}