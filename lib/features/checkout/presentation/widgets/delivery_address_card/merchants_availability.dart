import 'package:flutter/material.dart';

class MerchantsAvailability extends StatelessWidget {
  final List<String> merchantIds;
  final Map<String, String> merchantsInfo;
  final Map<String, double> shippingData;
  final bool isRtl;

  const MerchantsAvailability({
    super.key,
    required this.merchantIds,
    required this.merchantsInfo,
    required this.shippingData,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isRtl ? 'توفر التوصيل:' : 'Delivery availability:',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...merchantIds.map((id) {
            final available = shippingData.containsKey(id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Icon(available ? Icons.check_circle : Icons.cancel,
                      size: 14, color: available ? Colors.green : Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      merchantsInfo[id] ?? id,
                      style: TextStyle(
                          fontSize: 12,
                          color: available
                              ? Colors.green.shade700
                              : Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
