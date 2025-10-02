import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../util/simple_icon_utils.dart';

class SimpleIcon extends StatefulWidget {
  final String iconName;
  const SimpleIcon({
    super.key,
    required this.iconName,
  });

  @override
  State<SimpleIcon> createState() => _SimpleIconState();
}

class _SimpleIconState extends State<SimpleIcon> {
  @override
  Widget build(BuildContext context) {
    String? colorHex = SimpleIconsUtils().getIconHexColor(widget.iconName);
    if (colorHex == '000000') {
      // default to transparent
      colorHex = 'FFFFFF';
    }

    Color iconColor = Color(int.parse('0xFF$colorHex'));
    return SvgPicture.asset(
      SimpleIconsUtils.getIconAssetPath(widget.iconName),
      semanticsLabel: '${widget.iconName} logo',
      height: 40,
      width: 40,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      placeholderBuilder: (BuildContext context) => Container(
        height: 40,
        width: 40,
        color: Colors.transparent,
      ),
    );
  }
}
