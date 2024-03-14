import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'connection_helper.dart';

class ResetDetailsConnectionHelper extends ConnectionHelper {
  static String? url = dotenv.env['RESET_URL'];

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

  Future<Map> postHTTP(String url, dynamic data) async {
    try {
      var dio = createDio();
      var baseAPI = addInterceptors(dio);
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
}
