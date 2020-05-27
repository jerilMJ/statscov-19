import 'dart:io';

import 'package:http/http.dart';
import 'package:statscov/utils/exceptions.dart';

/// Response handler for responses received from API fetch requests.
///
/// Throws custom exceptions based on the statuscode of the reposnse.
class HttpResponseHandlerService {
  const HttpResponseHandlerService();

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

      default:
        throw HttpOtherException(
          message: 'Unkown',
          uri: uri,
          statusCode: response.statusCode,
        );
    }
  }
}
