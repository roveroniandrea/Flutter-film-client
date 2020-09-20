import 'package:flutter/material.dart';

class OptionsScreen extends StatefulWidget {
  static final routeName = '/options';
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opzioni'),
      ),
      body: Center(
        child: Text('WIP'),
      ),
    );
  }
}
