import 'package:dio/dio.dart';
import '../../core/models/assignment.dart';
import 'dart:typed_data';

abstract class AssignmentsRepository {
  Future<List<Assignment>> fetchStudentAssignments();
  Future<void> submitAssignment(
    String assignmentId, {
    String? note,
    List<MultipartFile> files,
    Uint8List? fileBytes,
    String? filename,
  });
}
