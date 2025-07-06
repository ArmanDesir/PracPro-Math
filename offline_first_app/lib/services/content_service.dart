import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/content.dart';
import 'package:uuid/uuid.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Pick and upload PDF file
  Future<FilePickerResult?> pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      return result;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  // Upload PDF to Firebase Storage
  Future<String> uploadPDFFile(
    File file,
    String classroomId,
    String fileName,
  ) async {
    try {
      print('Uploading file: \\${file.path}');
      print('File exists: \\${await file.exists()}');
      print('File length: \\${await file.length()}');
      final storageRef = _storage.ref().child(
        'classrooms/$classroomId/content/$fileName',
      );
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Create content with PDF
  Future<Content> createContent({
    required String classroomId,
    required String title,
    required String description,
    required ContentType type,
    required File pdfFile,
  }) async {
    try {
      final fileName = '${_uuid.v4()}_${pdfFile.path.split('/').last}';
      final fileUrl = await uploadPDFFile(pdfFile, classroomId, fileName);

      final content = Content(
        id: _uuid.v4(),
        classroomId: classroomId,
        title: title,
        description: description,
        type: type,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: await pdfFile.length(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('content')
          .doc(content.id)
          .set(content.toJson());
      return content;
    } catch (e) {
      throw Exception('Failed to create content: $e');
    }
  }

  // Get content by classroom
  Future<List<Content>> getContentByClassroom(String classroomId) async {
    try {
      print('Loading content for classroom: $classroomId');
      final query =
          await _firestore
              .collection('content')
              .where('classroomId', isEqualTo: classroomId)
              .orderBy('createdAt', descending: true)
              .get();
      print('Found \\${query.docs.length} content items');
      final contents =
          query.docs.map((doc) {
            print('Content doc: \\${doc.data()}');
            return Content.fromJson(doc.data());
          }).toList();
      return contents;
    } catch (e) {
      print('Error loading content: $e');
      throw Exception('Failed to get content: $e');
    }
  }

  // Delete content
  Future<void> deleteContent(String contentId) async {
    try {
      await _firestore.collection('content').doc(contentId).delete();
    } catch (e) {
      throw Exception('Failed to delete content: $e');
    }
  }
}
