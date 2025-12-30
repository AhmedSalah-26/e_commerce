import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/inventory_remote_datasource.dart';
import '../../domain/entities/inventory_insight_entity.dart';

// States
abstract class InventoryInsightsState extends Equatable {
  const InventoryInsightsState();

  @override
  List<Object?> get props => [];
}

class InventoryInsightsInitial extends InventoryInsightsState {}

class InventoryInsightsLoading extends InventoryInsightsState {}

class InventoryInsightsLoaded extends InventoryInsightsState {
  final InventoryInsightsSummary summary;
  final List<ProductInventoryDetail> products;
  final String currentFilter;

  const InventoryInsightsLoaded({
    required this.summary,
    required this.products,
    this.currentFilter = 'all',
  });

  @override
  List<Object?> get props => [summary, products, currentFilter];

  InventoryInsightsLoaded copyWith({
    InventoryInsightsSummary? summary,
    List<ProductInventoryDetail>? products,
    String? currentFilter,
  }) {
    return InventoryInsightsLoaded(
      summary: summary ?? this.summary,
      products: products ?? this.products,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class InventoryInsightsError extends InventoryInsightsState {
  final String message;

  const InventoryInsightsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class InventoryInsightsCubit extends Cubit<InventoryInsightsState> {
  final InventoryRemoteDataSource _dataSource;
  String? _currentMerchantId;

  InventoryInsightsCubit(this._dataSource) : super(InventoryInsightsInitial());

  Future<void> loadInsights(String merchantId) async {
    _currentMerchantId = merchantId;
    emit(InventoryInsightsLoading());

    try {
      final summary = await _dataSource.getInventoryInsights(merchantId);
      final products = await _dataSource.getInventoryDetails(merchantId);

      emit(InventoryInsightsLoaded(
        summary: summary,
        products: products,
      ));
    } catch (e) {
      emit(InventoryInsightsError(e.toString()));
    }
  }

  Future<void> filterProducts(String filter) async {
    if (_currentMerchantId == null) return;
    if (state is! InventoryInsightsLoaded) return;

    final currentState = state as InventoryInsightsLoaded;

    try {
      final products = await _dataSource.getInventoryDetails(
        _currentMerchantId!,
        filter: filter,
      );

      emit(currentState.copyWith(
        products: products,
        currentFilter: filter,
      ));
    } catch (e) {
      // Keep current state on filter error
    }
  }

  Future<void> refresh() async {
    if (_currentMerchantId != null) {
      await loadInsights(_currentMerchantId!);
    }
  }
}
