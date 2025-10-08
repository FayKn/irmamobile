import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../util/simple_icon_utils.dart';

class SimpleIcon extends StatefulWidget {
  final String iconName;

  const SimpleIcon({
    super.key,
    required this.iconName,
    this.width = 40.0,
    this.height = 40.0,
  });

  final double width;
  final double height;

  @override
  State<SimpleIcon> createState() => _SimpleIconState();
}

class _SimpleIconState extends State<SimpleIcon> {
  @override
  void initState() {
    super.initState();
    SimpleIconsUtils().loadIconDataArray().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String colorHex = 'FFFFFF';
    setState(() {
      colorHex = SimpleIconsUtils().getIconHexColor(widget.iconName);
    });
    Color iconColor = Color(int.parse('0xFF$colorHex'));
    return SvgPicture.asset(
      SimpleIconsUtils.getIconAssetPath(widget.iconName),
      semanticsLabel: '${widget.iconName} logo',
      height: widget.height,
      width: widget.width,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      placeholderBuilder: (BuildContext context) => Container(
        height: widget.height,
        width: widget.width,
        color: Colors.transparent,
      ),
    );
  }
}
