import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/data/repositories/product_repository_impl.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';

class HomeSlidersState {
  final List<ProductEntity> flashSaleProducts;
  final List<ProductEntity> discountedProducts;
  final List<ProductEntity> newestProducts;
  final bool isLoadingFlashSale;
  final bool isLoadingDiscounted;
  final bool isLoadingNewest;

  const HomeSlidersState({
    this.flashSaleProducts = const [],
    this.discountedProducts = const [],
    this.newestProducts = const [],
    this.isLoadingFlashSale = false,
    this.isLoadingDiscounted = false,
    this.isLoadingNewest = false,
  });

  HomeSlidersState copyWith({
    List<ProductEntity>? flashSaleProducts,
    List<ProductEntity>? discountedProducts,
    List<ProductEntity>? newestProducts,
    bool? isLoadingFlashSale,
    bool? isLoadingDiscounted,
    bool? isLoadingNewest,
  }) {
    return HomeSlidersState(
      flashSaleProducts: flashSaleProducts ?? this.flashSaleProducts,
      discountedProducts: discountedProducts ?? this.discountedProducts,
      newestProducts: newestProducts ?? this.newestProducts,
      isLoadingFlashSale: isLoadingFlashSale ?? this.isLoadingFlashSale,
      isLoadingDiscounted: isLoadingDiscounted ?? this.isLoadingDiscounted,
      isLoadingNewest: isLoadingNewest ?? this.isLoadingNewest,
    );
  }
}

class HomeSlidersCubit extends Cubit<HomeSlidersState> {
  final ProductRepository _repository;
  bool _isLoading = false;

  HomeSlidersCubit(this._repository) : super(const HomeSlidersState());

  /// Set the locale for fetching products
  void setLocale(String locale) {
    if (_repository is ProductRepositoryImpl) {
      _repository.setLocale(locale);
    }
  }

  Future<void> loadSliders() async {
    // Prevent duplicate loading
    if (_isLoading) return;
    if (state.discountedProducts.isNotEmpty &&
        state.newestProducts.isNotEmpty) {
      return; // Already loaded
    }

    await _fetchSliders();
  }

  /// Force refresh sliders
  Future<void> refreshSliders() async {
    _isLoading = false;
    emit(const HomeSlidersState());
    await _fetchSliders();
  }

  /// Reset state and force reload - used when language changes
  Future<void> reset() async {
    _isLoading = false;
    emit(const HomeSlidersState());
    await _fetchSliders();
  }

  Future<void> _fetchSliders() async {
    _isLoading = true;
    emit(state.copyWith(
      isLoadingFlashSale: true,
      isLoadingDiscounted: true,
      isLoadingNewest: true,
    ));

    // Load all in parallel
    final results = await Future.wait([
      _repository.getFlashSaleProducts(limit: 10),
      _repository.getDiscountedProducts(limit: 20),
      _repository.getNewestProducts(limit: 10),
    ]);

    final flashSaleResult = results[0];
    final discountedResult = results[1];
    final newestResult = results[2];

    _isLoading = false;
    emit(state.copyWith(
      flashSaleProducts: flashSaleResult.fold((_) => [], (p) => p),
      discountedProducts: discountedResult.fold((_) => [], (p) => p),
      newestProducts: newestResult.fold((_) => [], (p) => p),
      isLoadingFlashSale: false,
      isLoadingDiscounted: false,
      isLoadingNewest: false,
    ));
  }
}
