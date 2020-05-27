import 'dart:io';

class HttpUntrackedException implements HttpException {
  const HttpUntrackedException({this.message, this.uri, this.statusCode});

  final String message;
  final int statusCode;
  final Uri uri;

  @override
  String toString() {
    return 'An untracked error occurred.\n'
        'Please report this to the developer of the app via the'
        'playstore(Android) or the appstore(iOS) or email.\n\n'
        'Error message: $message\n'
        'Error code: $statusCode';
  }
}

class HttpClientSideException implements HttpException {
  const HttpClientSideException({this.message, this.uri, this.statusCode});

  final String message;
  final int statusCode;
  final Uri uri;

  @override
  String toString() {
    return 'An error occurred on the client side.\n'
        'This usually occurs when the client has a weak network'
        'connection.\n\n'
        'Error message: $message\n'
        'Error code: $statusCode';
  }
}

class HttpServerSideException implements HttpException {
  const HttpServerSideException({this.message, this.uri, this.statusCode});

  final String message;
  final int statusCode;
  final Uri uri;

  @override
  String toString() {
    return 'An error occurred on the server side.\n'
        'This is a problem with the server that keeps the data'
        'for the app. Please contact the developer of the app'
        'if you experience the error frequently.'
        'Error message: $message'
        'Error code: $statusCode';
  }
}

class HttpOtherException implements HttpException {
  const HttpOtherException({this.message, this.uri, this.statusCode});

  final String message;
  final int statusCode;
  final Uri uri;

  @override
  String toString() {
    return 'An unkown error occurred while fetching data.\n'
        'Please contact the developer of the app'
        'if you experience the error frequently.'
        'Error message: $message'
        'Error code: $statusCode';
  }
}

class DataFetchException implements Exception {
  const DataFetchException(this.message);

  final String message;

  @override
  String toString() {
    return 'Exception occurred: $message';
  }
}

class IsoNotFoundException implements Exception {
  const IsoNotFoundException();
}

class WidgetNotBuiltYetException implements Exception {
  const WidgetNotBuiltYetException();
}

class NoCachedDataException implements Exception {
  const NoCachedDataException();
}
