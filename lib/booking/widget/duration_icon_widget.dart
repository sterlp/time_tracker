import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DurationIconWidget extends StatelessWidget {
  final Duration duration;
  const DurationIconWidget(this.duration, {super.key});

  @override
  Widget build(BuildContext context) {
    Icon result;
    const hour = 61;

    if (duration.inMinutes <= 1 * hour) {
      result = Icon(MdiIcons.clockTimeOneOutline);
    } else if (duration.inMinutes <= 2 * hour) {
      result = Icon(MdiIcons.clockTimeTwoOutline);
    } else if (duration.inMinutes <= 3 * hour) {
      result = Icon(MdiIcons.clockTimeThreeOutline);
    } else if (duration.inMinutes <= 4 * hour) {
      result = Icon(MdiIcons.clockTimeFourOutline);
    } else if (duration.inMinutes <= 5 * hour) {
      result = Icon(MdiIcons.clockTimeFiveOutline);
    } else if (duration.inMinutes <= 6 * hour) {
      result = Icon(MdiIcons.clockTimeSixOutline);
    } else if (duration.inMinutes <= 7 * hour) {
      result = Icon(MdiIcons.clockTimeSevenOutline);
    } else if (duration.inMinutes <= 8 * hour) {
      result = Icon(MdiIcons.clockTimeEightOutline);
    } else if (duration.inMinutes <= 9 * hour) {
      result = Icon(MdiIcons.clockTimeNineOutline);
    } else if (duration.inMinutes <= 10 * hour) {
      result = Icon(MdiIcons.clockTimeTenOutline);
    } else if (duration.inMinutes <= 11 * hour) {
      result = Icon(MdiIcons.clockTimeElevenOutline);
    } else {
      result = Icon(MdiIcons.clockTimeTwelveOutline);
    }
    return result;
  }
}
