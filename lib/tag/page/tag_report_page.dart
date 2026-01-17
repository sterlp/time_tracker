import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/booking/entity/time_booking_statistics.dart';
import 'package:time_tracker/booking/service/booking_service.dart';
import 'package:time_tracker/tag/entity/tag.dart';
import 'package:time_tracker/tag/entity/tag_statistic.dart';
import 'package:time_tracker/tag/page/tag_management_page.dart';
import 'package:time_tracker/tag/service/tag_service.dart';

enum DateFilterMode { custom, lastYear, thisYear }

class TagReportPage extends StatefulWidget {
  final AppContainer _container;
  const TagReportPage(this._container, {super.key});

  @override
  State<TagReportPage> createState() => _TagReportPageState();
}

class _TagReportPageState extends State<TagReportPage> {
  DateFilterMode _filterMode = DateFilterMode.lastYear;
  DateTime? _customFrom;
  DateTime? _customTo;

  List<TagStatistic>? _tagStats;
  List<DailyBookingStatistic>? _untaggedDays;
  Map<String, List<Tag>>? _dayTags;

  DateTime get _fromDate {
    switch (_filterMode) {
      case DateFilterMode.thisYear:
        return DateTime(DateTime.now().year, 1, 1);
      case DateFilterMode.lastYear:
        return DateTime(DateTime.now().year - 1, 1, 1);
      case DateFilterMode.custom:
        return _customFrom ?? DateTime(DateTime.now().year - 1, 1, 1);
    }
  }

  DateTime get _toDate {
    switch (_filterMode) {
      case DateFilterMode.thisYear:
        return DateTime.now();
      case DateFilterMode.lastYear:
        return DateTime(DateTime.now().year - 1, 12, 31);
      case DateFilterMode.custom:
        return _customTo ?? DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final tagService = widget._container.get<TagService>();
    final bookingService = widget._container.get<BookingService>();

    // Get tag statistics
    _tagStats = await tagService.getTagStatistics(from: _fromDate, to: _toDate);

    // Get all days with tags in range
    _dayTags = await tagService.getDaysWithTagsInRange(_fromDate, _toDate);

    // Get all booking days and filter untagged ones
    final allStats = await bookingService.statisticByDay();
    final taggedDays = _dayTags!.keys.toSet();
    _untaggedDays = allStats.where((stat) {
      final inRange =
          !stat.start.isBefore(_fromDate) && !stat.start.isAfter(_toDate);
      return inRange && !taggedDays.contains(stat.day);
    }).toList();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag-Bericht'),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.tagTextOutline),
            tooltip: 'Tags verwalten',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagManagementPage(widget._container),
                ),
              );
              _reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateFilterButtons(),
          Expanded(
            child: _tagStats == null
                ? const Center(child: CircularProgressIndicator())
                : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<DateFilterMode>(
        segments: [
          ButtonSegment(
            value: DateFilterMode.custom,
            label: const Text('Zeitraum'),
            icon: Icon(MdiIcons.calendarRange),
          ),
          const ButtonSegment(
            value: DateFilterMode.lastYear,
            label: Text('Letztes Jahr'),
          ),
          const ButtonSegment(
            value: DateFilterMode.thisYear,
            label: Text('Dieses Jahr'),
          ),
        ],
        selected: {_filterMode},
        onSelectionChanged: (selection) async {
          final newMode = selection.first;
          if (newMode == DateFilterMode.custom) {
            await _showCustomDatePicker();
          }
          setState(() => _filterMode = newMode);
          _reload();
        },
      ),
    );
  }

  Widget _buildReportContent() {
    return ListView(
      children: [
        _buildTagSummarySection(),
        const Divider(thickness: 2),
        _buildUntaggedSection(),
      ],
    );
  }

  Widget _buildTagSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Tags Übersicht',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        if (_tagStats!.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Keine Tags vorhanden'),
          )
        else
          ..._tagStats!.map((stat) => _buildTagCard(stat)),
      ],
    );
  }

  Widget _buildTagCard(TagStatistic stat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          MdiIcons.tag,
          color: stat.tag.color,
        ),
        title: Text(stat.tag.name),
        trailing: Text(
          '${stat.dayCount} Tage',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => _showTagDetails(stat.tag),
      ),
    );
  }

  Widget _buildUntaggedSection() {
    final count = _untaggedDays?.length ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                'Ohne Tag',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: 8),
              Chip(label: Text('$count Tage')),
            ],
          ),
        ),
        if (_untaggedDays != null && _untaggedDays!.isNotEmpty)
          ...(_untaggedDays!.take(10).map(
                (day) => ListTile(
                  title: Text(day.day),
                  subtitle: Text(_formatDuration(day.workedTime)),
                  trailing: IconButton(
                    icon: Icon(MdiIcons.tagPlus),
                    tooltip: 'Tag hinzufügen',
                    onPressed: () => _addTagToDay(day.day),
                  ),
                ),
              )),
        if (_untaggedDays != null && _untaggedDays!.length > 10)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: _showAllUntagged,
              child: Text('Alle ${_untaggedDays!.length} anzeigen'),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}min';
  }

  Future<void> _showCustomDatePicker() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );
    if (range != null) {
      setState(() {
        _customFrom = range.start;
        _customTo = range.end;
      });
    }
  }

  Future<void> _showTagDetails(Tag tag) async {
    final tagService = widget._container.get<TagService>();
    final days =
        await tagService.getDaysWithTag(tag.id!, from: _fromDate, to: _toDate);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(MdiIcons.tag, color: tag.color),
                const SizedBox(width: 8),
                Text(
                  tag.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                Text('${days.length} Tage'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(days[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllUntagged() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Tage ohne Tag',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  Text('${_untaggedDays!.length} Tage'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _untaggedDays!.length,
                itemBuilder: (context, index) {
                  final day = _untaggedDays![index];
                  return ListTile(
                    title: Text(day.day),
                    subtitle: Text(_formatDuration(day.workedTime)),
                    trailing: IconButton(
                      icon: Icon(MdiIcons.tagPlus),
                      onPressed: () {
                        Navigator.pop(context);
                        _addTagToDay(day.day);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTagToDay(String day) async {
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
    _reload();
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
