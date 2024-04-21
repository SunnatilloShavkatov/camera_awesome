import "package:camera_awesome/camerawesome_plugin.dart";
import "package:flutter/material.dart";

class AwesomeFilterNameIndicator extends StatelessWidget {

  const AwesomeFilterNameIndicator({
    super.key,
    required this.state,
  });
  final CameraState state;

  @override
  Widget build(BuildContext context) => StreamBuilder<AwesomeFilter>(
      stream: state.filter$,
      builder: (BuildContext context, AsyncSnapshot<AwesomeFilter> snapshot) => snapshot.hasData
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Text(
                    snapshot.data!.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
    );
}
