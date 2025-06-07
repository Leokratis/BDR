import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

@JsonSerializable()
class CaptchaData {
  final String id;
  final String image; // base64 encoded image

  CaptchaData({
    required this.id,
    required this.image,
  });

  factory CaptchaData.fromJson(Map<String, dynamic> json) =>
      _$CaptchaDataFromJson(json);

  Map<String, dynamic> toJson() => _$CaptchaDataToJson(this);
}

@JsonSerializable()
class UserData {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? bloodType;
  final DateTime? lastDonation;
  final int? totalDonations;

  UserData({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.bloodType,
    this.lastDonation,
    this.totalDonations,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class Donation {
  final String id;
  final DateTime date;
  final String location;
  final String bloodType;
  final String status;
  final double? hemoglobin;
  final String? notes;

  Donation({
    required this.id,
    required this.date,
    required this.location,
    required this.bloodType,
    required this.status,
    this.hemoglobin,
    this.notes,
  });

  factory Donation.fromJson(Map<String, dynamic> json) =>
      _$DonationFromJson(json);

  Map<String, dynamic> toJson() => _$DonationToJson(this);
}

@JsonSerializable()
class Coverage {
  final String id;
  final String name;
  final String type;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Coverage({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory Coverage.fromJson(Map<String, dynamic> json) =>
      _$CoverageFromJson(json);

  Map<String, dynamic> toJson() => _$CoverageToJson(this);
}

@JsonSerializable()
class ContactIssue {
  final String? email;
  final String? phoneNumber;
  final String subject;
  final String message;
  final String? captchaId;
  final String? captchaAnswer;

  ContactIssue({
    this.email,
    this.phoneNumber,
    required this.subject,
    required this.message,
    this.captchaId,
    this.captchaAnswer,
  });

  factory ContactIssue.fromJson(Map<String, dynamic> json) =>
      _$ContactIssueFromJson(json);

  Map<String, dynamic> toJson() => _$ContactIssueToJson(this);
}
