import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // 이미지 업로드 (파일)
  Future<String> uploadImageFile({
    required File file,
    required String path,
    String? fileName,
  }) async {
    try {
      String finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String fullPath = '$path/$finalFileName';
      
      Reference ref = _storage.ref().child(fullPath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      rethrow;
    }
  }

  // 이미지 업로드 (바이트 데이터)
  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String path,
    String? fileName,
  }) async {
    try {
      String finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String fullPath = '$path/$finalFileName';
      
      Reference ref = _storage.ref().child(fullPath);
      UploadTask uploadTask = ref.putData(bytes);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      rethrow;
    }
  }

  // 갤러리에서 이미지 선택
  Future<File?> pickImageFromGallery() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('갤러리에서 이미지 선택 실패: $e');
      rethrow;
    }
  }

  // 카메라로 이미지 촬영
  Future<File?> pickImageFromCamera() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('카메라로 이미지 촬영 실패: $e');
      rethrow;
    }
  }

  // 프로필 이미지 업로드
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await uploadImageFile(
      file: imageFile,
      path: AppConstants.profileImagesPath,
      fileName: 'profile_$userId.jpg',
    );
  }

  // 마사지샵 이미지 업로드
  Future<String> uploadShopImage(File imageFile, String shopId, {String? imageName}) async {
    return await uploadImageFile(
      file: imageFile,
      path: AppConstants.shopImagesPath,
      fileName: imageName ?? 'shop_${shopId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // 리뷰 이미지 업로드
  Future<String> uploadReviewImage(File imageFile, String reviewId, {String? imageName}) async {
    return await uploadImageFile(
      file: imageFile,
      path: AppConstants.reviewImagesPath,
      fileName: imageName ?? 'review_${reviewId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // 파일 삭제
  Future<void> deleteFile(String downloadUrl) async {
    try {
      Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      print('파일 삭제 실패: $e');
      rethrow;
    }
  }

  // 파일 존재 여부 확인
  Future<bool> fileExists(String downloadUrl) async {
    try {
      Reference ref = _storage.refFromURL(downloadUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 파일 메타데이터 가져오기
  Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      Reference ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('파일 메타데이터 가져오기 실패: $e');
      return null;
    }
  }
} 