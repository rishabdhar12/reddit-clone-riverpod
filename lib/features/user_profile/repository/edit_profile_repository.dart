import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_provider/core/constants/firebase_constants.dart';
import 'package:reddit_clone_provider/core/failure.dart';
import 'package:reddit_clone_provider/core/providers/firebase_providers.dart';
import 'package:reddit_clone_provider/core/type_defs.dart';
import 'package:reddit_clone_provider/models/user_model.dart';

// user repository provider
final editProfileRepositoryProvider = Provider((ref) {
  return EditProfileRepository(
    firebaseFirestore: ref.watch(firestoreProvider),
  );
});

class EditProfileRepository {
  final FirebaseFirestore _firebaseFirestore;

  EditProfileRepository({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

// edit user profile
  FutureVoid editProfile({required UserModel userModel}) async {
    try {
      return right(_users.doc(userModel.uid).update(userModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
