import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io'; // Needed for File class
// import 'package:open_filex/open_filex.dart'; // Import open_filex
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/models.dart'; // Import kIsWeb

class FileMessageView extends StatelessWidget {
  const FileMessageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
  }) : super(key: key);

  final Message message;
  final bool isMessageBySender;

  bool _isWebUrl(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }

  void _onFileTap(BuildContext context, String pathOrUrl) async {
    if (kIsWeb) {
      try {
        final uri = Uri.parse(pathOrUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opened web link: ${uri.host}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open web link.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL or error opening: $pathOrUrl')),
        );
      }
      return;
    }

    if (_isWebUrl(pathOrUrl)) {
      try {
        final uri = Uri.parse(pathOrUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opened web link: ${uri.host}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open web link: $pathOrUrl')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL or error opening: $pathOrUrl')),
        );
      }
    } else {
      String actualFilePath;
      if (pathOrUrl.startsWith('file:///')) {
        actualFilePath =
            Uri.decodeComponent(pathOrUrl.substring('file:///'.length));
      } else {
        actualFilePath = Uri.decodeComponent(pathOrUrl);
      }

      final File file = File(actualFilePath);

      if (await file.exists()) {
        try {
          final OpenResult result = await OpenFilex.open(actualFilePath);

          if (result.type == ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Opened file: ${file.path.split('/').last}')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Could not open file: ${file.path.split('/').last}. Error: ${result.message}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('An unexpected error occurred: ${e.toString()}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'File not found on device: ${file.path.split('/').last}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pathOrUrl = message.message;

    // Determine what to display based on whether it's a URL or a file path
    String displayFileName;
    IconData displayIcon;
    Color iconColor = isMessageBySender ? Colors.blue[700]! : Colors.grey[700]!;
    Color textColor = isMessageBySender ? Colors.blue[900]! : Colors.black87;

    if (_isWebUrl(pathOrUrl)) {
      displayFileName = Uri.parse(pathOrUrl).pathSegments.last;
      displayIcon = Icons.link;
    } else {
      String actualFilePath;
      if (pathOrUrl.startsWith('file:///')) {
        actualFilePath =
            Uri.decodeComponent(pathOrUrl.substring('file:///'.length));
      } else {
        actualFilePath = Uri.decodeComponent(pathOrUrl);
      }
      displayFileName = actualFilePath.split('/').last;
      displayIcon = Icons.insert_drive_file;
    }

    return GestureDetector(
      onTap: () => _onFileTap(context, pathOrUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(
          top: 6,
          right: isMessageBySender ? 6 : 0,
          left: isMessageBySender ? 0 : 6,
          bottom: message.reaction.reactions.isNotEmpty ? 15 : 0,
        ),
        decoration: BoxDecoration(
          color: isMessageBySender ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              displayIcon,
              color: iconColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayFileName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Conditional display for file size/status or URL status
                  _isWebUrl(pathOrUrl)
                      ? Text(
                          'Web Link',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        )
                      : FutureBuilder<bool>(
                          future: File(pathOrUrl.startsWith('file:///')
                                  ? Uri.decodeComponent(
                                      pathOrUrl.substring('file:///'.length))
                                  : Uri.decodeComponent(pathOrUrl))
                              .exists(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data == true) {
                                final file = File(pathOrUrl
                                        .startsWith('file:///')
                                    ? Uri.decodeComponent(
                                        pathOrUrl.substring('file:///'.length))
                                    : Uri.decodeComponent(pathOrUrl));
                                return Text(
                                  'File exists (${(file.lengthSync() / 1024).toStringAsFixed(2)} KB)',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                );
                              } else {
                                return Text(
                                  'File not found',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.red),
                                );
                              }
                            }
                            return const Text('Checking file...',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black54));
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
