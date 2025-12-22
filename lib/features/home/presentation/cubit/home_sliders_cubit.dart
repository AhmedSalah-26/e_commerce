import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/product_repository.dart';

class HomeSlidersState {
  final List<ProductEntity> discountedProducts;
  final List<ProductEntity> newestProducts;
  final bool isLoadingDiscounted;
  final bool isLoadingNewest;

  const HomeSlidersState({
    this.discountedProducts = const [],
    this.newestProducts = const [],
    this.isLoadingDiscounted = false,
    this.isLoadingNewest = false,
  });

  HomeSlidersState copyWith({
    List<ProductEntity>? discountedProducts,
    List<ProductEntity>? newestProducts,
    bool? isLoadingDiscounted,
    bool? isLoadingNewest,
  }) {
    return HomeSlidersState(
      discountedProducts: discountedProducts ?? this.discountedProducts,
      newestProducts: newestProducts ?? this.newestProducts,
      isLoadingDiscounted: isLoadingDiscounted ?? this.isLoadingDiscounted,
      isLoadingNewest: isLoadingNewest ?? this.isLoadingNewest,
    );
  }
}

class HomeSlidersCubit extends Cubit<HomeSlidersState> {
  final ProductRepository _repository;

  HomeSlidersCubit(this._repository) : super(const HomeSlidersState());

  Future<void> loadSliders() async {
    emit(state.copyWith(isLoadingDiscounted: true, isLoadingNewest: true));

    // Load both in parallel
    final results = await Future.wait([
      _repository.getDiscountedProducts(limit: 10),
      _repository.getNewestProducts(limit: 10),
    ]);

    final discountedResult = results[0];
    final newestResult = results[1];

    emit(state.copyWith(
      discountedProducts: discountedResult.fold((_) => [], (p) => p),
      newestProducts: newestResult.fold((_) => [], (p) => p),
      isLoadingDiscounted: false,
      isLoadingNewest: false,
    ));
  }
}
