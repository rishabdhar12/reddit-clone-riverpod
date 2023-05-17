import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_provider/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
