import 'package:flutter/material.dart';

/// Utilizzato per mostrare un widget di caricamento ed eventuale widget di errore
class CustomProgress extends StatelessWidget {
  /// Se [true] mostra [loadingText]
  final bool isLoading;

  /// Testo mostrato quando [isLoading == true]
  final String loadingText;

  /// Il widget mostrato di default
  final Widget child;

  /// Se [true] mostra [errorChild]
  final bool hasError;

  /// Widget mostrato quando [hasError == true]
  final Widget errorChild;

  CustomProgress({Key key, this.isLoading, this.loadingText, this.child, this.hasError, this.errorChild});

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      // In caso di errore mostro errorChild
      return errorChild;
    }
    // Se isLoading mostro il testo di caricamento con un CircularProgressIndicator, altrimenti il child normale
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
