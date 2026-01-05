// import 'package:flutter/material.dart';
// import 'package:mainland/core/component/text_field/input_helper.dart';
// import 'package:quill_html_editor_v3/quill_html_editor_v3.dart';

// class CustomQuillField extends StatefulWidget {
//   final String? initialText;
//   final String? hintText;
//   final bool readOnly;
//   final int? maxLength;
//   final double height;
//   final double borderRadius;
//   final double borderWidth;
//   final Color? borderColor;
//   final Color? backgroundColor;
//   final ValueChanged<String> onSave;
//   final ValueChanged<String>? onChanged;
//   final FocusNode? focusNode;
//   final ValidationType validator;

//   const CustomQuillField({
//     Key? key,
//     this.initialText,
//     this.hintText,
//     this.readOnly = false,
//     this.maxLength,
//     required this.height,
//     required this.borderRadius,
//     required this.borderWidth,
//     required this.onSave,
//     this.onChanged,
//     this.borderColor,
//     this.backgroundColor,
//     required this.validator,
//     this.focusNode,
//   }) : super(key: key);

//   @override
//   _CustomQuillFieldState createState() => _CustomQuillFieldState();
// }

// class _CustomQuillFieldState extends State<CustomQuillField> {
//   ///[controller] create a QuillEditorController to access the editor methods
//   late QuillEditorController controller;

//   ///[customToolBarList] pass the custom toolbarList to show only selected styles in the editor

//   final customToolBarList = [
//     ToolBarStyle.bold,
//     ToolBarStyle.italic,
//     ToolBarStyle.align,
//     ToolBarStyle.color,
//     ToolBarStyle.background,
//     ToolBarStyle.listBullet,
//     ToolBarStyle.listOrdered,
//     ToolBarStyle.clean,
//     ToolBarStyle.addTable,
//     ToolBarStyle.editTable,
//   ];

//   final _toolbarColor = Colors.grey.shade200;
//   final _backgroundColor = Colors.white70;
//   final _toolbarIconColor = Colors.black87;
//   final _editorTextStyle = const TextStyle(
//     fontSize: 18,
//     color: Colors.black,
//     fontWeight: FontWeight.normal,
//     fontFamily: 'Roboto',
//   );
//   final _hintTextStyle = const TextStyle(
//     fontSize: 18,
//     color: Colors.black38,
//     fontWeight: FontWeight.normal,
//   );

//   bool _hasFocus = false;

//   @override
//   void initState() {
//     controller = QuillEditorController();
//     controller.onTextChanged((text) {
//       debugPrint('listening to $text');
//     });
//     controller.onEditorLoaded(() {
//       debugPrint('Editor Loaded :)');
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     /// please do not forget to dispose the controller
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return SizedBox(
//       height: widget.height,
//       child: QuillHtmlEditor(
//         text: widget.initialText,
//         hintText: widget.hintText,
//         controller: controller,
//         isEnabled: true,
//         ensureVisible: false,
//         minHeight: widget.height,
//         autoFocus: false,
//         textStyle: _editorTextStyle,
//         hintTextStyle: _hintTextStyle,
//         hintTextAlign: TextAlign.start,
//         padding: const EdgeInsets.only(left: 10, top: 10),
//         hintTextPadding: const EdgeInsets.only(left: 20),
//         backgroundColor: _backgroundColor,
//         inputAction: InputAction.newline,
//         onEditingComplete: widget.onSave,
//         loadingBuilder: (context) {
//           return const Center(child: CircularProgressIndicator(strokeWidth: 1, color: Colors.red));
//         },
//         onFocusChanged: (focus) {
//           debugPrint('has focus $focus');
//           setState(() {
//             _hasFocus = focus;
//           });
//         },
//         onTextChanged: widget.onChanged,
//         onEditorCreated: () => debugPrint('Editor has been loaded'),
//         onEditorResized: (height) => debugPrint('Editor resized $height'),
//         onSelectionChanged: (sel) => debugPrint('index ${sel.index}, range ${sel.length}'),
//       ),
//     );
//   }

//   Widget textButton({required String text, required VoidCallback onPressed}) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: MaterialButton(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         color: _toolbarIconColor,
//         onPressed: onPressed,
//         child: Text(text, style: TextStyle(color: _toolbarColor)),
//       ),
//     );
//   }

//   ///[getHtmlText] to get the html text from editor
//   void getHtmlText() async {
//     String? htmlText = await controller.getText();
//     debugPrint(htmlText);
//   }

//   ///[setHtmlText] to set the html text to editor
//   void setHtmlText(String text) async {
//     await controller.setText(text);
//   }

//   ///[insertNetworkImage] to set the html text to editor
//   void insertNetworkImage(String url) async {
//     await controller.embedImage(url);
//   }

//   ///[insertVideoURL] to set the video url to editor
//   ///this method recognises the inserted url and sanitize to make it embeddable url
//   ///eg: converts youtube video to embed video, same for vimeo
//   void insertVideoURL(String url) async {
//     await controller.embedVideo(url);
//   }

//   /// to set the html text to editor
//   /// if index is not set, it will be inserted at the cursor postion
//   void insertHtmlText(String text, {int? index}) async {
//     await controller.insertText(text, index: index);
//   }

//   /// to clear the editor
//   void clearEditor() => controller.clear();

//   /// to enable/disable the editor
//   void enableEditor(bool enable) => controller.enableEditor(enable);

//   /// method to un focus editor
//   void unFocusEditor() => controller.unFocus();
// }
