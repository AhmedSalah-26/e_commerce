import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/merchant_coupon_card.dart';
import '../widgets/coupon_details_sheet.dart';
import '../widgets/coupon_stat_chip.dart';
import '../widgets/suspend_coupon_dialog.dart';

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
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(isRtl: isRtl, isDark: isDark),
          _SearchBar(
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
          _StatsRow(coupons: _coupons, isRtl: isRtl, isDark: isDark),
          Expanded(
            child: _coupons.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _coupons.isEmpty
                    ? _EmptyState(isRtl: isRtl, isDark: isDark)
                    : _CouponsList(
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

// Private Widgets
class _Header extends StatelessWidget {
  final bool isRtl;
  final bool isDark;

  const _Header({required this.isRtl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        isRtl ? 'كوبونات التجار' : 'Merchant Coupons',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final bool isRtl;
  final bool isDark;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.isRtl,
    required this.isDark,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: isRtl ? 'بحث بكود الكوبون...' : 'Search by coupon code...',
          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          prefixIcon: Icon(Icons.search,
              color: isDark ? Colors.white54 : Colors.black45),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.white54 : Colors.black45),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onSubmitted: onSearch,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;
  final bool isRtl;
  final bool isDark;

  const _StatsRow(
      {required this.coupons, required this.isRtl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final activeCount = coupons
        .where((c) => c['is_active'] == true && c['is_suspended'] != true)
        .length;
    final suspendedCount =
        coupons.where((c) => c['is_suspended'] == true).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Wrap(
        spacing: 8,
        children: [
          CouponStatChip(
              label: isRtl ? 'الكل' : 'All',
              count: coupons.length,
              color: Colors.blue,
              isDark: isDark),
          CouponStatChip(
              label: isRtl ? 'نشط' : 'Active',
              count: activeCount,
              color: Colors.green,
              isDark: isDark),
          CouponStatChip(
              label: isRtl ? 'موقوف' : 'Suspended',
              count: suspendedCount,
              color: Colors.red,
              isDark: isDark),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isRtl;
  final bool isDark;

  const _EmptyState({required this.isRtl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:
                  (isDark ? Colors.white : Colors.grey).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_offer_outlined,
                size: 48, color: isDark ? Colors.white38 : Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد كوبونات' : 'No coupons found',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _CouponsList extends StatelessWidget {
  final List<Map<String, dynamic>> coupons;
  final bool hasMore;
  final ScrollController scrollController;
  final bool isRtl;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, dynamic>) onToggle;
  final Future<void> Function(Map<String, dynamic>) onSuspend;
  final void Function(Map<String, dynamic>) onTap;

  const _CouponsList({
    required this.coupons,
    required this.hasMore,
    required this.scrollController,
    required this.isRtl,
    required this.onRefresh,
    required this.onToggle,
    required this.onSuspend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: coupons.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == coupons.length) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()));
          }
          return MerchantCouponCard(
            coupon: coupons[index],
            isRtl: isRtl,
            onToggle: () => onToggle(coupons[index]),
            onSuspend: () => onSuspend(coupons[index]),
            onTap: () => onTap(coupons[index]),
          );
        },
      ),
    );
  }
}
