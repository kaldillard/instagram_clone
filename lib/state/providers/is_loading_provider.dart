import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone/state/image_upload/typedefs/is_loading.dart';

final isLoadingProvider = Provider<IsLoading>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.isLoading;
});
