import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/theme.dart';
import '../../../util/simple_icon_utils.dart';
import '../../../widgets/irma_avatar.dart';

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

String getInitials(String name) {
  if (name.isEmpty) return '?'; // fallback for empty names, should not happen usually since we either send the issuer or user account

  if (name.contains('-')) {
    var parts = name.split('-');
    return parts.map((part) => part.isNotEmpty ? part[0].toUpperCase() : '').join();
  } else if (name.contains(' ')) {
    var parts = name.split(' ');
    return parts.map((part) => part.isNotEmpty ? part[0].toUpperCase() : '').join();
  } else if (name.length >= 2) {
    return name.substring(0, 2).toUpperCase();
  } else {
    return name[0].toUpperCase();
  }
}

Widget placeHolderCircle(ServiceIcon widget, Color color) {
  String initials = getInitials(widget.iconName);

  return IrmaAvatar(
    size: widget.width < widget.height ? widget.width : widget.height,
    initials: initials,
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
    final theme = IrmaTheme.of(context);
    if (!_loaded) {
      return placeHolderCircle(widget, theme.neutralExtraLight);
    }
    Color iconColor = Color(int.parse('0xFF$_colorHex'));
    return SvgPicture.asset(
      SimpleIconsUtils.getIconAssetPath(widget.iconName),
      semanticsLabel: '${widget.iconName} logo',
      height: widget.height,
      width: widget.width,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      placeholderBuilder: (BuildContext context) => placeHolderCircle(widget, theme.neutralExtraLight),
    );
  }
}
