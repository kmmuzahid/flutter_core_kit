/*
 * @Author: Km Muzahid
 * @Date: 2026-01-18 13:32:11
 * @Email: km.muzahid@gmail.com
 */
import 'package:flutter/material.dart';

class FormBuilder<T> extends StatefulWidget {
  const FormBuilder({
    required this.builder,
    required this.entity,
    this.scrollPhysics,
    this.scrollDirection = Axis.vertical,
    super.key,
  });

  final Widget Function(BuildContext context, GlobalKey<FormState> formKey, T entity) builder;

  final T entity;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;

  @override
  State<FormBuilder<T>> createState() => _FormBuilderState<T>();
}

class _FormBuilderState<T> extends State<FormBuilder<T>> {
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
    final form = Form(key: _formKey, child: widget.builder(context, _formKey, entity));
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
