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

  // Validation
  String titleRequired;
  String descriptionRequired;
  String emailRequiredValidation;
  String emailInvalid;

  // Detail view
  String voteButton;
  String removeVoteButton;
  String comments;
  String addComment;
  String commentPlaceholder;
  String noComments;

  // Comment labels
  String admin;
  String user;

  // Time formatting (use %d as placeholder for the number)
  String timeYearsAgo;
  String timeMonthsAgo;
  String timeDaysAgo;
  String timeHoursAgo;
  String timeMinutesAgo;
  String timeJustNow;

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
    this.titleRequired = 'Title is required',
    this.descriptionRequired = 'Description is required',
    this.emailRequiredValidation = 'Email is required',
    this.emailInvalid = 'Please enter a valid email',
    this.voteButton = 'Vote',
    this.removeVoteButton = 'Remove Vote',
    this.comments = 'Comments',
    this.addComment = 'Add Comment',
    this.commentPlaceholder = 'Write a comment...',
    this.noComments = 'No comments yet',
    this.admin = 'Admin',
    this.user = 'User',
    this.timeYearsAgo = '%dy ago',
    this.timeMonthsAgo = '%dmo ago',
    this.timeDaysAgo = '%dd ago',
    this.timeHoursAgo = '%dh ago',
    this.timeMinutesAgo = '%dm ago',
    this.timeJustNow = 'Just now',
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

  /// English localization (same as default).
  factory WishKitLocalization.en() => WishKitLocalization();

  /// German localization.
  factory WishKitLocalization.de() => WishKitLocalization(
        requested: 'Angefragt',
        pending: 'Ausstehend',
        inReview: 'In Prüfung',
        planned: 'Geplant',
        inProgress: 'In Bearbeitung',
        completed: 'Abgeschlossen',
        approved: 'Genehmigt',
        implemented: 'Umgesetzt',
        rejected: 'Abgelehnt',
        all: 'Alle',
        tabRequested: 'Angefragt',
        tabPending: 'Ausstehend',
        tabApproved: 'Genehmigt',
        tabInReview: 'In Prüfung',
        tabPlanned: 'Geplant',
        tabInProgress: 'In Bearbeitung',
        tabCompleted: 'Abgeschlossen',
        tabImplemented: 'Umgesetzt',
        tabRejected: 'Abgelehnt',
        save: 'Speichern',
        done: 'Fertig',
        confirm: 'Bestätigen',
        cancel: 'Abbrechen',
        discard: 'Verwerfen',
        close: 'Schließen',
        featureRequest: 'Feature-Wunsch',
        title: 'Titel',
        titlePlaceholder: 'Kurzer und beschreibender Titel',
        description: 'Beschreibung',
        descriptionPlaceholder: 'Beschreibe das Feature, das du dir wünschst...',
        email: 'E-Mail',
        emailPlaceholder: 'deine@email.de',
        submit: 'Absenden',
        titleRequired: 'Titel ist erforderlich',
        descriptionRequired: 'Beschreibung ist erforderlich',
        emailRequiredValidation: 'E-Mail ist erforderlich',
        emailInvalid: 'Bitte gib eine gültige E-Mail-Adresse ein',
        voteButton: 'Abstimmen',
        removeVoteButton: 'Stimme zurücknehmen',
        comments: 'Kommentare',
        addComment: 'Kommentar hinzufügen',
        commentPlaceholder: 'Schreibe einen Kommentar...',
        noComments: 'Noch keine Kommentare',
        admin: 'Admin',
        user: 'Nutzer',
        timeYearsAgo: 'vor %d J.',
        timeMonthsAgo: 'vor %d Mon.',
        timeDaysAgo: 'vor %d T.',
        timeHoursAgo: 'vor %d Std.',
        timeMinutesAgo: 'vor %d Min.',
        timeJustNow: 'Gerade eben',
        noWishes: 'Noch keine Feature-Wünsche',
        loading: 'Laden...',
        errorLoading: 'Fehler beim Laden',
        retry: 'Erneut versuchen',
        successTitle: 'Erfolg',
        errorTitle: 'Fehler',
        wishCreatedMessage: 'Dein Feature-Wunsch wurde eingereicht!',
        alreadyVotedMessage: 'Du hast bereits für dieses Feature abgestimmt.',
        voteErrorMessage: 'Abstimmung fehlgeschlagen. Bitte versuche es erneut.',
        commentErrorMessage: 'Kommentar konnte nicht gesendet werden. Bitte versuche es erneut.',
        unsavedChangesTitle: 'Ungespeicherte Änderungen',
        unsavedChangesMessage: 'Du hast ungespeicherte Änderungen. Möchtest du sie verwerfen?',
      );

  /// Helper to format a time-ago string with a number.
  String formatTimeAgo(String template, int value) {
    return template.replaceFirst('%d', value.toString());
  }

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
    String? titleRequired,
    String? descriptionRequired,
    String? emailRequiredValidation,
    String? emailInvalid,
    String? voteButton,
    String? removeVoteButton,
    String? comments,
    String? addComment,
    String? commentPlaceholder,
    String? noComments,
    String? admin,
    String? user,
    String? timeYearsAgo,
    String? timeMonthsAgo,
    String? timeDaysAgo,
    String? timeHoursAgo,
    String? timeMinutesAgo,
    String? timeJustNow,
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
      titleRequired: titleRequired ?? this.titleRequired,
      descriptionRequired: descriptionRequired ?? this.descriptionRequired,
      emailRequiredValidation: emailRequiredValidation ?? this.emailRequiredValidation,
      emailInvalid: emailInvalid ?? this.emailInvalid,
      voteButton: voteButton ?? this.voteButton,
      removeVoteButton: removeVoteButton ?? this.removeVoteButton,
      comments: comments ?? this.comments,
      addComment: addComment ?? this.addComment,
      commentPlaceholder: commentPlaceholder ?? this.commentPlaceholder,
      noComments: noComments ?? this.noComments,
      admin: admin ?? this.admin,
      user: user ?? this.user,
      timeYearsAgo: timeYearsAgo ?? this.timeYearsAgo,
      timeMonthsAgo: timeMonthsAgo ?? this.timeMonthsAgo,
      timeDaysAgo: timeDaysAgo ?? this.timeDaysAgo,
      timeHoursAgo: timeHoursAgo ?? this.timeHoursAgo,
      timeMinutesAgo: timeMinutesAgo ?? this.timeMinutesAgo,
      timeJustNow: timeJustNow ?? this.timeJustNow,
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
