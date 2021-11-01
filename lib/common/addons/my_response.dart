import 'dart:convert' as convert;

import 'package:shelf/shelf.dart';

class MyResponse {
  Response json(
    status,
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    headers = headers ?? {'Content-Type': 'application/json'};
    if (headers['Content-Type'] == null) {
      headers['Content-Type'] = 'application/json';
    }

    if (body is String) {
      headers.remove('Content-Type');
    }

    return Response(
      status,
      body: body is String ? body : convert.json.encode(body),
      headers: headers,
      context: context,
      encoding: encoding,
    );
  }

  Response ok(
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return json(200, body,
        context: context, headers: headers, encoding: encoding);
  }

  Response forbidden(
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return json(403, body,
        context: context, headers: headers, encoding: encoding);
  }

  Response internalServerError(
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return json(500, body,
        context: context, headers: headers, encoding: encoding);
  }

  Response notFound(
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return json(404, body,
        context: context, headers: headers, encoding: encoding);
  }

  Response reset(
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return json(205, body,
        context: context, headers: headers, encoding: encoding);
  }

  Response seeOther(
    body, {
    Map<String, Object>? headers,
    convert.Encoding? encoding,
    Map<String, Object>? context,
  }) {
    return json(303, body,
        context: context, headers: headers, encoding: encoding);
  }
}
