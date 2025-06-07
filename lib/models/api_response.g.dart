// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(Map<String, dynamic> json) =>
    ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] as T?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$ApiResponseToJson<T>(ApiResponse<T> instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
    };

CaptchaData _$CaptchaDataFromJson(Map<String, dynamic> json) => CaptchaData(
      id: json['id'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$CaptchaDataToJson(CaptchaData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      bloodType: json['bloodType'] as String?,
      lastDonation: json['lastDonation'] == null
          ? null
          : DateTime.parse(json['lastDonation'] as String),
      totalDonations: json['totalDonations'] as int?,
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'bloodType': instance.bloodType,
      'lastDonation': instance.lastDonation?.toIso8601String(),
      'totalDonations': instance.totalDonations,
    };

Donation _$DonationFromJson(Map<String, dynamic> json) => Donation(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      bloodType: json['bloodType'] as String,
      status: json['status'] as String,
      hemoglobin: (json['hemoglobin'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DonationToJson(Donation instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'location': instance.location,
      'bloodType': instance.bloodType,
      'status': instance.status,
      'hemoglobin': instance.hemoglobin,
      'notes': instance.notes,
    };

Coverage _$CoverageFromJson(Map<String, dynamic> json) => Coverage(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      location: json['location'] as String,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$CoverageToJson(Coverage instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'location': instance.location,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
    };

ContactIssue _$ContactIssueFromJson(Map<String, dynamic> json) => ContactIssue(
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      subject: json['subject'] as String,
      message: json['message'] as String,
      captchaId: json['captchaId'] as String?,
      captchaAnswer: json['captchaAnswer'] as String?,
    );

Map<String, dynamic> _$ContactIssueToJson(ContactIssue instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'subject': instance.subject,
      'message': instance.message,
      'captchaId': instance.captchaId,
      'captchaAnswer': instance.captchaAnswer,
    };
