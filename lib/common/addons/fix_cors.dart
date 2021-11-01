import 'package:shelf/shelf.dart' as shelf;

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': '*',
};

shelf.Response? _options(shelf.Request request) => (request.method == 'OPTIONS')
    ? shelf.Response.ok(null, headers: _corsHeaders)
    : null;

shelf.Response _cors(shelf.Response response) =>
    response.change(headers: _corsHeaders);

final fixCORS =
    shelf.createMiddleware(requestHandler: _options, responseHandler: _cors);
