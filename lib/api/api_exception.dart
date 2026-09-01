import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          return ApiException(first.first.toString(), statusCode: status);
        }
        return ApiException(first.toString(), statusCode: status);
      }
      if (data['message'] != null) {
        return ApiException(data['message'].toString(), statusCode: status);
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        'Koneksi ke server timeout. Coba lagi.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Tidak bisa terhubung ke server. Pastikan backend Laravel berjalan.',
      );
    }

    return ApiException(
      'Terjadi kesalahan. Coba lagi.',
      statusCode: status,
    );
  }

  @override
  String toString() => message;
}
