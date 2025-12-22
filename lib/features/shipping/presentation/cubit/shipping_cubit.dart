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

  const GovernoratesLoaded({
    required this.governorates,
    this.selectedGovernorate,
    this.shippingPrice = 0,
    this.merchantShippingPrices = const {},
    this.totalShippingPrice = 0,
  });

  @override
  List<Object?> get props => [
        governorates,
        selectedGovernorate,
        shippingPrice,
        merchantShippingPrices,
        totalShippingPrice,
      ];

  GovernoratesLoaded copyWith({
    List<GovernorateEntity>? governorates,
    GovernorateEntity? Function()? selectedGovernorate,
    double? shippingPrice,
    Map<String, double>? merchantShippingPrices,
    double? totalShippingPrice,
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
  Future<void> selectGovernorateForMultipleMerchants(
      GovernorateEntity governorate, List<String> merchantIds) async {
    final currentState = state;
    if (currentState is GovernoratesLoaded) {
      emit(currentState.copyWith(
        selectedGovernorate: () => governorate,
        shippingPrice: 0,
        merchantShippingPrices: {},
        totalShippingPrice: 0,
      ));

      if (merchantIds.isNotEmpty) {
        final pricesResult = await _repository
            .getMultipleMerchantsShippingPrices(merchantIds, governorate.id);
        pricesResult.fold(
          (_) {},
          (prices) {
            if (state is GovernoratesLoaded) {
              // Calculate total shipping
              double total = 0;
              for (final merchantId in merchantIds) {
                total += prices[merchantId] ?? 0;
              }
              emit((state as GovernoratesLoaded).copyWith(
                merchantShippingPrices: prices,
                totalShippingPrice: total,
                // Keep shippingPrice as first merchant's price for backward compatibility
                shippingPrice: merchantIds.isNotEmpty
                    ? (prices[merchantIds.first] ?? 0)
                    : 0,
              ));
            }
          },
        );
      }
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
}
