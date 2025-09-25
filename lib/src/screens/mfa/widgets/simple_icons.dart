import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../util/simple_icon_utils.dart';

class SimpleIcon extends StatelessWidget {
  final String iconName;
  const SimpleIcon({
    super.key,
    required this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    var colorHex = SimpleIconsUtils().getIconHexColor(iconName);
    Color iconColor = Color(int.parse('0xFF$colorHex'));

    return SvgPicture.asset('assets/simple-icons/icons/${iconName.toLowerCase()}.svg', semanticsLabel: '$iconName logo', height: 40, width: 40,colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        placeholderBuilder: (BuildContext context) => Container(
          padding: const EdgeInsets.all(10.0),
          child: const CircularProgressIndicator(),
        ));
  }
}
