import 'package:core_kit/image/common_image.dart';
import 'package:core_kit/utils/permission_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class CommonMultiImagePickerFormField extends StatefulWidget {
  final bool isMulti;
  final bool isFullScreenEnabled;
  final int? limit;
  final List<String> initialValue;
  final String Function(List<XFile> list)? validator;
  final void Function(List<XFile> value)? onSaved;
  final void Function(XFile? file, String path)? onRemove;
  const CommonMultiImagePickerFormField({
    super.key,
    this.isMulti = true,
    this.isFullScreenEnabled = true,
    this.limit,
    this.initialValue = const [],
    this.onSaved,
    this.onRemove,
    this.validator,
  });

  @override
  State<CommonMultiImagePickerFormField> createState() =>
      _CommonMultiImagePickerField();
}

class _CommonMultiImagePickerField
    extends State<CommonMultiImagePickerFormField> {
  final ImagePicker _picker = ImagePicker();

  /// Shown in the grid (network, asset, file path, etc.). Not part of form value.
  List<String> _initialSources = [];

  /// Only gallery picks — this is what [onSaved] / validation receive.
  List<XFile> _picked = [];

  @override
  void initState() {
    super.initState();
    _initialSources = List<String>.from(widget.initialValue);
  }

  @override
  void didUpdateWidget(CommonMultiImagePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.initialValue, widget.initialValue)) {
      _initialSources = List<String>.from(widget.initialValue);
    }
  }

  /// Slots used toward [limit] (multi: initials + picks; single: one visible slot).
  int _countTowardLimit() {
    if (!widget.isMulti) {
      if (_picked.isNotEmpty) return 1;
      return _initialSources.isNotEmpty ? 1 : 0;
    }
    return _initialSources.length + _picked.length;
  }

  /// How many images appear in the grid (single mode shows at most one cell).
  int get _displayCount {
    if (!widget.isMulti) {
      return (_picked.isNotEmpty || _initialSources.isNotEmpty) ? 1 : 0;
    }
    return _initialSources.length + _picked.length;
  }

  bool get _showAddButton {
    if (!widget.isMulti) return true;
    final lim = widget.limit;
    if (lim == null) return true;
    return _countTowardLimit() < lim;
  }

  String _srcAtDisplayIndex(int index) {
    if (!widget.isMulti) {
      if (_picked.isNotEmpty) return _picked.first.path;
      return _initialSources.first;
    }
    if (index < _initialSources.length) return _initialSources[index];
    return _picked[index - _initialSources.length].path;
  }

  Future<void> _pickImages(FormFieldState<List<XFile>> fieldState) async {
    final status = await PermissionHelper.request(Permission.photos);
    if (!status) return;

    if (!widget.isMulti) {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      setState(() {
        _picked
          ..clear()
          ..add(file);
        fieldState.didChange(List<XFile>.from(_picked));
      });
      return;
    }

    final lim = widget.limit;
    final remaining = lim == null ? null : (lim - _countTowardLimit());
    if (remaining != null && remaining <= 0) return;

    final pickLimit = remaining ?? lim;
    final files = await _picker.pickMultiImage(
      limit: pickLimit == null || pickLimit <= 0 ? null : pickLimit,
    );
    if (files.isEmpty) return;

    final existingNames = _picked.map((img) => p.basename(img.path)).toSet();
    var newFiles = files.where((file) {
      final name = p.basename(file.path);
      return !existingNames.contains(name);
    }).toList();

    if (lim != null) {
      final allowed = lim - _countTowardLimit();
      if (allowed <= 0) return;
      if (newFiles.length > allowed) {
        newFiles = newFiles.take(allowed).toList();
      }
    }

    if (newFiles.isEmpty) return;

    setState(() {
      _picked.addAll(newFiles);
      fieldState.didChange(List<XFile>.from(_picked));
    });
  }

  void _removeAt(int index, FormFieldState<List<XFile>> fieldState) {
    if (!widget.isMulti) {
      if (_picked.isNotEmpty) {
        final f = _picked.first;
        widget.onRemove?.call(f, f.path);
        _picked.clear();
      } else if (_initialSources.isNotEmpty) {
        final s = _initialSources.first;
        widget.onRemove?.call(null, s);
        _initialSources.removeAt(0);
      }
    } else {
      if (index < _initialSources.length) {
        final s = _initialSources[index];
        widget.onRemove?.call(null, s);
        _initialSources.removeAt(index);
      } else {
        final j = index - _initialSources.length;
        final f = _picked[j];
        widget.onRemove?.call(f, f.path);
        _picked.removeAt(j);
      }
    }
    fieldState.didChange(List<XFile>.from(_picked));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<XFile>>(
      initialValue: const [],
      validator: (file) {
        return widget.validator?.call(file ?? []) ?? '';
      },
      onSaved: (fields) {
        widget.onSaved?.call(fields ?? []);
      },
      builder: (fieldState) {
        final itemCount = _displayCount + (_showAddButton ? 1 : 0);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: fieldState.hasError
                  ? Theme.of(context).colorScheme.error
                  : Colors.grey.shade300,
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
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (_showAddButton && index == _displayCount) {
                    return GestureDetector(
                      onTap: () => _pickImages(fieldState),
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
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 26,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }

                  final src = _srcAtDisplayIndex(index);

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
                            src: src,
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
                          onTap: () => _removeAt(index, fieldState),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              if (fieldState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: Text(
                    fieldState.errorText ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
