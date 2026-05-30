import 'package:flutter/material.dart';

class CkFormBuilder<T> extends StatefulWidget {
  const CkFormBuilder({
    required this.builder,
    required this.entity,
    this.scrollPhysics,
    this.scrollDirection = Axis.vertical,
    super.key,
  });

  final Widget Function(
    BuildContext context,
    GlobalKey<FormState> formKey,
    T entity,
  ) builder;

  final T entity;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;

  @override
  State<CkFormBuilder<T>> createState() => _CkFormBuilderState<T>();
}

class _CkFormBuilderState<T> extends State<CkFormBuilder<T>> {
  late final GlobalKey<FormState> _formKey;
  late T entity;

  @override
  void initState() {
    super.initState();
    entity = widget.entity;
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: widget.builder(context, _formKey, entity),
    );
    if (widget.scrollPhysics is NeverScrollableScrollPhysics) {
      return form;
    }
    return SingleChildScrollView(
      physics: widget.scrollPhysics,
      scrollDirection: widget.scrollDirection,
      child: form,
    );
  }
}

/// @deprecated Use [CkFormBuilder] instead.
@Deprecated('Use CkFormBuilder instead')
typedef FormBuilder<T> = CkFormBuilder<T>;
