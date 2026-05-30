import 'package:flutter/material.dart';

class CkForm extends StatefulWidget {
  const CkForm({required this.builder, super.key});

  final Widget Function(BuildContext context, GlobalKey<FormState> formKey) builder;

  @override
  _CkFormState createState() => _CkFormState();
}

class _CkFormState extends State<CkForm> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: widget.builder(context, _formKey),
    );
  }
}

