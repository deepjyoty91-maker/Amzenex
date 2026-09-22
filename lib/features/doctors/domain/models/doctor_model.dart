import 'package:equatable/equatable.dart';

class DoctorReview extends Equatable {
  final String patientName;
  final double rating;
  final String comment;
  final String date;

  const DoctorReview({
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      patientName: json['patientName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  @override
  List<Object?> get props => [patientName, rating, comment, date];
}

class DoctorModel extends Equatable {
  final int id;
  final String name;
  final String speciality;
  final int experience;
  final int consultationFee;
  final bool available;
  final String about;
  final double rating;
  final int reviewCount;
  final String hospitalLocation;
  final List<DoctorReview> reviews;
  final List<String> availableSlots;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.speciality,
    required this.experience,
    required this.consultationFee,
    required this.available,
    this.about = 'Senior consultant committed to providing high-quality, compassionate healthcare.',
    this.rating = 4.8,
    this.reviewCount = 94,
    this.hospitalLocation = 'Amzenex Super Speciality Hospital, GS Road, Guwahati',
    this.reviews = const [
      DoctorReview(
        patientName: 'Bikash Das',
        rating: 5.0,
        comment: 'Extremely attentive and explained the diagnosis in detail. Highly recommended!',
        date: '2 days ago',
      ),
      DoctorReview(
        patientName: 'Ananya Sharma',
        rating: 4.5,
        comment: 'Very polite doctor. The consultation was smooth and effective.',
        date: '1 week ago',
      ),
    ],
    this.availableSlots = const [
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
      '02:00 PM',
      '02:30 PM',
      '03:00 PM',
    ],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      speciality: json['speciality'] as String,
      experience: json['experience'] as int,
      consultationFee: json['consultationFee'] as int,
      available: json['available'] as bool,
      about: json['about'] as String? ?? 'Senior consultant committed to providing high-quality healthcare.',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['reviewCount'] as int? ?? 94,
      hospitalLocation: json['hospitalLocation'] as String? ?? 'Amzenex Super Speciality Hospital, GS Road, Guwahati',
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => DoctorReview.fromJson(Map<String, dynamic>.from(r))).toList()
          : const [
              DoctorReview(
                patientName: 'Bikash Das',
                rating: 5.0,
                comment: 'Extremely attentive and explained the diagnosis in detail. Highly recommended!',
                date: '2 days ago',
              ),
              DoctorReview(
                patientName: 'Ananya Sharma',
                rating: 4.5,
                comment: 'Very polite doctor. The consultation was smooth and effective.',
                date: '1 week ago',
              ),
            ],
      availableSlots: json['availableSlots'] != null
          ? List<String>.from(json['availableSlots'])
          : const [
              '10:00 AM',
              '10:30 AM',
              '11:00 AM',
              '11:30 AM',
              '02:00 PM',
              '02:30 PM',
              '03:00 PM',
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speciality': speciality,
      'experience': experience,
      'consultationFee': consultationFee,
      'available': available,
      'about': about,
      'rating': rating,
      'reviewCount': reviewCount,
      'hospitalLocation': hospitalLocation,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'availableSlots': availableSlots,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        speciality,
        experience,
        consultationFee,
        available,
        about,
        rating,
        reviewCount,
        hospitalLocation,
        reviews,
        availableSlots,
      ];
}
