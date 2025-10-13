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
  bool _loaded = false;
  String _colorHex = 'FFFFFF';

  @override
  void initState() {
    super.initState();
    SimpleIconsUtils().loadIconDataArray().then((_) {
      setState(() {
        _colorHex = SimpleIconsUtils().getIconHexColor(widget.iconName);
        // slight hack to ensure the icon is only shown when it actually exists to avoid an error being thrown by SvgPicture for the missing asset
        if (_colorHex != '') {
          _loaded = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.transparent,
      );
    }
    Color iconColor = Color(int.parse('0xFF$_colorHex'));
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
