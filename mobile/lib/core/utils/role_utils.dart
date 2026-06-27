import '../../shared/models/user_model.dart';

String roleDisplayName(UserRole role) {
  switch (role) {
    case UserRole.learner:
      return 'Learner';
    case UserRole.teacher:
      return 'Teacher / Freelancer';
    case UserRole.client:
      return 'Client';
    case UserRole.admin:
      return 'Admin';
  }
}
