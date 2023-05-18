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
}
