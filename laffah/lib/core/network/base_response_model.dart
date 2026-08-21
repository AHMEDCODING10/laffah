/// يتوافق مع هيكل JSON القياسي لـ Laravel:
/// { "success": bool, "message": string, "data": dynamic, "errors": dynamic }
class BaseApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, List<String>>? errors;

  const BaseApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// fromJson لكائن فردي (Single Object)
  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message']?.toString() ?? '',
      data: _parseData<T>(json['data'], fromJsonT),
      errors: _parseErrors(json['errors']),
    );
  }

  /// fromJsonList لقائمة كائنات (List of Objects)
  static BaseApiResponse<List<T>> fromJsonList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List<T>? parsedList;
    if (json['data'] != null && json['data'] is List) {
      parsedList = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => fromJsonT(item))
          .toList();
    }

    return BaseApiResponse<List<T>>(
      success: json['success'] ?? true,
      message: json['message']?.toString() ?? '',
      data: parsedList,
      errors: _parseErrors(json['errors']),
    );
  }

  static T? _parseData<T>(dynamic rawData, T Function(dynamic)? fromJsonT) {
    if (rawData == null || fromJsonT == null) return null;
    try {
      return fromJsonT(rawData);
    } catch (_) {
      return null;
    }
  }

  static Map<String, List<String>>? _parseErrors(dynamic rawErrors) {
    if (rawErrors == null || rawErrors is! Map) return null;
    final Map<String, List<String>> parsed = {};
    (rawErrors as Map<String, dynamic>).forEach((key, value) {
      if (value is List) {
        parsed[key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        parsed[key] = [value.toString()];
      }
    });
    return parsed.isEmpty ? null : parsed;
  }
}

/// Alias لضمان عدم حدوث أي كسر في المسارات أو الكود الموجود مسبقاً
typedef BaseResponseModel<T> = BaseApiResponse<T>;
