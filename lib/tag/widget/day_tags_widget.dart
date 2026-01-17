import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/tag/entity/tag.dart';

class DayTagsWidget extends StatelessWidget {
  final List<Tag> tags;
  final VoidCallback? onTap;

  const DayTagsWidget({
    super.key,
    required this.tags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(MdiIcons.tag, size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 4),
            if (tags.isEmpty)
              Text(
                'Keine Tags',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              )
            else
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags
                      .map((tag) => Chip(
                            label: Text(
                              tag.name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: tag.color?.withAlpha(51),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ),
            if (onTap != null)
              Icon(
                MdiIcons.pencil,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
          ],
        ),
      ),
    );
  }
}
