import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';

/// SafeArea-aware bottom action bar. Accepts 1–2 CTA widgets (typically
/// [PrimaryButton] or [DakshaOutlineButton]).
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.children,
  }) : assert(children.length >= 1 && children.length <= 2,
            'BottomActionBar accepts 1 or 2 children');

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: DT.bg,
        border: Border(top: BorderSide(color: DT.outline, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
        DT.contentPad,
        DT.lg,
        DT.contentPad,
        DT.bottomSafe + bottomInset,
      ),
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: DT.sm),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}
