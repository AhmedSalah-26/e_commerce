import 'package:equatable/equatable.dart';

class GovernorateEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final bool isActive;
  final int sortOrder;

  const GovernorateEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.isActive = true,
    this.sortOrder = 0,
  });

  String getName(String locale) => locale == 'en' ? nameEn : nameAr;

  @override
  List<Object?> get props => [id, nameAr, nameEn, isActive, sortOrder];
}
