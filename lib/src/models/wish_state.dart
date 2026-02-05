/// Represents the state of a wish/feature request.
enum WishState {
  pending,
  inReview,
  approved,
  planned,
  inProgress,
  completed,
  implemented,
  rejected;

  /// Creates a WishState from a string value.
  static WishState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return WishState.pending;
      case 'inreview':
      case 'in_review':
        return WishState.inReview;
      case 'approved':
        return WishState.approved;
      case 'planned':
        return WishState.planned;
      case 'inprogress':
      case 'in_progress':
        return WishState.inProgress;
      case 'completed':
        return WishState.completed;
      case 'implemented':
        return WishState.implemented;
      case 'rejected':
        return WishState.rejected;
      default:
        return WishState.pending;
    }
  }

  /// Converts the state to a string for API requests.
  String toApiString() {
    switch (this) {
      case WishState.pending:
        return 'pending';
      case WishState.inReview:
        return 'inReview';
      case WishState.approved:
        return 'approved';
      case WishState.planned:
        return 'planned';
      case WishState.inProgress:
        return 'inProgress';
      case WishState.completed:
        return 'completed';
      case WishState.implemented:
        return 'implemented';
      case WishState.rejected:
        return 'rejected';
    }
  }

  /// Returns a human-readable display name.
  String get displayName {
    switch (this) {
      case WishState.pending:
        return 'Pending';
      case WishState.inReview:
        return 'In Review';
      case WishState.approved:
        return 'Approved';
      case WishState.planned:
        return 'Planned';
      case WishState.inProgress:
        return 'In Progress';
      case WishState.completed:
        return 'Completed';
      case WishState.implemented:
        return 'Implemented';
      case WishState.rejected:
        return 'Rejected';
    }
  }
}
