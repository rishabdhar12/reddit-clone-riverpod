import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone_provider/core/constants/constants.dart';
import 'package:reddit_clone_provider/core/constants/firebase_constants.dart';
import 'package:reddit_clone_provider/core/failure.dart';
import 'package:reddit_clone_provider/core/providers/firebase_providers.dart';
import 'package:reddit_clone_provider/core/type_defs.dart';
import 'package:reddit_clone_provider/models/user_model.dart';

// auth repository provider
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firebaseFirestore: ref.read(firestoreProvider),
    firebaseAuth: ref.read(firebaseAuthProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firebaseFirestore,
      required FirebaseAuth firebaseAuth,
      required GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore,
        _googleSignIn = googleSignIn;

  // firestore collection getter
  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.usersCollection);

  // Notifies about changes to the user's sign-in state (such as sign-in or sign-out)
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  // google sign in repository
  FutureEither<UserModel> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // user model
      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        // update user model.
        userModel = UserModel(
            name: userCredential.user?.displayName ?? "John Doe",
            profilePic:
                userCredential.user?.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: []);

        // push user model to firestore
        await _users.doc(userCredential.user!.uid).set(
              userModel.toMap(),
            );
      } else {
        // get the first instance
        userModel = await getUser(userCredential.user!.uid).first;
      }
      // success
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      // failure
      return left(Failure("Google sign in ${e.toString()}"));
    }
  }

  // get user stream
  Stream<UserModel> getUser(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  // sign out
  void signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
