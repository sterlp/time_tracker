import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/booking/dao/time_booking_dao.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/page/bookings_list_page.dart';
import 'package:time_tracker/booking/page/edit_booking_page.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/booking/widget/bookings_statistic_widget.dart';
import 'package:time_tracker/booking/widget/daily_booking_statistic_widget.dart';
import 'package:time_tracker/home/widget/loading_widget.dart';
import 'package:time_tracker/tag/entity/tag.dart';
import 'package:time_tracker/tag/service/tag_service.dart';

class BookingsHistoryPage extends StatefulWidget {
  final AppContainer _container;
  const BookingsHistoryPage(this._container, {super.key});

  @override
  _BookingsHistoryPageState createState() => _BookingsHistoryPageState();

}

class _BookingsHistoryPageState extends State<BookingsHistoryPage> {
  final _stats = ValueNotifier<List<DailyBookingStatistic>?>(null);
  Map<String, List<Tag>> _dayTags = {};

  Future<void> _reload() async {
    _stats.value = await widget._container.get<TimeBookingDao>().stats();
    await _loadTags();
  }

  Future<void> _loadTags() async {
    final tagService = widget._container.get<TagService>();
    final now = DateTime.now();
    final from = DateTime(now.year - 1, 1, 1);
    _dayTags = await tagService.getDaysWithTagsInRange(from, now);
    if (mounted) setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _reload();
  }
  @override
  void dispose() {
    _stats.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DailyBookingStatistic>?>(
      valueListenable: _stats,
      builder: (context, value, child) {
        if (value == null) {
          return const LoadingWidget();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Historie'),
            ),
            body: _buildWeekList(value),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await showBookingPageWithCallback(context, widget._container);
                if (mounted) _reload();
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }

  Widget _buildWeekList(List<DailyBookingStatistic> value) {
    return ListView.builder(
      itemCount: value.length,
      itemBuilder: (context, index) {
        final item = value[index];

        if (index == 0) {
          return Column(
            children: [
              BookingsStatisticWidget(DailyBookingStatisticList.of(value)),
              _buildWeekItem(item),
            ],
          );
        } else {
          return _buildWeekItem(item);
        }
      },
    );
  }

  Widget _buildWeekItem(DailyBookingStatistic item) {
    return DailyBookingStatisticWidget(
      item,
      tags: _dayTags[item.day] ?? [],
      onLongPress: () async {
        if (item.bookingsCount > 1) {
          await showBookingListPage(context, widget._container, item.start, item.end);
        } else {
          final booking = await widget._container
              .get<BookingService>()
              .getBookingByStartDate(item.start);
          if (mounted) await showEditBookingPage(context, widget._container, booking: booking);
        }
        if (mounted) _reload();
      },
      onTagTap: () => _showTagDialog(item.day),
    );
  }

  Future<void> _showTagDialog(String day) async {
    final tagService = widget._container.get<TagService>();
    final allTags = await tagService.getAllTags();
    final selectedTags = await tagService.getTagsForDay(day);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _TagSelectionDialog(
        day: day,
        allTags: allTags,
        selectedTags: selectedTags,
        tagService: tagService,
      ),
    );
    await _loadTags();
  }
}

class _TagSelectionDialog extends StatefulWidget {
  final String day;
  final List<Tag> allTags;
  final List<Tag> selectedTags;
  final TagService tagService;

  const _TagSelectionDialog({
    required this.day,
    required this.allTags,
    required this.selectedTags,
    required this.tagService,
  });

  @override
  State<_TagSelectionDialog> createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends State<_TagSelectionDialog> {
  late List<Tag> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tags für ${widget.day}'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.allTags.map((tag) {
          final isSelected = _selectedTags.any((t) => t.id == tag.id);
          return FilterChip(
            label: Text(tag.name),
            selected: isSelected,
            selectedColor: tag.color?.withAlpha(77),
            avatar: Icon(MdiIcons.tag, size: 18, color: tag.color),
            onSelected: (selected) async {
              if (selected) {
                await widget.tagService.addTagToDay(widget.day, tag);
                _selectedTags.add(tag);
              } else {
                await widget.tagService.removeTagFromDay(widget.day, tag);
                _selectedTags.removeWhere((t) => t.id == tag.id);
              }
              setState(() {});
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fertig'),
        ),
      ],
    );
  }
}
