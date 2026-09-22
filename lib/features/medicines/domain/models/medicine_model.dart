import 'package:equatable/equatable.dart';

class MedicineModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final int price;
  final String dosage;
  final String manufacturer;
  final bool inStock;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.dosage,
    this.manufacturer = 'Amzenex Pharmaceuticals Guwahati',
    this.inStock = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        description,
        price,
        dosage,
        manufacturer,
        inStock,
      ];
}
