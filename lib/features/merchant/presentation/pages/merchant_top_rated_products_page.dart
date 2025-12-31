import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../widgets/top_rated_product_card.dart';

class MerchantTopRatedProductsPage extends StatefulWidget {
  const MerchantTopRatedProductsPage({super.key});

  @override
  State<MerchantTopRatedProductsPage> createState() =>
      _MerchantTopRatedProductsPageState();
}

class _MerchantTopRatedProductsPageState
    extends State<MerchantTopRatedProductsPage> {
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  static const _pageSize = 10;
  String? _merchantId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        _merchantId = authState.user.id;
        _loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore || _merchantId == null) return;

    setState(() => _isLoading = true);

    try {
      // First try to get products with ratings
      var response = await Supabase.instance.client
          .from('products')
          .select('''
            id, name_ar, name_en, images, price, 
            rating, rating_count, is_active
          ''')
          .eq('merchant_id', _merchantId!)
          .gt('rating_count', 0)
          .order('rating', ascending: false)
          .order('rating_count', ascending: false)
          .range(_page * _pageSize, (_page + 1) * _pageSize - 1);

      var products = List<Map<String, dynamic>>.from(response);

      // If no rated products found on first page, show all products sorted by rating
      if (products.isEmpty && _page == 0) {
        response = await Supabase.instance.client
            .from('products')
            .select('''
              id, name_ar, name_en, images, price, 
              rating, rating_count, is_active
            ''')
            .eq('merchant_id', _merchantId!)
            .eq('is_active', true)
            .order('rating', ascending: false)
            .order('created_at', ascending: false)
            .range(_page * _pageSize, (_page + 1) * _pageSize - 1);

        products = List<Map<String, dynamic>>.from(response);
      }

      setState(() {
        _products.addAll(products);
        _page++;
        _hasMore = products.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _products.clear();
      _page = 0;
      _hasMore = true;
    });
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isRtl ? 'المنتجات الأعلى تقييماً' : 'Top Rated Products',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _products.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
                ? _buildEmptyState(isRtl)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return TopRatedProductCard(
                        product: _products[index],
                        isRtl: isRtl,
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState(bool isRtl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد منتجات' : 'No products found',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? 'أضف منتجات لمتجرك أولاً'
                : 'Add products to your store first',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
