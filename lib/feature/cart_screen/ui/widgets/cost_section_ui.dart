import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cost_row.dart';

class CostSectionUi extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  const CostSectionUi({super.key, required this.subtotal, required this.deliveryFee});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CostRow(label: "سعر المنتجات", amount: subtotal),
        CostRow(label: "رسوم التوصيل", amount: deliveryFee),
        Divider(),
        CostRow(label: "الاجمالي", amount: subtotal + deliveryFee, isBold: true),
      ],
    );
  }
}
