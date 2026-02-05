/// Localization configuration for WishKit.
class WishKitLocalization {
  // Status labels
  String requested;
  String pending;
  String inReview;
  String planned;
  String inProgress;
  String completed;
  String approved;
  String implemented;
  String rejected;

  // Tab labels
  String all;
  String tabRequested;
  String tabPending;
  String tabApproved;
  String tabInReview;
  String tabPlanned;
  String tabInProgress;
  String tabCompleted;
  String tabImplemented;
  String tabRejected;

  // Buttons
  String save;
  String done;
  String confirm;
  String cancel;
  String discard;
  String close;

  // Create wish
  String featureRequest;
  String title;
  String titlePlaceholder;
  String description;
  String descriptionPlaceholder;
  String email;
  String emailPlaceholder;
  String submit;

  // Detail view
  String voteButton;
  String removeVoteButton;
  String comments;
  String addComment;
  String commentPlaceholder;
  String noComments;

  // List view
  String noWishes;
  String loading;
  String errorLoading;
  String retry;

  // Alerts
  String successTitle;
  String errorTitle;
  String wishCreatedMessage;
  String alreadyVotedMessage;
  String voteErrorMessage;
  String commentErrorMessage;

  // Confirmation
  String unsavedChangesTitle;
  String unsavedChangesMessage;

  WishKitLocalization({
    this.requested = 'Requested',
    this.pending = 'Pending',
    this.inReview = 'In Review',
    this.planned = 'Planned',
    this.inProgress = 'In Progress',
    this.completed = 'Completed',
    this.approved = 'Approved',
    this.implemented = 'Implemented',
    this.rejected = 'Rejected',
    this.all = 'All',
    this.tabRequested = 'Requested',
    this.tabPending = 'Pending',
    this.tabApproved = 'Approved',
    this.tabInReview = 'In Review',
    this.tabPlanned = 'Planned',
    this.tabInProgress = 'In Progress',
    this.tabCompleted = 'Completed',
    this.tabImplemented = 'Implemented',
    this.tabRejected = 'Rejected',
    this.save = 'Save',
    this.done = 'Done',
    this.confirm = 'Confirm',
    this.cancel = 'Cancel',
    this.discard = 'Discard',
    this.close = 'Close',
    this.featureRequest = 'Feature Request',
    this.title = 'Title',
    this.titlePlaceholder = 'Short and descriptive title',
    this.description = 'Description',
    this.descriptionPlaceholder = 'Describe the feature you would like to see...',
    this.email = 'Email',
    this.emailPlaceholder = 'your@email.com',
    this.submit = 'Submit',
    this.voteButton = 'Vote',
    this.removeVoteButton = 'Remove Vote',
    this.comments = 'Comments',
    this.addComment = 'Add Comment',
    this.commentPlaceholder = 'Write a comment...',
    this.noComments = 'No comments yet',
    this.noWishes = 'No feature requests yet',
    this.loading = 'Loading...',
    this.errorLoading = 'Failed to load',
    this.retry = 'Retry',
    this.successTitle = 'Success',
    this.errorTitle = 'Error',
    this.wishCreatedMessage = 'Your feature request has been submitted!',
    this.alreadyVotedMessage = 'You have already voted for this feature.',
    this.voteErrorMessage = 'Failed to submit vote. Please try again.',
    this.commentErrorMessage = 'Failed to submit comment. Please try again.',
    this.unsavedChangesTitle = 'Unsaved Changes',
    this.unsavedChangesMessage = 'You have unsaved changes. Do you want to discard them?',
  });

  /// Creates a copy with modified values.
  WishKitLocalization copyWith({
    String? requested,
    String? pending,
    String? inReview,
    String? planned,
    String? inProgress,
    String? completed,
    String? approved,
    String? implemented,
    String? rejected,
    String? all,
    String? tabRequested,
    String? tabPending,
    String? tabApproved,
    String? tabInReview,
    String? tabPlanned,
    String? tabInProgress,
    String? tabCompleted,
    String? tabImplemented,
    String? tabRejected,
    String? save,
    String? done,
    String? confirm,
    String? cancel,
    String? discard,
    String? close,
    String? featureRequest,
    String? title,
    String? titlePlaceholder,
    String? description,
    String? descriptionPlaceholder,
    String? email,
    String? emailPlaceholder,
    String? submit,
    String? voteButton,
    String? removeVoteButton,
    String? comments,
    String? addComment,
    String? commentPlaceholder,
    String? noComments,
    String? noWishes,
    String? loading,
    String? errorLoading,
    String? retry,
    String? successTitle,
    String? errorTitle,
    String? wishCreatedMessage,
    String? alreadyVotedMessage,
    String? voteErrorMessage,
    String? commentErrorMessage,
    String? unsavedChangesTitle,
    String? unsavedChangesMessage,
  }) {
    return WishKitLocalization(
      requested: requested ?? this.requested,
      pending: pending ?? this.pending,
      inReview: inReview ?? this.inReview,
      planned: planned ?? this.planned,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      approved: approved ?? this.approved,
      implemented: implemented ?? this.implemented,
      rejected: rejected ?? this.rejected,
      all: all ?? this.all,
      tabRequested: tabRequested ?? this.tabRequested,
      tabPending: tabPending ?? this.tabPending,
      tabApproved: tabApproved ?? this.tabApproved,
      tabInReview: tabInReview ?? this.tabInReview,
      tabPlanned: tabPlanned ?? this.tabPlanned,
      tabInProgress: tabInProgress ?? this.tabInProgress,
      tabCompleted: tabCompleted ?? this.tabCompleted,
      tabImplemented: tabImplemented ?? this.tabImplemented,
      tabRejected: tabRejected ?? this.tabRejected,
      save: save ?? this.save,
      done: done ?? this.done,
      confirm: confirm ?? this.confirm,
      cancel: cancel ?? this.cancel,
      discard: discard ?? this.discard,
      close: close ?? this.close,
      featureRequest: featureRequest ?? this.featureRequest,
      title: title ?? this.title,
      titlePlaceholder: titlePlaceholder ?? this.titlePlaceholder,
      description: description ?? this.description,
      descriptionPlaceholder: descriptionPlaceholder ?? this.descriptionPlaceholder,
      email: email ?? this.email,
      emailPlaceholder: emailPlaceholder ?? this.emailPlaceholder,
      submit: submit ?? this.submit,
      voteButton: voteButton ?? this.voteButton,
      removeVoteButton: removeVoteButton ?? this.removeVoteButton,
      comments: comments ?? this.comments,
      addComment: addComment ?? this.addComment,
      commentPlaceholder: commentPlaceholder ?? this.commentPlaceholder,
      noComments: noComments ?? this.noComments,
      noWishes: noWishes ?? this.noWishes,
      loading: loading ?? this.loading,
      errorLoading: errorLoading ?? this.errorLoading,
      retry: retry ?? this.retry,
      successTitle: successTitle ?? this.successTitle,
      errorTitle: errorTitle ?? this.errorTitle,
      wishCreatedMessage: wishCreatedMessage ?? this.wishCreatedMessage,
      alreadyVotedMessage: alreadyVotedMessage ?? this.alreadyVotedMessage,
      voteErrorMessage: voteErrorMessage ?? this.voteErrorMessage,
      commentErrorMessage: commentErrorMessage ?? this.commentErrorMessage,
      unsavedChangesTitle: unsavedChangesTitle ?? this.unsavedChangesTitle,
      unsavedChangesMessage: unsavedChangesMessage ?? this.unsavedChangesMessage,
    );
  }
}
