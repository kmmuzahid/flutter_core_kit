import 'dart:io';

import 'package:core_kit/utils/permission_handler_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class CommonMultiImagePickerFormField extends FormField<List<String>> {
  CommonMultiImagePickerFormField({
    super.key,
    bool isMulti = true,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    List<String> super.initialValue = const [],
  }) : super(
         builder: (FormFieldState<List<String>> field) {
           return _CommonMultiImagePickerField(field: field, isMulti: isMulti);
         },
       );
}

class _CommonMultiImagePickerField extends StatefulWidget {
  const _CommonMultiImagePickerField({required this.field, required this.isMulti});
  final FormFieldState<List<String>> field;
  final bool isMulti;

  @override
  State<_CommonMultiImagePickerField> createState() => _CommonMultiImagePickerFieldState();
}

class _CommonMultiImagePickerFieldState extends State<_CommonMultiImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _images = widget.field.value?.map(XFile.new).toList() ?? [];
  }

  void _pickImages() async {
    final permissionHandlerHelper = PermissionHandlerHelper(permission: Permission.photos);
    final status = await permissionHandlerHelper.getStatus();
    if (!status) return;

    if (widget.isMulti) {
      final files = await _picker.pickMultiImage();
      if (files.isEmpty) return;

      final existingNames = _images.map((img) => p.basename(img.path)).toSet();
      final newFiles = files.where((file) {
        final name = p.basename(file.path);
        return !existingNames.contains(name);
      }).toList();

      if (newFiles.isNotEmpty) {
        setState(() {
          _images.addAll(newFiles);
          // Notify FormField of change
          widget.field.didChange(_images.map((x) => x.path).toList());
        });
      }
    } else {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      setState(() {
        _images
          ..clear()
          ..add(file);
        widget.field.didChange(_images.map((x) => x.path).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      widget.field.didChange(_images.map((x) => x.path).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.field.hasError ? Theme.of(context).colorScheme.error : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final double size = (constraints.maxWidth / 3) - 10;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 5,
                      children: [
                        ..._images.asMap().entries.map((entry) {
                          final int i = entry.key;
                          final XFile file = entry.value;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(8),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(file.path),
                                    width: size,
                                    height: size,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: GestureDetector(
                                  onTap: () => _removeImage(i),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.add_a_photo_outlined, size: 26, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (widget.field.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    widget.field.errorText ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
