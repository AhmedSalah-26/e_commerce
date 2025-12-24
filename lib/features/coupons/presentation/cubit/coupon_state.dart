import 'package:equatable/equatable.dart';
import '../../data/models/coupon_validation_result.dart';
import '../../domain/entities/coupon_entity.dart';

abstract class CouponState extends Equatable {
  const CouponState();

  @override
  List<Object?> get props => [];
}

class CouponInitial extends CouponState {}

class CouponLoading extends CouponState {}

class CouponValidating extends CouponState {}

/// حالة الكوبون المطبق في الـ Checkout
class CouponApplied extends CouponState {
  final CouponValidationResult result;

  const CouponApplied(this.result);

  @override
  List<Object?> get props => [result];
}

class CouponRemoved extends CouponState {}

class CouponError extends CouponState {
  final String messageAr;
  final String messageEn;

  const CouponError({required this.messageAr, required this.messageEn});

  String getMessage(String locale) => locale == 'ar' ? messageAr : messageEn;

  @override
  List<Object?> get props => [messageAr, messageEn];
}

/// حالات إدارة الكوبونات للتاجر
class MerchantCouponsLoading extends CouponState {}

class MerchantCouponsLoaded extends CouponState {
  final List<CouponEntity> coupons;

  const MerchantCouponsLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class MerchantCouponsError extends CouponState {
  final String message;

  const MerchantCouponsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CouponSaving extends CouponState {}

class CouponSaved extends CouponState {}

class CouponDeleted extends CouponState {}
