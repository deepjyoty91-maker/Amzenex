import 'package:flutter_test/flutter_test.dart';
import 'package:medmylife/features/doctors/domain/models/doctor_model.dart';

void main() {
  group('DoctorModel JSON Serialization', () {
    const sampleJson = {
      "id": 101,
      "name": "Dr. Rahul Sharma",
      "speciality": "Cardiologist",
      "experience": 12,
      "consultationFee": 800,
      "available": true
    };

    test('should correctly parse valid DoctorModel from JSON', () {
      final model = DoctorModel.fromJson(sampleJson);

      expect(model.id, equals(101));
      expect(model.name, equals("Dr. Rahul Sharma"));
      expect(model.speciality, equals("Cardiologist"));
      expect(model.experience, equals(12));
      expect(model.consultationFee, equals(800));
      expect(model.available, isTrue);
      expect(model.availableSlots, isNotEmpty);
    });

    test('should correctly convert DoctorModel instance back to JSON map', () {
      final model = DoctorModel.fromJson(sampleJson);
      final resultMap = model.toJson();

      expect(resultMap['id'], equals(101));
      expect(resultMap['name'], equals("Dr. Rahul Sharma"));
      expect(resultMap['speciality'], equals("Cardiologist"));
      expect(resultMap['experience'], equals(12));
      expect(resultMap['consultationFee'], equals(800));
      expect(resultMap['available'], isTrue);
    });
  });
}
