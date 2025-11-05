import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../util/simple_icon_utils.dart';

class ServiceIcon extends StatefulWidget {
  final String iconName;

  const ServiceIcon({
    super.key,
    required this.iconName,
    this.width = 40.0,
    this.height = 40.0,
  });

  final double width;
  final double height;

  @override
  State<ServiceIcon> createState() => _ServiceIconState();
}

// taken and adapted from https://stackoverflow.com/a/16348977
Color stringToColor(String str) {
  var hash = 0;
  for (var i = 0; i < str.length; i++) {
    final code = str.codeUnitAt(i);
    hash = code + ((hash << 5) - hash);
  }

  var color = '#';
  for (var i = 0; i < 3; i++) {
    final value = (hash >> (i * 8)) & 0xFF;
    color += value.toRadixString(16).padLeft(2, '0');
  }

  return Color(int.parse('0xFF${color.substring(1)}'));
}

Widget placeHolderCircle(ServiceIcon widget) {
  String firstIconLetter = widget.iconName.isNotEmpty ? widget.iconName[0].toUpperCase() : '';
  Color bgColor = widget.iconName.isNotEmpty ? stringToColor(widget.iconName) : Colors.grey;

  return Container(
    width: widget.width,
    height: widget.height,
    decoration: BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: firstIconLetter.isNotEmpty
          ? Text(
              firstIconLetter,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.width / 2,
                fontWeight: FontWeight.bold,
              ),
            )
          : Icon(
              Icons.person,
              color: Colors.white,
              size: widget.width / 2,
            ),
    ),
  );
}

class _ServiceIconState extends State<ServiceIcon> {
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
      return placeHolderCircle(widget);
    }
    Color iconColor = Color(int.parse('0xFF$_colorHex'));
    return SvgPicture.asset(
      SimpleIconsUtils.getIconAssetPath(widget.iconName),
      semanticsLabel: '${widget.iconName} logo',
      height: widget.height,
      width: widget.width,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      placeholderBuilder: (BuildContext context) => placeHolderCircle(widget),
    );
  }
}
