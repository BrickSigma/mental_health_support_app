import 'package:flutter/material.dart';
import 'package:mental_health_support_app/models/journal_model.dart';
import 'package:provider/provider.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  @override
  Widget build(BuildContext context) {
    return Consumer<JournalModel>(
      builder: (context, journalModel, child) {
        List<JournalEntry> entries = journalModel.entries;

        return Scaffold(
          appBar: AppBar(title: const Text('Journal'), centerTitle: true),
          floatingActionButton: FloatingActionButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => JournalEntryFormPage(journalModel, false),
                  ),
                ),
            child: Icon(Icons.add),
          ),
          body: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(entries[index].id),
                onDismissed:
                    (direction) =>
                        journalModel.deleteJournalEntry(entries[index].id),
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                ),
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ViewJournalPage(journalModel, entries[index]),
                        ),
                      ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entries[index].title),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed:
                              () => journalModel.deleteJournalEntry(
                                entries[index].id,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Used for viewing a journal entry
class ViewJournalPage extends StatefulWidget {
  final JournalEntry entry;
  final JournalModel journalModel;

  const ViewJournalPage(this.journalModel, this.entry, {super.key});

  @override
  State<ViewJournalPage> createState() => _ViewJournalPageState();
}

class _ViewJournalPageState extends State<ViewJournalPage> {
  late ValueNotifier<JournalEntry> entryNotifier;

  @override
  void initState() {
    super.initState();
    entryNotifier = ValueNotifier(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: entryNotifier,
      builder: (context, child) {
        JournalEntry entry = entryNotifier.value;

        return Scaffold(
          appBar: AppBar(
            title: Text(entry.title),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => JournalEntryFormPage(
                              widget.journalModel,
                              true,
                              entryNotifier: entryNotifier,
                            ),
                      ),
                    ),
                icon: Icon(Icons.edit),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(12),
            child: Text(entry.contents),
          ),
        );
      },
    );
  }
}

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
