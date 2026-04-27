class ApiEndpoints {
  static const assignments = '/assignments';
  static const submissions = '/submissions';
  static String submissionsByAssignment(String assignmentId) =>
      '/submissions?assignment_id=eq.$assignmentId&select=*,student:user_id(full_name)';
  static const resources = '/resources';
  static const groups = '/groups';
  static const groupMembers = '/group_members';
  static const authLogin = '/token?grant_type=password';
  static const notifications = '/notifications';
  static const sessions = '/sessions';
  static const attendance = '/attendance';
}
