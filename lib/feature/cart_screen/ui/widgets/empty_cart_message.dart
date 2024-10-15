import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Core/Theme/app_text_style.dart';

class EmptyCartMessage extends StatelessWidget {
  const EmptyCartMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AutoSizeText(
        "السلة فارغة",
        style: AppTextStyle.normal_16_greyDark.copyWith(fontSize: MediaQuery.of(context).size.width * (18.0 / 375), ),
        ),
    );
  }
}
