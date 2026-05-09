import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';

class DakshaBubble extends StatelessWidget {
  const DakshaBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: DT.elev2,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'द',
              style: DakshaTypography.caption.copyWith(
                fontFamily: 'NotoSansDevanagari',
                color: DT.muted,
              ),
            ),
          ),
          const SizedBox(width: DT.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DT.cardHPad,
                vertical: DT.lg,
              ),
              decoration: BoxDecoration(
                color: DT.elev1,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(color: DT.outline, width: DT.bwCard),
              ),
              // Gemma emits markdown (bold, italics, lists) for explanations,
              // so render it instead of showing raw asterisks. User-typed
              // messages stay plain Text in StudentBubble — only assistant
              // turns flow through here.
              //
              // TODO: LaTeX math (e.g. $$x = \frac{-b}{2a}$$, \(...\)) is not
              // yet rendered. Adding flutter_math_fork requires a custom
              // MarkdownElementBuilder for `$$...$$` fences and inline `\(...\)`
              // detection — deferred until the markdown path stabilises.
              child: MarkdownBody(
                data: text,
                selectable: false,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: DakshaTypography.body,
                  listBullet: DakshaTypography.body,
                  code: DakshaTypography.body.copyWith(
                    fontFamily: 'DMMono',
                    backgroundColor: DT.elev2,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: DT.elev2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
