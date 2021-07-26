class PlaceInfo {
  final String name;
  final String? phoneNumber;
  final String? openingHours;
  final String address;

  PlaceInfo(
      {required this.name,
      required this.address,
      this.openingHours,
      this.phoneNumber});

  factory PlaceInfo.fromJson(Map<String, dynamic> json) {
    return PlaceInfo(
        name: json["name"],
        phoneNumber: json["formatted_phone_number"],
        openingHours: json["opening_hours"],
        address: json["formatted_address"]);
  }
}
