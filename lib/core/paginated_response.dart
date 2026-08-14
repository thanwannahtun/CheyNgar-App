import 'package:equatable/equatable.dart';

import '../models/contact.dart';
import '../models/repayment.dart';
import '../models/transactions.dart';

class PaginatedResponse<T> extends Equatable {
  final String? message;
  final bool? success;
  final List<T>? data;
  final int? total;
  final int? currentPage;
  final int? previousPage;
  final int? nextPage;
  final int? lastPage;
  final int? countPerPage;

  const PaginatedResponse({
    this.message,
    this.success,
    this.data,
    this.total,
    this.currentPage,
    this.previousPage,
    this.nextPage,
    this.lastPage,
    this.countPerPage,
  });

  PaginatedResponse copyWith({
    String? message,
    bool? success,
    List<T>? data,
    int? total,
    int? currentPage,
    int? previousPage,
    int? nextPage,
    int? lastPage,
    int? countPerPage,
  }) => PaginatedResponse(
    message: message ?? this.message,
    success: success ?? this.success,
    data: data ?? this.data,
    total: total ?? this.total,
    currentPage: currentPage ?? this.currentPage,
    previousPage: previousPage ?? this.previousPage,
    nextPage: nextPage ?? this.nextPage,
    lastPage: lastPage ?? this.lastPage,
    countPerPage: countPerPage ?? this.countPerPage,
  );

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    var data = <T>[];

    if (T == Contact) {
      data =
          (json["data"] as List).map((e) => Contact.fromJson(e)).toList()
              as List<T>;
    }
    if (T == Transaction) {
      data =
          (json["data"] as List).map((e) => Transaction.fromJson(e)).toList()
              as List<T>;
    }
    if (T == Repayment) {
      data =
          (json["data"] as List).map((e) => Repayment.fromJson(e)).toList()
              as List<T>;
    }

    return PaginatedResponse(
      message: json["message"],
      success: json["success"],
      data: data,
      total: json["total"],
      currentPage: json["currentPage"],
      previousPage: json["previousPage"],
      nextPage: json["nextPage"],
      lastPage: json["lastPage"],
      countPerPage: json["countPerPage"],
    );
  }

  @override
  List<Object?> get props => [
    message,
    success,
    data,
    total,
    currentPage,
    previousPage,
    nextPage,
    lastPage,
    countPerPage,
  ];
}
