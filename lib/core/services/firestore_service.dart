import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _firestore;

  // Generic CRUD operations
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection({
    required String collection,
  }) async {
    return await _firestore.collection(collection).get();
  }

  Future<QuerySnapshot> getCollectionWhere({
    required String collection,
    required String field,
    required dynamic value,
  }) async {
    return await _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();
  }

  Stream<QuerySnapshot> streamCollection({
    required String collection,
  }) {
    return _firestore.collection(collection).snapshots();
  }

  Stream<QuerySnapshot> streamCollectionWhere({
    required String collection,
    required String field,
    required dynamic value,
  }) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .snapshots();
  }
}
