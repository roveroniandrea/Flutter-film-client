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

  CustomProgress({Key? key, required this.isLoading, required this.loadingText, required this.child, required this.hasError, required this.errorChild});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _buildWidget(),
      switchInCurve: Curves.easeOutCirc,
      switchOutCurve: Curves.easeInCirc,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          children: currentChild != null ? <Widget>[
            ...previousChildren,
            currentChild,
          ]: [],
          alignment: Alignment.topCenter,
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          child: SlideTransition(
            child: child,
            position: Tween<Offset>(begin: Offset(-1,0), end: Offset(0, 0)).animate(animation),
          ),
          opacity: animation,
        );
      },
    );
  }

  Widget _buildWidget() {
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
