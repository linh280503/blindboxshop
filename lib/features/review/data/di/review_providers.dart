import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/review_remote_datasource.dart';
import '../repositories/review_repository_impl.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/usecases/create_review.dart';
import '../../domain/usecases/get_reviews_by_product.dart';

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSourceImpl();
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dataSource = ref.watch(reviewRemoteDataSourceProvider);
  return ReviewRepositoryImpl(remoteDataSource: dataSource);
});

final createReviewProvider = Provider<CreateReview>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return CreateReview(repository);
});

final getReviewsByProductProvider = Provider<GetReviewsByProduct>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetReviewsByProduct(repository);
});
