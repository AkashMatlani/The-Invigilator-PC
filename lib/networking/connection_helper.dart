import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConnectionHelper {
  static String? url = dotenv.env['WEB_URL'];
  static BaseOptions opts = BaseOptions(
    baseUrl: url!,
    responseType: ResponseType.json,
    connectTimeout: Duration(milliseconds: 24000),
    receiveTimeout: Duration(milliseconds: 24000),
    followRedirects: false,
    validateStatus: (status) {
      return status! < 500;
    },
    headers: {
      HttpHeaders.authorizationHeader: dotenv.env['API_TOKEN'],
      HttpHeaders.contentTypeHeader: "application/json; charset=utf-8"
    },
  );

  static Dio createDio() {
    return Dio(opts);
  }

  static Dio addInterceptors(Dio dio) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback = (cert, host, port) => true;
    };
    return dio
      ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        return handler.next(options);
      }, onResponse: (response, handler) {
        return handler.next(response);
      }, onError: (DioException e, handler) {
        return handler.next(e);
      }));
  }

  static dynamic requestInterceptor(RequestOptions options) async {
    return options;
  }

  static final dio = createDio();
  static final baseAPI = addInterceptors(dio);

  Future<Map> getHTTP(String url) async {
    try {
      Response response = await baseAPI.get(url);
      return {'body': response.data, 'code': response.statusCode};
    } on DioException catch (e) {
      Map data = Map();
      final errorMessage = DioExceptions.fromDioError(e).toString();
      if (e.type == DioExceptionType.receiveTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.connectionTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.sendTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else {
        data = {'body': "error", 'errorMessage': errorMessage, 'code': 500};
      }
      return data;
    }
  }

  Future<Map> postHTTP(String url, dynamic data) async {
    try {
      Response response = await baseAPI.post(url, data: data);
      return {'body': response.data, 'code': response.statusCode};
    } on DioException catch (e) {
      Map data = Map();
      final errorMessage = DioExceptions.fromDioError(e).toString();
      if (e.type == DioExceptionType.receiveTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.connectionTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.sendTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else {
        data = {'body': "error", 'errorMessage': errorMessage, 'code': 500};
      }
      return data;
    }
  }

  Future<Map> putHTTP(String url, dynamic data) async {
    try {
      Response response = await baseAPI.put(url, data: data);
      return {'body': response.data, 'code': response.statusCode};
    } on DioException catch (e) {
      Map data = Map();
      final errorMessage = DioExceptions.fromDioError(e).toString();
      if (e.type == DioExceptionType.receiveTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.connectionTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.sendTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else {
        data = {'body': "error", 'errorMessage': errorMessage, 'code': 500};
      }
      return data;
    }
  }

  Future<Map> deleteHTTP(String url) async {
    try {
      Response response = await baseAPI.delete(url);
      return {'body': response.data, 'code': response.statusCode};
    } on DioException catch (e) {
      Map data = Map();
      final errorMessage = DioExceptions.fromDioError(e).toString();
      if (e.type == DioExceptionType.receiveTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.connectionTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else if (e.type == DioExceptionType.sendTimeout) {
        data = {'body': "timeout", 'code': 500};
      } else {
        data = {'body': "error", 'errorMessage': errorMessage, 'code': 500};
      }
      return data;
    }
  }
}

class DioExceptions implements Exception {
  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with the server";
        break;
      case DioExceptionType.unknown:
        message = "Something went wrong on the server, please try again.";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with the server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
            dioError.response!.statusCode, dioError.response!.data);
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with the server";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String? message;

  String? _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 404:
        return error["message"];
      case 500:
        return 'Internal server error';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message!;
}
