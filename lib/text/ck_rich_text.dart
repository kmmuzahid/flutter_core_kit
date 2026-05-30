import 'package:core_kit/initializer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class CkRichTextContent {}

class CkRichTextSpan extends CkRichTextContent {
  CkRichTextSpan({required this.textSpan});
  final TextSpan textSpan;
}

class CkSimpleRichTextContent extends CkRichTextContent {
  CkSimpleRichTextContent({required this.text, this.style, this.ontap});
  final Function()? ontap;
  final String text;
  final TextStyle? style;
}

class CkRichText extends StatelessWidget {
  /// usage:
  /// richTextContent: [CkSimpleRichTextContent(text: '', style: TextStyle, ontap: (){}),
  /// CkRichTextSpan(textSpan: TextSpan())]
  const CkRichText({required this.richTextContent, super.key});
  final List<CkRichTextContent> richTextContent;

  @override
  Widget build(BuildContext context) {
    return _content();
  }

  Widget _content() {
    return Text.rich(
      TextSpan(
        children: List.generate(richTextContent.length, (index) {
          final rContent = richTextContent[index];

          if (rContent is CkSimpleRichTextContent) {
            final style = rContent.style?.copyWith(
              fontFamily: coreKitInstance.fontFamily,
            );
            return TextSpan(
              text: rContent.text,
              style:
                  style ??
                  coreKitInstance.defaultTextStyle?.copyWith(
                    fontFamily: coreKitInstance.fontFamily,
                  ),
              recognizer: rContent.ontap == null
                  ? null
                  : (TapGestureRecognizer()..onTap = rContent.ontap),
            );
          } else if (rContent is CkRichTextSpan) {
            return rContent.textSpan;
          } else {
            return const TextSpan(text: '');
          }
        }),
      ),
      softWrap: true,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
    );
  }
}

/// @deprecated Use [CkRichTextContent] instead.
@Deprecated('Use CkRichTextContent instead')
typedef CommonRichTextContent = CkRichTextContent;

/// @deprecated Use [CkRichTextSpan] instead.
@Deprecated('Use CkRichTextSpan instead')
typedef CommonRichTextSpan = CkRichTextSpan;

/// @deprecated Use [CkSimpleRichTextContent] instead.
@Deprecated('Use CkSimpleRichTextContent instead')
typedef CommonSimpleRichTextContent = CkSimpleRichTextContent;

/// @deprecated Use [CkRichText] instead.
@Deprecated('Use CkRichText instead')
typedef CommonRichText = CkRichText;
