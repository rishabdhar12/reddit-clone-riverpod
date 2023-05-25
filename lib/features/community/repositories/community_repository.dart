import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_provider/core/constants/firebase_constants.dart';
import 'package:reddit_clone_provider/core/failure.dart';
import 'package:reddit_clone_provider/core/providers/firebase_providers.dart';
import 'package:reddit_clone_provider/core/type_defs.dart';
import 'package:reddit_clone_provider/models/community_model.dart';

// community repository provider
final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  );
});

class CommunityRepository {
  final FirebaseFirestore _firebaseFirestore;

  CommunityRepository({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;

  // create community
  FutureVoid createCommunity(Community community) async {
    try {
      // check if community exists
      var communityDoc = await _communitiesCollection.doc(community.name).get();
      if (communityDoc.exists) {
        throw "Community already exists";
      }

      // set community to firestore
      return right(
        _communitiesCollection.doc(community.name).set(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // community collection getter
  CollectionReference get _communitiesCollection =>
      _firebaseFirestore.collection(FirebaseConstants.communitiesCollection);

  // get users communities repository
  Stream<List<Community>> getUserCommunities(String uid) {
    return _communitiesCollection
        .where("members", arrayContains: uid)
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(
          Community.fromMap(doc.data() as Map<String, dynamic>),
        );
      }
      return communities;
    });
  }

  // get community by name
  Stream<Community> getCommunityByName({required String name}) {
    try {
      return _communitiesCollection.doc(name).snapshots().map(
          (event) => Community.fromMap(event.data() as Map<String, dynamic>));
    } catch (e) {
      rethrow;
    }
  }

  // edit community
  FutureVoid editCommunity({required Community community}) async {
    try {
      return right(
          _communitiesCollection.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // get streamed list of communities
  Stream<List<Community>> searchCommunities({required String query}) {
    return _communitiesCollection
        .where(
          "name",
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map((event) {
      List<Community> communities = [];
      for (var community in event.docs) {
        communities
            .add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  // join community
  FutureVoid joinCommunity(
      {required String communityName, required String uid}) async {
    try {
      return right(
        _communitiesCollection.doc(communityName).update({
          'members': FieldValue.arrayUnion([uid]),
        }),
      );
    } on FirebaseException {
      rethrow;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // leave community
  FutureVoid leaveCommunity(
      {required String communityName, required String uid}) async {
    try {
      return right(
        _communitiesCollection.doc(communityName).update({
          'members': FieldValue.arrayRemove([uid]),
        }),
      );
    } on FirebaseException {
      rethrow;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
