import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DurationIconWidget extends StatelessWidget {
  final Duration duration;
  const DurationIconWidget(this.duration, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon result;
    const hour = 61;

    if (duration.inMinutes <= 1 * hour) {
      result = const Icon(MdiIcons.clockTimeOneOutline);
    } else if (duration.inMinutes <= 2 * hour) {
      result = const Icon(MdiIcons.clockTimeTwoOutline);
    } else if (duration.inMinutes <= 3 * hour) {
      result = const Icon(MdiIcons.clockTimeThreeOutline);
    } else if (duration.inMinutes <= 4 * hour) {
      result = const Icon(MdiIcons.clockTimeFourOutline);
    } else if (duration.inMinutes <= 5 * hour) {
      result = const Icon(MdiIcons.clockTimeFiveOutline);
    } else if (duration.inMinutes <= 6 * hour) {
      result = const Icon(MdiIcons.clockTimeSixOutline);
    } else if (duration.inMinutes <= 7 * hour) {
      result = const Icon(MdiIcons.clockTimeSevenOutline);
    } else if (duration.inMinutes <= 8 * hour) {
      result = const Icon(MdiIcons.clockTimeEightOutline);
    }else if (duration.inMinutes <= 9 * hour) {
      result = const Icon(MdiIcons.clockTimeNineOutline);
    }else if (duration.inMinutes <= 10 * hour) {
      result = const Icon(MdiIcons.clockTimeTenOutline);
    }else if (duration.inMinutes <= 11 * hour) {
      result = const Icon(MdiIcons.clockTimeElevenOutline);
    } else {
      result = const Icon(MdiIcons.clockTimeTwelveOutline);
    }
    return result;
  }
}
