import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer.freezed.dart';
part 'trainer.g.dart';

@freezed
abstract class Trainer with _$Trainer {
  const factory Trainer({
    required String id,
    required String name,
    required List<String> specialties,
    required String bio,
    String? photoUrl,

    /// Out of 5. Null when the trainer has no ratings yet — which is not the
    /// same as a rating of zero.
    double? rating,
  }) = _Trainer;

  const Trainer._();

  factory Trainer.fromJson(Map<String, dynamic> json) =>
      _$TrainerFromJson(json);

  bool get hasRating => rating != null;
}
