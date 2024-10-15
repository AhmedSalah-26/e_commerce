import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Core/Sharedwidgets/CustomButton.dart';
import '../../../../Core/Theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../Domain/CartScreenProvider.dart';
import '../cart_screen.dart';
import 'cost_section_ui.dart';

class DeliveryOptions extends StatelessWidget {
  final CartProvider cartScreenProvider;
  final bool isWideScreen;
  final double responsiveHeight;

  const DeliveryOptions({
    required this.cartScreenProvider,
    required this.isWideScreen,
    required this.responsiveHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isWideScreen ? 24.0 : 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AutoSizeText(
            "خيارات التوصيل",
            style: AppTextStyle.normal_12_black.copyWith(
              fontSize: MediaQuery.of(context).size.width * (18.0 / 375),
            ),
            maxLines: 1,
          ),
          DeliveryOptionsRow(cartScreenProvider: cartScreenProvider),
          CostSectionUi(
            subtotal: cartScreenProvider.calculateTotal(),
            deliveryFee: cartScreenProvider.getDeliveryFee(),
          ),
          SizedBox(height: responsiveHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                label: "تأكيد الطلب",
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeliveryOptionsRow extends StatelessWidget {
  final CartProvider cartScreenProvider;

  const DeliveryOptionsRow({required this.cartScreenProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DeliveryOptionRadio(
            value: "Home Delivery",
            label: "توصيل للمنزل",
            cartScreenProvider: cartScreenProvider,
          ),
          const SizedBox(width: 10),
          DeliveryOptionRadio(
            value: "Pick-up",
            label: "استلام من المتجر",
            cartScreenProvider: cartScreenProvider,
          ),
        ],
      ),
    );
  }
}

class DeliveryOptionRadio extends StatelessWidget {
  final String value;
  final String label;
  final CartProvider cartScreenProvider;

  const DeliveryOptionRadio({
    required this.value,
    required this.label,
    required this.cartScreenProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
          activeColor: AppColours.brownLight,
          value: value,
          groupValue: cartScreenProvider.getDeliveryOption(),
          onChanged: (newValue) {
            cartScreenProvider.setDeliveryOption(newValue.toString());
            cartScreenProvider
                .setDeliveryFee(newValue == "Home Delivery" ? 20.0 : 0.0);
          },
        ),
        AutoSizeText(
          label,
          style: AppTextStyle.normal_12_black,
        ),
      ],
    );
  }
}
