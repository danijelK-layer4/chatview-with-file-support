import 'package:flutter/material.dart';

class LoadingMessageView extends StatelessWidget {
  LoadingMessageView();

  @override
  Widget build(BuildContext context) {
    // Determine what to display based on whether it's a URL or a file path

    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      margin: EdgeInsets.only(
        top: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.grey[100],
        ),
      ),
    );
  }
}
