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
                  onTap: null,
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
