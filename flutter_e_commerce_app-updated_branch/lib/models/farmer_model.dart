
import 'dart:convert';

String farmerModel(FarmerModel farmerModel) => json.encode(farmerModel.toJson());

class FarmerModel {
  final String farmerName;
  bool isFarmerSelected;

  FarmerModel(this.farmerName, this.isFarmerSelected);

  // Convert a FarmerModel object into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'farmerName': farmerName,
      'isFarmerSelected': isFarmerSelected,
    };
  }

  // Create a FarmerModel object from a JSON map.
  factory FarmerModel.fromJson(Map<String, dynamic> json) {
    return FarmerModel(
      json['farmerName'] as String,
      json['isFarmerSelected'] as bool,
    );
  }
}
