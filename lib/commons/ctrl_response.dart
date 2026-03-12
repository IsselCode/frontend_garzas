class CtrlResponse<T> {

  final bool success;
  final String? message;
  final T? element;

  CtrlResponse({
    required this.success,
    this.message,
    this.element
  });

}