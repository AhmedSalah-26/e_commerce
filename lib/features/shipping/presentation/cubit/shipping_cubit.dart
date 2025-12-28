import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/governorate_entity.dart';
import '../../domain/entities/shipping_price_entity.dart';
import '../../domain/repositories/shipping_repository.dart';

// States
abstract class ShippingState extends Equatable {
  const ShippingState();
  @override
  List<Object?> get props => [];
}

class ShippingInitial extends ShippingState {}

class ShippingLoading extends ShippingState {}

class GovernoratesLoaded extends ShippingState {
  final List<GovernorateEntity> governorates;
  final GovernorateEntity? selectedGovernorate;
  final double shippingPrice;
  final Map<String, double> merchantShippingPrices;
  final double totalShippingPrice;
  // Map: governorateId -> { merchantId -> price }
  // If price > 0, merchant is available for that governorate
  final Map<String, Map<String, double>> merchantsShippingData;

  const GovernoratesLoaded({
    required this.governorates,
    this.selectedGovernorate,
    this.shippingPrice = 0,
    this.merchantShippingPrices = const {},
    this.totalShippingPrice = 0,
    this.merchantsShippingData = const {},
  });

  @override
  List<Object?> get props => [
        governorates,
        selectedGovernorate,
        shippingPrice,
        merchantShippingPrices,
        totalShippingPrice,
        merchantsShippingData,
      ];

  GovernoratesLoaded copyWith({
    List<GovernorateEntity>? governorates,
    GovernorateEntity? Function()? selectedGovernorate,
    double? shippingPrice,
    Map<String, double>? merchantShippingPrices,
    double? totalShippingPrice,
    Map<String, Map<String, double>>? merchantsShippingData,
  }) {
    return GovernoratesLoaded(
      governorates: governorates ?? this.governorates,
      selectedGovernorate: selectedGovernorate != null
          ? selectedGovernorate()
          : this.selectedGovernorate,
      shippingPrice: shippingPrice ?? this.shippingPrice,
      merchantShippingPrices:
          merchantShippingPrices ?? this.merchantShippingPrices,
      totalShippingPrice: totalShippingPrice ?? this.totalShippingPrice,
      merchantsShippingData:
          merchantsShippingData ?? this.merchantsShippingData,
    );
  }
}

class MerchantShippingPricesLoaded extends ShippingState {
  final List<ShippingPriceEntity> prices;
  final List<GovernorateEntity> governorates;

  const MerchantShippingPricesLoaded({
    required this.prices,
    required this.governorates,
  });

  @override
  List<Object?> get props => [prices, governorates];
}

class ShippingError extends ShippingState {
  final String message;
  const ShippingError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ShippingCubit extends Cubit<ShippingState> {
  final ShippingRepository _repository;

  ShippingCubit(this._repository) : super(ShippingInitial());

  Future<void> loadGovernorates() async {
    emit(ShippingLoading());

    final result = await _repository.getGovernorates();

    result.fold(
      (failure) => emit(ShippingError(failure.message)),
      (governorates) => emit(GovernoratesLoaded(governorates: governorates)),
    );
  }

  /// Load governorates with merchants shipping data in one call
  Future<void> loadGovernoratesWithAvailability(
      List<String> merchantIds) async {
    emit(ShippingLoading());

    final governoratesResult = await _repository.getGovernorates();

    await governoratesResult.fold(
      (failure) async => emit(ShippingError(failure.message)),
      (governorates) async {
        if (merchantIds.isEmpty) {
          emit(GovernoratesLoaded(governorates: governorates));
          return;
        }

        final dataResult =
            await _repository.getMerchantsShippingData(merchantIds);

        dataResult.fold(
          (_) => emit(GovernoratesLoaded(governorates: governorates)),
          (data) => emit(GovernoratesLoaded(
            governorates: governorates,
            merchantsShippingData: data,
          )),
        );
      },
    );
  }

  Future<void> selectGovernorate(
      GovernorateEntity governorate, String? merchantId) async {
    final currentState = state;
    if (currentState is GovernoratesLoaded) {
      emit(currentState.copyWith(
        selectedGovernorate: () => governorate,
        shippingPrice: 0,
      ));

      if (merchantId != null) {
        final priceResult =
            await _repository.getShippingPrice(merchantId, governorate.id);
        priceResult.fold(
          (_) {},
          (price) {
            if (state is GovernoratesLoaded) {
              emit(
                  (state as GovernoratesLoaded).copyWith(shippingPrice: price));
            }
          },
        );
      }
    }
  }

  /// Select governorate and calculate shipping for multiple merchants
  /// Uses pre-loaded data from merchantsShippingData
  void selectGovernorateForMultipleMerchants(
      GovernorateEntity governorate, List<String> merchantIds) {
    final currentState = state;
    if (currentState is GovernoratesLoaded) {
      // Get prices from pre-loaded data
      final governorateData =
          currentState.merchantsShippingData[governorate.id] ?? {};

      final Map<String, double> prices = {};
      double total = 0;

      for (final merchantId in merchantIds) {
        final price = governorateData[merchantId] ?? 0;
        prices[merchantId] = price;
        total += price;
      }

      emit(currentState.copyWith(
        selectedGovernorate: () => governorate,
        merchantShippingPrices: prices,
        totalShippingPrice: total,
        shippingPrice:
            merchantIds.isNotEmpty ? (prices[merchantIds.first] ?? 0) : 0,
      ));
    }
  }

  Future<void> loadMerchantShippingPrices(String merchantId) async {
    emit(ShippingLoading());

    final governoratesResult = await _repository.getGovernorates();
    final pricesResult =
        await _repository.getMerchantShippingPrices(merchantId);

    governoratesResult.fold(
      (failure) => emit(ShippingError(failure.message)),
      (governorates) {
        pricesResult.fold(
          (failure) => emit(ShippingError(failure.message)),
          (prices) => emit(MerchantShippingPricesLoaded(
            prices: prices,
            governorates: governorates,
          )),
        );
      },
    );
  }

  Future<void> setShippingPrice(
      String merchantId, String governorateId, double price) async {
    final result =
        await _repository.setShippingPrice(merchantId, governorateId, price);

    result.fold(
      (failure) => emit(ShippingError(failure.message)),
      (_) => loadMerchantShippingPrices(merchantId),
    );
  }

  Future<void> deleteShippingPrice(
      String merchantId, String governorateId) async {
    final result =
        await _repository.deleteShippingPrice(merchantId, governorateId);

    result.fold(
      (failure) => emit(ShippingError(failure.message)),
      (_) => loadMerchantShippingPrices(merchantId),
    );
  }

  /// Reset state - used when language changes
  void reset() {
    emit(ShippingInitial());
  }
}
