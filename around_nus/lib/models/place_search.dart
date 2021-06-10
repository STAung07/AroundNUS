class PlaceSearch {
  final String description;
  final String placeId;

  PlaceSearch({required this.description, required this.placeId});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(
        description:
            json["terms"][0]["value"] + ", " + json["terms"][1]["value"],
        placeId: json["place_id"]);
  }
}
