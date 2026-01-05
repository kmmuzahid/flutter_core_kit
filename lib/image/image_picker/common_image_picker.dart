import 'dart:io';

import 'package:core_kit/utils/core_screen_utils.dart';
import 'package:core_kit/utils/permission_handler_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonImagePicker extends StatefulWidget {
  const CommonImagePicker({
    super.key,
    this.width = 160,
    this.height = 160,
    this.borderRadius = 10,
    this.pickerIcon = Icons.image,
    this.onSaved,
    this.validator,
  });

  final double width;
  final double height;
  final double borderRadius;
  final IconData pickerIcon;
  final void Function(XFile?)? onSaved;
  final FormFieldValidator<XFile>? validator;

  @override
  State<CommonImagePicker> createState() => _CommonImagePickerState();
}

class _CommonImagePickerState extends State<CommonImagePicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImages;

  Future<void> _pickImage(FormFieldState<XFile> fieldState) async {
    final permissionHandlerHelper = PermissionHandlerHelper(permission: Permission.photos);
    final status = await permissionHandlerHelper.getStatus();
    if (!status) return;
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImages = picked; // Always replace
      });
      fieldState.didChange(_selectedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<XFile>(
      initialValue: _selectedImages,
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (fieldState) {
        final hasError = fieldState.hasError;
        final isCircular = widget.borderRadius.r >= widget.width / 2;
        final borderColor = hasError ? Colors.red : Colors.transparent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                  child: Container(
                    width: widget.width.w,
                    height: widget.height.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1.5),
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    ),
                    child: _selectedImages != null
                        ? Image.file(File(_selectedImages!.path), fit: BoxFit.cover)
                        : Icon(
                            widget.pickerIcon,
                            size: widget.width / 1.8,
                            color: Theme.of(context).primaryColor,
                          ),
                  ),
                ),
                _buildCameraIcon(() => _pickImage(fieldState), isCircular),
              ],
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCameraIcon(VoidCallback onTap, bool isCircular) {
    double right = 8;
    double bottom = 8;

    if (isCircular) {
      final radius = widget.width.w / 2;
      final offset = radius * 0.12;
      right = offset;
      bottom = offset;
    }

    return Positioned(
      bottom: bottom,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30.h,
          width: 30.w,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
