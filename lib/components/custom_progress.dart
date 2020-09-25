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
      return Center(
        child: errorChild,
      );
    }
    return isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text(loadingText, style: TextStyle(fontSize: 25.0)),
                  padding: EdgeInsets.all(40.0),
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
