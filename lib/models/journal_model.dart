import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Stores the patient's journal
class JournalModel extends ChangeNotifier {
  List<JournalEntry> entries = [];
  String _patientId = "";

  /// Sort entries by their
  void _sortEntries() {
    entries.sort((a, b) => b.entryDateTime.compareTo(a.entryDateTime));
  }

  /// Load journal entries for a patient
  Future<void> loadJournal(String patientId) async {
    _patientId = patientId;

    final db = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db
            .collection("patients")
            .doc(_patientId)
            .collection("journals")
            .get();

    // Load the journal entries from the sub collection under the patient.
    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data()! as Map<String, dynamic>;
      entries.add(
        JournalEntry(
          docSnapshot.id,
          data["title"] ?? "Journal Entry",
          ((data["entryDateTime"] ?? Timestamp.now()) as Timestamp).toDate(),
          data["contents"] ?? "",
        ),
      );
    }

    _sortEntries();
  }

  /// Upload a new journal entry to firebase.
  Future<void> addJournalEntry(JournalEntry entry) async {
    entries.add(entry);

    final db = FirebaseFirestore.instance;
    await db
        .collection("patients")
        .doc(_patientId)
        .collection("journals")
        .add(entry.toObject());

    _sortEntries();
    notifyListeners();
  }

  /// Update a journal entry.
  Future<void> updateJournalEntry(String id, JournalEntry entry) async {
    JournalEntry entryToUpdate = entries.firstWhere(
      (element) => element.id == id,
    );
    entryToUpdate.title = entry.title;
    entryToUpdate.contents = entry.contents;

    final db = FirebaseFirestore.instance;
    await db
        .collection("patients")
        .doc(_patientId)
        .collection("journals")
        .doc(id)
        .update(entryToUpdate.toObject());

    notifyListeners();
  }

  /// Delete a journal entry from the database.
  Future<void> deleteJournalEntry(String id) async {
    entries.removeWhere((element) => element.id == id);

    final db = FirebaseFirestore.instance;
    await db
        .collection("patients")
        .doc(_patientId)
        .collection("journals")
        .doc(id)
        .delete();

    notifyListeners();
  }
}

/// Model for a single journal entry.
class JournalEntry {
  String id;
  String title;
  String contents;
  DateTime entryDateTime;

  JournalEntry(this.id, this.title, this.entryDateTime, this.contents);

  Map<String, dynamic> toObject() {
    return {
      "title": title,
      "contents": contents,
      "entryDateTime": Timestamp.fromDate(entryDateTime),
    };
  }

  @override
  String toString() {
    return "$id $title ${entryDateTime.toIso8601String()} $contents";
  }
}
