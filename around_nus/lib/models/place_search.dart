class PlaceSearch {
  final String description;
  final String placeId;
  final String name;

  PlaceSearch(
      {required this.description, required this.placeId, required this.name});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(
        description: json["description"],
        name: json["structured_formatting"]["main_text"],
        // description:
        //     json["terms"][0]["value"] + " , " + json["terms"][1]["value"],
        placeId: json["place_id"]);
  }
}
