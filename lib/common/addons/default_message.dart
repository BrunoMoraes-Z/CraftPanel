class DefaultMessage {

  static dynamic invalidBody(dynamic) {
    return {
      'message': 'Body informado de maneira incorreta.',
      'body': dynamic,
    };
  }

}
