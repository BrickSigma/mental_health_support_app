import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/journal_model.dart';

/// Used for creating or editing a journal entry
class JournalEntryFormPage extends StatefulWidget {
  /// Indicates whether the entry is being created or edited.
  final bool isEditing;

  /// If `isEditing` is `true`, this must not be `null`.
  final ValueNotifier<JournalEntry>? entryNotifier;

  final JournalModel journalModel;

  const JournalEntryFormPage(
    this.journalModel,
    this.isEditing, {
    super.key,
    this.entryNotifier,
  });

  @override
  State<JournalEntryFormPage> createState() => _JournalEntryFormPageState();
}

class _JournalEntryFormPageState extends State<JournalEntryFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.entryNotifier != null) {
      _titleController.text = widget.entryNotifier!.value.title;
      _contentsController.text = widget.entryNotifier!.value.contents;
    }
  }

  void _saveEntry(BuildContext context, JournalModel journalModel) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    JournalEntry updatedEntry = JournalEntry(
      "",
      _titleController.text,
      widget.isEditing
          ? widget.entryNotifier!.value.entryDateTime
          : DateTime.now(),
      _contentsController.text,
    );
    if (widget.isEditing) {
      journalModel.updateJournalEntry(
        widget.entryNotifier!.value.id,
        updatedEntry,
      );
      widget.entryNotifier!.value = updatedEntry;
    } else {
      journalModel.addJournalEntry(updatedEntry);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? "Edit Entry" : "Create Entry"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _saveEntry(context, widget.journalModel),
            child: Text("Save"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Journal Title",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _contentsController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Contents",
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter some text";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
