import 'package:dependency_container/dependency_container.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:time_tracker/tag/entity/tag.dart';
import 'package:time_tracker/tag/service/tag_service.dart';

class TagManagementPage extends StatefulWidget {
  final AppContainer _container;
  const TagManagementPage(this._container, {super.key});

  @override
  State<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends State<TagManagementPage> {
  List<Tag>? _tags;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final tagService = widget._container.get<TagService>();
    _tags = await tagService.getAllTags();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags verwalten'),
      ),
      body: _tags == null
          ? const Center(child: CircularProgressIndicator())
          : _buildTagList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTag,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagList() {
    if (_tags!.isEmpty) {
      return const Center(
        child: Text('Keine Tags vorhanden'),
      );
    }

    return ListView.builder(
      itemCount: _tags!.length,
      itemBuilder: (context, index) {
        final tag = _tags![index];
        return ListTile(
          leading: Icon(MdiIcons.tag, color: tag.color),
          title: Text(tag.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editTag(tag),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTag(tag),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addTag() async {
    final result = await showDialog<Tag>(
      context: context,
      builder: (context) => const _EditTagDialog(),
    );
    if (result != null) {
      final tagService = widget._container.get<TagService>();
      await tagService.saveTag(result);
      _reload();
    }
  }

  Future<void> _editTag(Tag tag) async {
    final result = await showDialog<Tag>(
      context: context,
      builder: (context) => _EditTagDialog(tag: tag),
    );
    if (result != null) {
      final tagService = widget._container.get<TagService>();
      await tagService.saveTag(result);
      _reload();
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag löschen'),
        content: Text('Möchten Sie den Tag "${tag.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final tagService = widget._container.get<TagService>();
      await tagService.deleteTag(tag);
      _reload();
    }
  }
}

class _EditTagDialog extends StatefulWidget {
  final Tag? tag;

  const _EditTagDialog({this.tag});

  @override
  State<_EditTagDialog> createState() => _EditTagDialogState();
}

class _EditTagDialogState extends State<_EditTagDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Color? _selectedColor;

  static const List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedColor = widget.tag?.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tag != null;

    return AlertDialog(
      title: Text(isEditing ? 'Tag bearbeiten' : 'Neuer Tag'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'z.B. Homeoffice',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte einen Namen eingeben';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Farbe:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final tag = widget.tag ?? Tag(_nameController.text.trim());
              tag.name = _nameController.text.trim();
              tag.color = _selectedColor;
              Navigator.pop(context, tag);
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
