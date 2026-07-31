import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financo/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';

/// Base for a Firestore-backed, `userId`-scoped CRUD datasource.
///
/// Thirteen datasources in this project repeat the same four methods with the
/// same `try { … } on Exception { throw ServerException(…) }` shell, differing
/// only in the collection name, the model's `fromFirestore`/`toJson`, and the
/// wording of the error message. `TODO.md` deferred extracting this twice
/// (2026-05-28, 2026-06-12) on the grounds that per-collection differences made
/// the abstraction low-value, with an explicit "revisit if an 8th appears"
/// trigger — which has since fired.
///
/// Subclasses supply the three things that genuinely vary and keep their own
/// domain-named public methods, so call sites and their interfaces are
/// unchanged. Anything a collection needs beyond plain CRUD (compound queries,
/// batched writes, transactions) is written normally in the subclass; this base
/// deliberately does not try to cover those.
///
/// Example:
/// ```dart
/// class InstitutionRemoteDataSourceImpl
///     extends FirestoreCrudDataSource<InstitutionModel>
///     implements InstitutionRemoteDataSource {
///   InstitutionRemoteDataSourceImpl({required super.firestore});
///
///   @override
///   String get collectionName => 'institutions';
///   @override
///   String get entityLabel => 'institution';
///   @override
///   InstitutionModel fromFirestore(DocumentSnapshot doc) =>
///       InstitutionModel.fromFirestore(doc);
///   @override
///   Map<String, dynamic> toJson(InstitutionModel model) => model.toJson();
///
///   @override
///   Future<List<InstitutionModel>> getInstitutions({
///     required String userId,
///   }) => fetchAllForUser(userId);
/// }
/// ```
abstract class FirestoreCrudDataSource<T> {
  const FirestoreCrudDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Top-level Firestore collection this datasource owns.
  String get collectionName;

  /// Singular, lower-case noun used in error messages ("institution" →
  /// "Failed to fetch institutions."). Keeps the strings identical to the
  /// hand-written ones they replaced.
  String get entityLabel;

  /// Plural form, when it is not just `entityLabel + 's'`.
  String get entityLabelPlural => '${entityLabel}s';

  /// Deserialises one document.
  T fromFirestore(DocumentSnapshot<Object?> doc);

  /// Serialises a model for a create/update write.
  Map<String, dynamic> toJson(T model);

  /// The document id of [model], needed by [update].
  String idOf(T model);

  @protected
  CollectionReference<Object?> get collection =>
      _firestore.collection(collectionName);

  /// Every document owned by [userId].
  Future<List<T>> fetchAllForUser(String userId) async {
    try {
      final snapshot = await collection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map(fromFirestore).toList();
    } on Exception {
      throw ServerException('Failed to fetch $entityLabelPlural.');
    }
  }

  /// Adds [model] and returns it re-read, so the caller gets the assigned id.
  Future<T> create(T model) async {
    try {
      final docRef = await collection.add(toJson(model));
      final doc = await docRef.get();
      return fromFirestore(doc);
    } on Exception {
      throw ServerException('Failed to create $entityLabel.');
    }
  }

  /// Overwrites [model]'s document and returns it re-read.
  Future<T> update(T model) async {
    try {
      final docRef = collection.doc(idOf(model));
      await docRef.update(toJson(model));
      final doc = await docRef.get();
      return fromFirestore(doc);
    } on Exception {
      throw ServerException('Failed to update $entityLabel.');
    }
  }

  /// Removes the document with [id].
  Future<void> deleteById(String id) async {
    try {
      await collection.doc(id).delete();
    } on Exception {
      throw ServerException('Failed to delete $entityLabel.');
    }
  }
}
