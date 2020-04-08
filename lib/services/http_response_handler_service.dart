import 'dart:io';

import 'package:http/http.dart';
import 'package:statscov/utils/exceptions.dart';

class HttpResponseHandlerService {
  void handleResponse(Response response, Uri uri) {
    switch (response.statusCode) {
      case HttpStatus.ok:
        break;

      case HttpStatus.badRequest:
        throw HttpClientSideException(
          message: 'Bad Request. Please contact the app developer.',
          uri: uri,
          statusCode: response.statusCode,
        );
        break;

      case HttpStatus.requestTimeout:
        throw HttpClientSideException(
          message: 'Request timed out. Weak network connection?',
          uri: uri,
          statusCode: response.statusCode,
        );
        break;

      case HttpStatus.internalServerError:
        throw HttpServerSideException(
          message: 'Internal server error. Try restarting?',
          uri: uri,
          statusCode: response.statusCode,
        );
        break;
    }
  }
}
