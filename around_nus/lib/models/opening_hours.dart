// NOT USING ANYMORE FOR NOW

class OpeningHours {
  final bool isOpen;
  // final

  OpeningHours({required this.isOpen});
  factory OpeningHours.fromJson(Map<dynamic, dynamic> parsedJson) {
    return OpeningHours(isOpen: parsedJson['open_now']);
  }
}
