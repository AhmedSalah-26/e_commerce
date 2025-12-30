import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        *,
        profiles:merchant_id(id, name, email)
      ''').not('merchant_id', 'is', null);

      if (_searchQuery.isNotEmpty) {
        query = query.or('code.ilike.%$_searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(_page * _pageSize, (_page + 1) * _pageSize - 1);

      final coupons = List<Map<String, dynamic>>.from(response);

      setState(() {
        _coupons.addAll(coupons);
        _page++;
        _hasMore = coupons.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'كوبونات التجار' : 'Merchant Coupons'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, isRtl),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _coupons.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _coupons.isEmpty
                      ? _buildEmptyState(isRtl)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _coupons.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _coupons.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _CouponCard(
                              coupon: _coupons[index],
                              isRtl: isRtl,
                              onToggle: () => _toggleCoupon(_coupons[index]),
                              onSuspend: () =>
                                  _showSuspendDialog(_coupons[index]),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: isRtl ? 'بحث بكود الكوبون...' : 'Search by coupon code...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: _search,
      ),
    );
  }

  Widget _buildEmptyState(bool isRtl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isRtl ? 'لا توجد كوبونات' : 'No coupons found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCoupon(Map<String, dynamic> coupon) async {
    final isActive = coupon['is_active'] ?? true;
    try {
      await Supabase.instance.client
          .from('coupons')
          .update({'is_active': !isActive}).eq('id', coupon['id']);
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showSuspendDialog(Map<String, dynamic> coupon) async {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final isSuspended = coupon['is_suspended'] ?? false;

    if (isSuspended) {
      // Unsuspend
      try {
        await Supabase.instance.client.from('coupons').update({
          'is_suspended': false,
          'suspension_reason': null,
        }).eq('id', coupon['id']);
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
      return;
    }

    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'إيقاف الكوبون' : 'Suspend Coupon'),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: isRtl ? 'سبب الإيقاف' : 'Suspension Reason',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isRtl ? 'إيقاف' : 'Suspend'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await Supabase.instance.client.from('coupons').update({
          'is_suspended': true,
          'suspension_reason': result,
        }).eq('id', coupon['id']);
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isRtl;
  final VoidCallback onToggle;
  final VoidCallback onSuspend;

  const _CouponCard({
    required this.coupon,
    required this.isRtl,
    required this.onToggle,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = coupon['code'] ?? '';
    final discountType = coupon['discount_type'] ?? 'percentage';
    final discountValue = (coupon['discount_value'] ?? 0).toDouble();
    final isActive = coupon['is_active'] ?? true;
    final isSuspended = coupon['is_suspended'] ?? false;
    final suspensionReason = coupon['suspension_reason'];
    final merchant = coupon['profiles'] as Map<String, dynamic>?;
    final merchantName = merchant?['name'] ?? '';
    final usageCount = coupon['usage_count'] ?? 0;
    final usageLimit = coupon['usage_limit'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSuspended ? Colors.red.withValues(alpha: 0.05) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuspended
                  ? Colors.red
                  : (isActive ? Colors.green : Colors.orange),
              child: Icon(
                isSuspended
                    ? Icons.block
                    : (isActive
                        ? Icons.local_offer
                        : Icons.local_offer_outlined),
                color: Colors.white,
              ),
            ),
            title: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isSuspended ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discountType == 'percentage'
                      ? '${discountValue.toStringAsFixed(0)}%'
                      : '${discountValue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (merchantName.isNotEmpty)
                  Text(
                    '${isRtl ? 'التاجر:' : 'Merchant:'} $merchantName',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                Text(
                  '${isRtl ? 'الاستخدام:' : 'Usage:'} $usageCount${usageLimit != null ? '/$usageLimit' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle') onToggle();
                if (value == 'suspend') onSuspend();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive
                          ? (isRtl ? 'تعطيل' : 'Deactivate')
                          : (isRtl ? 'تفعيل' : 'Activate')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(
                        isSuspended ? Icons.check_circle : Icons.block,
                        size: 18,
                        color: isSuspended ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSuspended
                            ? (isRtl ? 'إلغاء الإيقاف' : 'Unsuspend')
                            : (isRtl ? 'إيقاف' : 'Suspend'),
                        style: TextStyle(
                          color: isSuspended ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSuspended && suspensionReason != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${isRtl ? 'سبب الإيقاف:' : 'Reason:'} $suspensionReason',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
