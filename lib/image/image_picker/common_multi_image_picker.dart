import 'package:core_kit/image/common_image.dart';
import 'package:core_kit/utils/permission_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class CommonMultiImagePickerFormField extends FormField<List<String>> {
  CommonMultiImagePickerFormField({
    super.key,
    bool isMulti = true,
    bool isFullScreenEnabled = true,
    int? limit,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    List<String> super.initialValue = const [],
  }) : super(
         builder: (FormFieldState<List<String>> field) {
           return _CommonMultiImagePickerField(
             field: field,
             isMulti: isMulti,
             limit: limit,
             isFullScreenEnabled: isFullScreenEnabled,
           );
         },
       );
}

class _CommonMultiImagePickerField extends StatefulWidget {
  const _CommonMultiImagePickerField({
    required this.field,
    required this.isMulti,
    required this.limit,
    required this.isFullScreenEnabled,
  });
  final FormFieldState<List<String>> field;
  final bool isMulti;
  final int? limit;
  final bool isFullScreenEnabled;

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
    final status = await PermissionHelper.request(Permission.photos);
    if (!status) return;

    if (widget.isMulti) {
      var files = (await _picker.pickMultiImage(limit: widget.limit));
      if (files.isEmpty) return;

   

      final existingNames = _images.map((img) => p.basename(img.path)).toSet();
      final newFiles = files.where((file) {
        final name = p.basename(file.path);
        return !existingNames.contains(name);
      }).toList();

      if (newFiles.isNotEmpty) {
          _images.addAll(newFiles);
        setState(() {
          if (widget.limit != null) {
            if (_images.length > widget.limit!) {
              _images = _images.take(widget.limit!).toList();
            }
          }
      
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1,
            ),
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              if (index == _images.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
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
                );
              }

              // Image item
              final XFile file = _images[index];

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
                      child: CommonImage(
                        src: file.path,
                        width: double.infinity,
                        height: double.infinity,
                        fill: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
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
      ),
    );
  }
}
