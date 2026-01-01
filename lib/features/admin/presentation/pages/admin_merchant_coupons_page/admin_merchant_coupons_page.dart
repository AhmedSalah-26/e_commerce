import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/coupon_details_sheet.dart';
import '../../widgets/suspend_coupon_dialog.dart';
import 'coupons_header.dart';
import 'coupons_search_bar.dart';
import 'coupons_stats_row.dart';
import 'coupons_list.dart';
import 'coupons_empty_state.dart';

class AdminMerchantCouponsPage extends StatefulWidget {
  const AdminMerchantCouponsPage({super.key});

  @override
  State<AdminMerchantCouponsPage> createState() =>
      _AdminMerchantCouponsPageState();
}

class _AdminMerchantCouponsPageState extends State<AdminMerchantCouponsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _coupons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  static const _pageSize = 20;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCoupons();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadCoupons();
    }
  }

  Future<void> _loadCoupons() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      var query = Supabase.instance.client.from('coupons').select('''
        *, stores!inner(id, name, merchant_id, profiles!stores_merchant_id_fkey(id, name, email))
      ''');

      if (_searchQuery.isNotEmpty) {
        query = query.or('code.ilike.%$_searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(_page * _pageSize, (_page + 1) * _pageSize - 1);

      setState(() {
        _coupons.addAll(List<Map<String, dynamic>>.from(response));
        _page++;
        _hasMore = response.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _coupons.clear();
      _page = 0;
      _hasMore = true;
    });
    await _loadCoupons();
  }

  void _search(String query) {
    setState(() {
      _searchQuery = query;
      _coupons.clear();
      _page = 0;
      _hasMore = true;
    });
    _loadCoupons();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CouponsHeader(isRtl: isRtl, isDark: isDark),
          CouponsSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            isRtl: isRtl,
            isDark: isDark,
            onSearch: _search,
            onClear: () {
              _searchController.clear();
              _search('');
            },
          ),
          CouponsStatsRow(coupons: _coupons, isRtl: isRtl, isDark: isDark),
          Expanded(
            child: _coupons.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _coupons.isEmpty
                    ? CouponsEmptyState(isRtl: isRtl, isDark: isDark)
                    : CouponsList(
                        coupons: _coupons,
                        hasMore: _hasMore,
                        scrollController: _scrollController,
                        isRtl: isRtl,
                        onRefresh: _refresh,
                        onToggle: _toggleCoupon,
                        onSuspend: _handleSuspend,
                        onTap: (c) => _showDetails(c, isRtl),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, dynamic> coupon, bool isRtl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CouponDetailsSheet(coupon: coupon, isRtl: isRtl),
    );
  }

  Future<void> _toggleCoupon(Map<String, dynamic> coupon) async {
    try {
      await Supabase.instance.client.from('coupons').update(
          {'is_active': !(coupon['is_active'] ?? true)}).eq('id', coupon['id']);
      _refresh();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _handleSuspend(Map<String, dynamic> coupon) async {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final isSuspended = coupon['is_suspended'] ?? false;

    if (isSuspended) {
      await _unsuspendCoupon(coupon['id']);
    } else {
      final reason = await SuspendCouponDialog.show(context, isRtl: isRtl);
      if (reason != null && reason.isNotEmpty) {
        await _suspendCoupon(coupon['id'], reason);
      }
    }
  }

  Future<void> _suspendCoupon(String id, String reason) async {
    try {
      await Supabase.instance.client.from('coupons').update({
        'is_suspended': true,
        'suspension_reason': reason,
      }).eq('id', id);
      _refresh();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _unsuspendCoupon(String id) async {
    try {
      await Supabase.instance.client.from('coupons').update({
        'is_suspended': false,
        'suspension_reason': null,
      }).eq('id', id);
      _refresh();
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }
}
