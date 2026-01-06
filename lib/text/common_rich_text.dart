/*
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:41:53
 * @Email: km.muzahid@gmail.com
 */
import 'package:core_kit/initializer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class CommonRichTextContent {}

class CommonRichTextSpan extends CommonRichTextContent {
  CommonRichTextSpan({required this.textSpan});
  final TextSpan textSpan;
}

class CommonSimpleRichTextContent extends CommonRichTextContent {
  CommonSimpleRichTextContent({required this.text, this.style, this.ontap});
  final Function()? ontap;
  final String text;
  final TextStyle? style;
}

class CommonRichText extends StatelessWidget {
  ///usage:
  ///richTextContent: [CommonSimpleRichTextContent(text: '', style: TextStyle, ontap: (){}),
  ///CommonRichTextSpan(textSpan : TextSpan() , ontap: (){})]
  const CommonRichText({required this.richTextContent, super.key});
  final List<CommonRichTextContent> richTextContent;

  @override
  Widget build(BuildContext context) {
    return _content();
  }

  Widget _content() {
    return Text.rich(
      TextSpan(
        children: List.generate(richTextContent.length, (index) {
          final rContent = richTextContent[index];

          if (rContent is CommonSimpleRichTextContent) {
            final style = rContent.style?.copyWith(fontFamily: CoreKit.instance.fontFamily);
            return TextSpan(
              text: rContent.text,
              style:
                  style ??
                  CoreKit.instance.defaultTextStyle?.copyWith(
                    fontFamily: CoreKit.instance.fontFamily,
                  ),
              recognizer: rContent.ontap == null
                  ? null
                  : (TapGestureRecognizer()..onTap = rContent.ontap),
            );
          } else if (rContent is CommonRichTextSpan) {
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
