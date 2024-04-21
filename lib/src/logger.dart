// ignore_for_file: comment_references
import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/foundation.dart";

/// Print logs if [CamerawesomePlugins.printLogs] is true, otherwise stays quiet
void printLog(String text) {
  // TODOAdd Log levels (verbose/warning/error?): + native logs printing config?
  if (CamerawesomePlugin.printLogs) {
    debugPrint(text);
  }
}
