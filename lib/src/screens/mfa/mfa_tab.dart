import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../providers/irma_repository_provider.dart';
import '../../theme/theme.dart';
import '../../util/navigation.dart';
import '../../widgets/irma_app_bar.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/yivi_themed_button.dart';
import '../home/widgets/irma_nav_bar.dart';


class MfaTab extends StatefulWidget {
  @override
  State<MfaTab> createState() => _MfaTabState();
}

class _MfaTabState extends State<MfaTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Text('MFA Tab')),
    );
  }
}
