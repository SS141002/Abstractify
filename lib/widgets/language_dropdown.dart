import 'package:flutter/material.dart';
import 'package:abstractify/models/languages.dart';

class MultiLanguageSelector extends StatelessWidget {
  final List<String> selectedLanguages;
  final Function(List<String>) onSelectionChanged;

  const MultiLanguageSelector({
    super.key,
    required this.selectedLanguages,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) => _LanguageDialog(
            selected: selectedLanguages,
          ),
        );

        if (result != null) {
          onSelectionChanged(result);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Languages',
          border: OutlineInputBorder(),
        ),
        child: Wrap(
          spacing: 8,
          children: selectedLanguages.isEmpty
              ? [const Text('Select languages')]
              : selectedLanguages.map((lang) {
            return Chip(
              label: Text(lang),
              onDeleted: () {
                final updated = List<String>.from(selectedLanguages)
                  ..remove(lang);
                onSelectionChanged(updated);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LanguageDialog extends StatefulWidget {
  final List<String> selected;

  const _LanguageDialog({required this.selected});

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = [...widget.selected];
  }

  void _onToggle(String lang) {
    setState(() {
      if (_tempSelected.contains(lang)) {
        _tempSelected.remove(lang);
      } else {
        _tempSelected.add(lang);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Languages"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: SupportedLanguage.values.map((lang) {
            final label = lang.label;
            return CheckboxListTile(
              title: Text(label),
              value: _tempSelected.contains(label),
              onChanged: (_) => _onToggle(label),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text("Done"),
        ),
      ],
    );
  }
}
