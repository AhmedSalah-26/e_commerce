import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/coupon_remote_datasource.dart';
import '../../data/models/coupon_model.dart';
import '../../data/models/coupon_validation_result.dart';
import 'coupon_state.dart';

class CouponCubit extends Cubit<CouponState> {
  final CouponRemoteDatasource _datasource;
  CouponValidationResult? _appliedCoupon;

  CouponCubit(this._datasource) : super(CouponInitial());

  CouponValidationResult? get appliedCoupon => _appliedCoupon;

  /// التحقق من الكوبون وتطبيقه
  Future<void> validateAndApplyCoupon({
    required String code,
    required String userId,
    required double orderAmount,
    String? storeId,
    List<String>? productIds,
  }) async {
    if (code.trim().isEmpty) return;

    emit(CouponValidating());

    try {
      final result = await _datasource.validateCoupon(
        code: code,
        userId: userId,
        orderAmount: orderAmount,
        storeId: storeId,
        productIds: productIds,
      );

      if (result.isValid) {
        _appliedCoupon = result;
        emit(CouponApplied(result));
      } else {
        emit(CouponError(
          messageAr: result.errorAr ?? 'كود الخصم غير صحيح',
          messageEn: result.errorEn ?? 'Invalid coupon code',
        ));
      }
    } catch (e) {
      emit(const CouponError(
        messageAr: 'حدث خطأ أثناء التحقق من الكوبون',
        messageEn: 'Error validating coupon',
      ));
    }
  }

  /// إزالة الكوبون المطبق
  void removeCoupon() {
    _appliedCoupon = null;
    emit(CouponRemoved());
  }

  /// إعادة تعيين الحالة
  void reset() {
    _appliedCoupon = null;
    emit(CouponInitial());
  }
}

/// Cubit منفصل لإدارة كوبونات التاجر
class MerchantCouponsCubit extends Cubit<CouponState> {
  final CouponRemoteDatasource _datasource;

  MerchantCouponsCubit(this._datasource) : super(CouponInitial());

  /// جلب كوبونات المتجر
  Future<void> loadCoupons(String storeId) async {
    emit(MerchantCouponsLoading());

    try {
      final coupons = await _datasource.getStoreCoupons(storeId);
      emit(MerchantCouponsLoaded(coupons));
    } catch (e) {
      emit(MerchantCouponsError(e.toString()));
    }
  }

  /// إنشاء كوبون جديد
  Future<void> createCoupon(
    CouponModel coupon,
    String storeId, {
    List<String>? productIds,
    List<String>? categoryIds,
  }) async {
    emit(CouponSaving());

    try {
      await _datasource.createCoupon(
        coupon,
        productIds: productIds,
        categoryIds: categoryIds,
      );
      emit(CouponSaved());
      loadCoupons(storeId);
    } catch (e) {
      // Check for duplicate code error
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('unique') ||
          errorMsg.contains('duplicate') ||
          errorMsg.contains('23505')) {
        emit(const MerchantCouponsError('DUPLICATE_CODE'));
      } else {
        emit(MerchantCouponsError(e.toString()));
      }
    }
  }

  /// تحديث كوبون
  Future<void> updateCoupon(
    CouponModel coupon,
    String storeId, {
    List<String>? productIds,
    List<String>? categoryIds,
  }) async {
    emit(CouponSaving());

    try {
      await _datasource.updateCoupon(
        coupon,
        productIds: productIds,
        categoryIds: categoryIds,
      );
      emit(CouponSaved());
      loadCoupons(storeId);
    } catch (e) {
      emit(MerchantCouponsError(e.toString()));
    }
  }

  /// حذف كوبون
  Future<void> deleteCoupon(String couponId, String storeId) async {
    try {
      await _datasource.deleteCoupon(couponId);
      emit(CouponDeleted());
      loadCoupons(storeId);
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      // Check if coupon is used in orders (foreign key constraint)
      if (errorMsg.contains('23503') ||
          errorMsg.contains('foreign key') ||
          errorMsg.contains('still referenced')) {
        emit(const MerchantCouponsError('COUPON_IN_USE'));
      } else {
        emit(MerchantCouponsError(e.toString()));
      }
    }
  }

  /// تفعيل/تعطيل كوبون
  Future<void> toggleCouponStatus(
      String couponId, bool isActive, String storeId) async {
    try {
      await _datasource.toggleCouponStatus(couponId, isActive);
      loadCoupons(storeId);
    } catch (e) {
      emit(MerchantCouponsError(e.toString()));
    }
  }
}
