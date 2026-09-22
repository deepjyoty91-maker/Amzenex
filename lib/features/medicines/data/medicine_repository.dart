import '../domain/models/medicine_model.dart';

abstract class MedicineRepository {
  Future<List<MedicineModel>> getAmzenexMedicines();
}

class MedicineRepositoryImpl implements MedicineRepository {
  static const List<MedicineModel> _sampleMedicines = [
    MedicineModel(
      id: 'AMZ-MED-01',
      name: 'Amzenex CardiaCare 500mg',
      category: 'Cardiovascular Care',
      description: 'Advanced formula for healthy lipid profile, blood pressure support, and cardiac wellness.',
      price: 350,
      dosage: '1 tablet daily after breakfast',
      manufacturer: 'Amzenex Pharmaceuticals Guwahati',
    ),
    MedicineModel(
      id: 'AMZ-MED-02',
      name: 'Amzenex DermaShield Ointment',
      category: 'Dermatology & Skin Repair',
      description: 'Anti-inflammatory and antimicrobial dermatological ointment for rapid skin healing and eczema relief.',
      price: 220,
      dosage: 'Apply twice daily on clean skin',
      manufacturer: 'Amzenex Pharmaceuticals Guwahati',
    ),
    MedicineModel(
      id: 'AMZ-MED-03',
      name: 'Amzenex OrthoRelief Joint Gel',
      category: 'Orthopedics & Joint Care',
      description: 'Fast-absorbing topical gel with herbal extracts for joint pain, arthritis, and muscle stiffness.',
      price: 180,
      dosage: 'Massage gently on affected area 3 times daily',
      manufacturer: 'Amzenex Pharmaceuticals Guwahati',
    ),
    MedicineModel(
      id: 'AMZ-MED-04',
      name: 'Amzenex NeuroPlus Capsules',
      category: 'Neurology & Nerve Health',
      description: 'Nerve nourishing complex with Methylcobalamin & Alpha Lipoic Acid for peripheral nerve strength.',
      price: 450,
      dosage: '1 capsule daily after dinner',
      manufacturer: 'Amzenex Pharmaceuticals Guwahati',
    ),
    MedicineModel(
      id: 'AMZ-MED-05',
      name: 'Amzenex PediaCure Immune Syrup',
      category: 'Pediatric Care',
      description: 'Delightful strawberry flavored multivitamin and zinc syrup formulated for children’s immunity.',
      price: 160,
      dosage: '5ml once daily for children 2-12 years',
      manufacturer: 'Amzenex Pharmaceuticals Guwahati',
    ),
    MedicineModel(
      id: 'AMZ-MED-06',
      name: 'Amzenex GastroEase Suspension',
      category: 'Gastroenterology',
      description: 'Instant relief antacid and anti-reflux suspension for hyperacidity, heart burn, and indigestion.',
      price: 190,
      dosage: '10ml after meals as needed',
      manufacturer: 'Amzenex Pharmaceuticals Guwahati',
    ),
  ];

  @override
  Future<List<MedicineModel>> getAmzenexMedicines() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _sampleMedicines;
  }
}
