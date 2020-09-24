import 'package:flutter/material.dart';

class CustomProgress extends StatelessWidget {
  final bool isLoading;
  final String loadingText;
  final Widget child;
  final bool hasError;
  final Widget errorChild;

  CustomProgress(
      {Key key,
      this.isLoading,
      this.loadingText,
      this.child,
      this.hasError,
      this.errorChild});

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return errorChild;
    }
    return isLoading
        ? Center(
            child: Column(
              children: [
                Container(
                  child: Text(loadingText, style: TextStyle(fontSize: 20.0)),
                  padding: EdgeInsets.all(30.0),
                ),
                SizedBox(
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 7.0,
                  ),
                  height: 100.0,
                  width: 100.0,
                ),
              ],
            ),
          )
        : child;
  }
}
