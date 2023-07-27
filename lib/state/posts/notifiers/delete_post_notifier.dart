import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone/state/constants/firebase_field_name.dart';
import 'package:instagram_clone/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:instagram_clone/state/image_upload/typedefs/is_loading.dart';
import 'package:instagram_clone/state/posts/models/post.dart';
import 'package:instagram_clone/state/posts/typedefs/post_id.dart';

class DeletePostStateNotfier extends StateNotifier<IsLoading> {
  DeletePostStateNotfier() : super(false);
  set isLoading(bool value) => state = value;

  Future<bool> deletePost({required Post post}) async {
    isLoading = true;

    // delete the post's thumbnail

    try {
      await FirebaseStorage.instance
          .ref()
          .child(post.userId)
          .child(FirebaseCollectionName.thumbnails)
          .child(post.thumbnailStorageId)
          .delete();

      // deelte the post's orginal file (video or image)

      await FirebaseStorage.instance
          .ref()
          .child(post.userId)
          .child(post.fileType.collectionName)
          .child(post.originalFileStorageId)
          .delete();

      // delete all comments associated with this post
      await _deleteAllDocuments(
        postId: post.postId,
        inCollection: FirebaseCollectionName.comments,
      );

      // delete all likes associated with this post
      await _deleteAllDocuments(
        postId: post.postId,
        inCollection: FirebaseCollectionName.likes,
      );

      // delete the post itself
      final postInCollection = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .where(
            FirebaseFieldName.postId,
            isEqualTo: post.postId,
          )
          .limit(1)
          .get();

      for (final post in postInCollection.docs) {
        await post.reference.delete();
      }

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> _deleteAllDocuments(
      {required PostId postId, required String inCollection}) {
    return FirebaseFirestore.instance.runTransaction(
      maxAttempts: 3,
      timeout: const Duration(seconds: 20),
      (transation) async {
        final query = await FirebaseFirestore.instance
            .collection(inCollection)
            .where(FirebaseFieldName.postId, isEqualTo: postId)
            .get();
        for (var doc in query.docs) {
          transation.delete(
            doc.reference,
          );
        }
      },
    );
  }
}
