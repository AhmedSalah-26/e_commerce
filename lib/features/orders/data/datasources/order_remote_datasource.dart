import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_datasource_interface.dart';
import 'mixins/order_fetch_mixin.dart';
import 'mixins/order_create_mixin.dart';
import 'mixins/order_update_mixin.dart';
import 'mixins/merchant_orders_mixin.dart';

export 'order_datasource_interface.dart';

/// Implementation of order remote data source using Supabase
class OrderRemoteDataSourceImpl
    with
        OrderFetchMixin,
        OrderCreateMixin,
        OrderUpdateMixin,
        MerchantOrdersMixin
    implements OrderRemoteDataSource {
  final SupabaseClient _client;

  OrderRemoteDataSourceImpl(this._client);

  @override
  SupabaseClient get client => _client;
}
