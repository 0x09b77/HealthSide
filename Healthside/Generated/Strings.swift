// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Add {
    /// Back
    public static let back = L10n.tr("Localizable", "add.back", fallback: "Back")
    /// Snap a photo, scan, or pick a file.
    public static let subtitle = L10n.tr("Localizable", "add.subtitle", fallback: "Snap a photo, scan, or pick a file.")
    /// Add analysis
    public static let title = L10n.tr("Localizable", "add.title", fallback: "Add analysis")
    public enum Error {
      /// Couldn't build a document from that scan.
      public static let scanFailed = L10n.tr("Localizable", "add.error.scan_failed", fallback: "Couldn't build a document from that scan.")
    }
    public enum Review {
      /// Label (optional)
      public static let labelField = L10n.tr("Localizable", "add.review.label_field", fallback: "Label (optional)")
      /// Lipid panel — Jun 25
      public static let labelPlaceholder = L10n.tr("Localizable", "add.review.label_placeholder", fallback: "Lipid panel — Jun 25")
      /// Review & upload
      public static let title = L10n.tr("Localizable", "add.review.title", fallback: "Review & upload")
      /// Upload
      public static let upload = L10n.tr("Localizable", "add.review.upload", fallback: "Upload")
    }
    public enum Source {
      public enum Camera {
        /// Scan a document
        public static let subtitle = L10n.tr("Localizable", "add.source.camera.subtitle", fallback: "Scan a document")
        /// Camera
        public static let title = L10n.tr("Localizable", "add.source.camera.title", fallback: "Camera")
      }
      public enum Files {
        /// PDF from Files
        public static let subtitle = L10n.tr("Localizable", "add.source.files.subtitle", fallback: "PDF from Files")
        /// Files
        public static let title = L10n.tr("Localizable", "add.source.files.title", fallback: "Files")
      }
      public enum PhotoLibrary {
        /// Pick from photos
        public static let subtitle = L10n.tr("Localizable", "add.source.photo_library.subtitle", fallback: "Pick from photos")
        /// Photo library
        public static let title = L10n.tr("Localizable", "add.source.photo_library.title", fallback: "Photo library")
      }
    }
    public enum Uploaded {
      /// We're reading it now. You can leave — we'll ping you the moment it's ready.
      public static let body = L10n.tr("Localizable", "add.uploaded.body", fallback: "We're reading it now. You can leave — we'll ping you the moment it's ready.")
      /// Done
      public static let done = L10n.tr("Localizable", "add.uploaded.done", fallback: "Done")
      /// Added
      public static let title = L10n.tr("Localizable", "add.uploaded.title", fallback: "Added")
    }
  }
  public enum Auth {
    /// Forgot password?
    public static let forgotPassword = L10n.tr("Localizable", "auth.forgot_password", fallback: "Forgot password?")
    /// By continuing you agree to our Terms and Privacy.
    public static let termsNotice = L10n.tr("Localizable", "auth.terms_notice", fallback: "By continuing you agree to our Terms and Privacy.")
    public enum Email {
      /// Email
      public static let label = L10n.tr("Localizable", "auth.email.label", fallback: "Email")
      /// you@email.com
      public static let placeholder = L10n.tr("Localizable", "auth.email.placeholder", fallback: "you@email.com")
    }
    public enum Error {
      /// Email already registered
      public static let emailTaken = L10n.tr("Localizable", "auth.error.email_taken", fallback: "Email already registered")
      /// Enter a valid email
      public static let invalidEmail = L10n.tr("Localizable", "auth.error.invalid_email", fallback: "Enter a valid email")
      /// Enter your password
      public static let passwordRequired = L10n.tr("Localizable", "auth.error.password_required", fallback: "Enter your password")
      /// Password must be at least 8 characters
      public static let passwordTooShort = L10n.tr("Localizable", "auth.error.password_too_short", fallback: "Password must be at least 8 characters")
      /// Wrong email or password
      public static let wrongCredentials = L10n.tr("Localizable", "auth.error.wrong_credentials", fallback: "Wrong email or password")
    }
    public enum Footer {
      /// Create account
      public static let createAccount = L10n.tr("Localizable", "auth.footer.create_account", fallback: "Create account")
      /// Log in
      public static let logIn = L10n.tr("Localizable", "auth.footer.log_in", fallback: "Log in")
      /// New here?
      public static let loginPrompt = L10n.tr("Localizable", "auth.footer.login_prompt", fallback: "New here?")
      /// Have an account?
      public static let registerPrompt = L10n.tr("Localizable", "auth.footer.register_prompt", fallback: "Have an account?")
    }
    public enum Password {
      /// Password
      public static let label = L10n.tr("Localizable", "auth.password.label", fallback: "Password")
      /// Password
      public static let placeholder = L10n.tr("Localizable", "auth.password.placeholder", fallback: "Password")
    }
    public enum Submit {
      /// Log in
      public static let login = L10n.tr("Localizable", "auth.submit.login", fallback: "Log in")
      /// Create account
      public static let register = L10n.tr("Localizable", "auth.submit.register", fallback: "Create account")
    }
    public enum Subtitle {
      /// Log in to your Healthside account.
      public static let login = L10n.tr("Localizable", "auth.subtitle.login", fallback: "Log in to your Healthside account.")
      /// Free. Takes a minute.
      public static let register = L10n.tr("Localizable", "auth.subtitle.register", fallback: "Free. Takes a minute.")
    }
    public enum Title {
      /// Welcome back
      public static let login = L10n.tr("Localizable", "auth.title.login", fallback: "Welcome back")
      /// Create your account
      public static let register = L10n.tr("Localizable", "auth.title.register", fallback: "Create your account")
    }
  }
  public enum Biomarker {
    /// Normal range
    public static let normalRangeLegend = L10n.tr("Localizable", "biomarker.normal_range_legend", fallback: "Normal range")
    /// SOURCES
    public static let sourcesTitle = L10n.tr("Localizable", "biomarker.sources_title", fallback: "SOURCES")
    public enum Trend {
      /// Trending down since %@ (was %@).
      public static func down(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "biomarker.trend.down", String(describing: p1), String(describing: p2), fallback: "Trending down since %@ (was %@).")
      }
      /// Latest reading from %@.
      public static func latest(_ p1: Any) -> String {
        return L10n.tr("Localizable", "biomarker.trend.latest", String(describing: p1), fallback: "Latest reading from %@.")
      }
      /// Only one measurement so far — add more results to see a trend.
      public static let singleMeasurement = L10n.tr("Localizable", "biomarker.trend.single_measurement", fallback: "Only one measurement so far — add more results to see a trend.")
      /// Steady since %@.
      public static func stable(_ p1: Any) -> String {
        return L10n.tr("Localizable", "biomarker.trend.stable", String(describing: p1), fallback: "Steady since %@.")
      }
      /// Trending up since %@ (was %@).
      public static func up(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "biomarker.trend.up", String(describing: p1), String(describing: p2), fallback: "Trending up since %@ (was %@).")
      }
    }
  }
  public enum Document {
    /// Delete record
    public static let deleteButton = L10n.tr("Localizable", "document.delete_button", fallback: "Delete record")
    /// DIAGNOSIS
    public static let diagnosisLabel = L10n.tr("Localizable", "document.diagnosis_label", fallback: "DIAGNOSIS")
    /// RESULTS
    public static let resultsLabel = L10n.tr("Localizable", "document.results_label", fallback: "RESULTS")
    /// SUMMARY
    public static let summaryLabel = L10n.tr("Localizable", "document.summary_label", fallback: "SUMMARY")
    public enum Alert {
      /// Delete
      public static let confirm = L10n.tr("Localizable", "document.alert.confirm", fallback: "Delete")
      /// This permanently removes your analysis and its data. This can't be undone.
      public static let message = L10n.tr("Localizable", "document.alert.message", fallback: "This permanently removes your analysis and its data. This can't be undone.")
      /// Delete this record?
      public static let title = L10n.tr("Localizable", "document.alert.title", fallback: "Delete this record?")
    }
    public enum Failed {
      /// We couldn't read this file clearly. Your original is saved.
      public static let body = L10n.tr("Localizable", "document.failed.body", fallback: "We couldn't read this file clearly. Your original is saved.")
      /// Couldn't read this one
      public static let title = L10n.tr("Localizable", "document.failed.title", fallback: "Couldn't read this one")
    }
  }
  public enum Errors {
    /// Conflict.
    public static let conflict = L10n.tr("Localizable", "errors.conflict", fallback: "Conflict.")
    /// Unexpected response format.
    public static let decoding = L10n.tr("Localizable", "errors.decoding", fallback: "Unexpected response format.")
    /// This file is too large. The limit is 20 MB.
    public static let fileTooLarge = L10n.tr("Localizable", "errors.file_too_large", fallback: "This file is too large. The limit is 20 MB.")
    /// You don't have access to this resource.
    public static let forbidden = L10n.tr("Localizable", "errors.forbidden", fallback: "You don't have access to this resource.")
    /// Not found.
    public static let notFound = L10n.tr("Localizable", "errors.not_found", fallback: "Not found.")
    /// No internet connection.
    public static let offline = L10n.tr("Localizable", "errors.offline", fallback: "No internet connection.")
    /// Server error.
    public static let server = L10n.tr("Localizable", "errors.server", fallback: "Server error.")
    /// Request timed out.
    public static let timeout = L10n.tr("Localizable", "errors.timeout", fallback: "Request timed out.")
    /// Too many requests. Try again later.
    public static let tooManyRequests = L10n.tr("Localizable", "errors.too_many_requests", fallback: "Too many requests. Try again later.")
    /// Session expired. Please sign in again.
    public static let unauthorized = L10n.tr("Localizable", "errors.unauthorized", fallback: "Session expired. Please sign in again.")
    /// Something went wrong.
    public static let unknown = L10n.tr("Localizable", "errors.unknown", fallback: "Something went wrong.")
    /// Unsupported file type. Use a PDF, JPEG, PNG or HEIC.
    public static let unsupportedMediaType = L10n.tr("Localizable", "errors.unsupported_media_type", fallback: "Unsupported file type. Use a PDF, JPEG, PNG or HEIC.")
    /// Validation failed
    public static let validationFailed = L10n.tr("Localizable", "errors.validation_failed", fallback: "Validation failed")
  }
  public enum Home {
    /// Hi 👋
    public static let greeting = L10n.tr("Localizable", "home.greeting", fallback: "Hi 👋")
    /// Latest
    public static let latestBadge = L10n.tr("Localizable", "home.latest_badge", fallback: "Latest")
    /// RECENT RECORDS
    public static let recentRecordsTitle = L10n.tr("Localizable", "home.recent_records_title", fallback: "RECENT RECORDS")
    public enum Empty {
      /// Snap a photo of a lab result and we'll explain it in plain language.
      public static let body = L10n.tr("Localizable", "home.empty.body", fallback: "Snap a photo of a lab result and we'll explain it in plain language.")
      /// Add analysis
      public static let cta = L10n.tr("Localizable", "home.empty.cta", fallback: "Add analysis")
      /// Add your first analysis
      public static let title = L10n.tr("Localizable", "home.empty.title", fallback: "Add your first analysis")
    }
  }
  public enum Insights {
    /// ALL MARKERS
    public static let allMarkers = L10n.tr("Localizable", "insights.all_markers", fallback: "ALL MARKERS")
    /// Insights
    public static let title = L10n.tr("Localizable", "insights.title", fallback: "Insights")
    /// WORTH WATCHING
    public static let worthWatching = L10n.tr("Localizable", "insights.worth_watching", fallback: "WORTH WATCHING")
    public enum Empty {
      /// Add a couple of lab results and your trends will show up here.
      public static let body = L10n.tr("Localizable", "insights.empty.body", fallback: "Add a couple of lab results and your trends will show up here.")
      /// No trends yet
      public static let title = L10n.tr("Localizable", "insights.empty.title", fallback: "No trends yet")
    }
  }
  public enum Lock {
    /// Your health data stays private. Unlock with %@ to continue.
    public static func body(_ p1: Any) -> String {
      return L10n.tr("Localizable", "lock.body", String(describing: p1), fallback: "Your health data stays private. Unlock with %@ to continue.")
    }
    /// Couldn't verify it's you.
    public static let failed = L10n.tr("Localizable", "lock.failed", fallback: "Couldn't verify it's you.")
    /// Healthside is locked
    public static let title = L10n.tr("Localizable", "lock.title", fallback: "Healthside is locked")
    /// Unlock with %@
    public static func unlockButton(_ p1: Any) -> String {
      return L10n.tr("Localizable", "lock.unlock_button", String(describing: p1), fallback: "Unlock with %@")
    }
  }
  public enum Main {
    public enum Tab {
      /// Home
      public static let home = L10n.tr("Localizable", "main.tab.home", fallback: "Home")
    }
  }
  public enum Profile {
    /// Auto-lock
    public static let autoLock = L10n.tr("Localizable", "profile.auto_lock", fallback: "Auto-lock")
    /// After 1 min
    public static let autoLockValue = L10n.tr("Localizable", "profile.auto_lock_value", fallback: "After 1 min")
    /// Change password
    public static let changePassword = L10n.tr("Localizable", "profile.change_password", fallback: "Change password")
    /// Delete everything
    public static let deleteEverything = L10n.tr("Localizable", "profile.delete_everything", fallback: "Delete everything")
    /// Export my data
    public static let exportData = L10n.tr("Localizable", "profile.export_data", fallback: "Export my data")
    /// Member since %@
    public static func memberSince(_ p1: Any) -> String {
      return L10n.tr("Localizable", "profile.member_since", String(describing: p1), fallback: "Member since %@")
    }
    /// PRIVACY & DATA
    public static let privacyData = L10n.tr("Localizable", "profile.privacy_data", fallback: "PRIVACY & DATA")
    /// SECURITY
    public static let security = L10n.tr("Localizable", "profile.security", fallback: "SECURITY")
    /// Profile
    public static let title = L10n.tr("Localizable", "profile.title", fallback: "Profile")
  }
  public enum Records {
    /// Filter
    public static let filterAccessibilityLabel = L10n.tr("Localizable", "records.filter_accessibility_label", fallback: "Filter")
    /// Search
    public static let searchPrompt = L10n.tr("Localizable", "records.search_prompt", fallback: "Search")
    /// Records
    public static let title = L10n.tr("Localizable", "records.title", fallback: "Records")
    public enum Empty {
      /// Add a lab result and it will show up here.
      public static let body = L10n.tr("Localizable", "records.empty.body", fallback: "Add a lab result and it will show up here.")
      /// No records yet
      public static let title = L10n.tr("Localizable", "records.empty.title", fallback: "No records yet")
    }
    public enum EmptyFiltered {
      /// Try a different search or filter.
      public static let body = L10n.tr("Localizable", "records.empty_filtered.body", fallback: "Try a different search or filter.")
      /// Nothing found
      public static let title = L10n.tr("Localizable", "records.empty_filtered.title", fallback: "Nothing found")
    }
    public enum Filter {
      /// All
      public static let all = L10n.tr("Localizable", "records.filter.all", fallback: "All")
      /// Imaging
      public static let imaging = L10n.tr("Localizable", "records.filter.imaging", fallback: "Imaging")
      /// Labs
      public static let labs = L10n.tr("Localizable", "records.filter.labs", fallback: "Labs")
    }
  }
  public enum Setup {
    public enum Consent {
      /// To read your analyses, we process them securely with a trusted provider. Personal details are removed first. You can delete everything anytime.
      public static let body = L10n.tr("Localizable", "setup.consent.body", fallback: "To read your analyses, we process them securely with a trusted provider. Personal details are removed first. You can delete everything anytime.")
      /// I agree to secure cloud processing of my documents.
      public static let checkbox = L10n.tr("Localizable", "setup.consent.checkbox", fallback: "I agree to secure cloud processing of my documents.")
      /// Agree and continue
      public static let cta = L10n.tr("Localizable", "setup.consent.cta", fallback: "Agree and continue")
      /// Before we start
      public static let title = L10n.tr("Localizable", "setup.consent.title", fallback: "Before we start")
    }
    public enum FaceId {
      /// Your health data stays private. We'll ask for %@ each time you open the app.
      public static func body(_ p1: Any) -> String {
        return L10n.tr("Localizable", "setup.face_id.body", String(describing: p1), fallback: "Your health data stays private. We'll ask for %@ each time you open the app.")
      }
      /// Enable %@
      public static func enable(_ p1: Any) -> String {
        return L10n.tr("Localizable", "setup.face_id.enable", String(describing: p1), fallback: "Enable %@")
      }
      /// Set up later
      public static let skip = L10n.tr("Localizable", "setup.face_id.skip", fallback: "Set up later")
      /// Lock with %@
      public static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "setup.face_id.title", String(describing: p1), fallback: "Lock with %@")
      }
    }
    public enum Notifications {
      /// Get a notification the moment your results are parsed and ready to view.
      public static let body = L10n.tr("Localizable", "setup.notifications.body", fallback: "Get a notification the moment your results are parsed and ready to view.")
      /// Enable notifications
      public static let enable = L10n.tr("Localizable", "setup.notifications.enable", fallback: "Enable notifications")
      /// Not now
      public static let skip = L10n.tr("Localizable", "setup.notifications.skip", fallback: "Not now")
      /// Stay in the loop
      public static let title = L10n.tr("Localizable", "setup.notifications.title", fallback: "Stay in the loop")
    }
  }
  public enum Shared {
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "shared.cancel", fallback: "Cancel")
    /// Log out
    public static let logOut = L10n.tr("Localizable", "shared.log_out", fallback: "Log out")
    /// Try again
    public static let tryAgain = L10n.tr("Localizable", "shared.try_again", fallback: "Try again")
  }
  public enum Status {
    public enum Biomarker {
      /// Critical
      public static let critical = L10n.tr("Localizable", "status.biomarker.critical", fallback: "Critical")
      /// Above
      public static let high = L10n.tr("Localizable", "status.biomarker.high", fallback: "Above")
      /// Below
      public static let low = L10n.tr("Localizable", "status.biomarker.low", fallback: "Below")
      /// Normal
      public static let normal = L10n.tr("Localizable", "status.biomarker.normal", fallback: "Normal")
    }
    public enum BiomarkerA11y {
      /// critical
      public static let critical = L10n.tr("Localizable", "status.biomarker_a11y.critical", fallback: "critical")
      /// above range
      public static let high = L10n.tr("Localizable", "status.biomarker_a11y.high", fallback: "above range")
      /// below range
      public static let low = L10n.tr("Localizable", "status.biomarker_a11y.low", fallback: "below range")
      /// normal
      public static let normal = L10n.tr("Localizable", "status.biomarker_a11y.normal", fallback: "normal")
      /// unknown
      public static let unknown = L10n.tr("Localizable", "status.biomarker_a11y.unknown", fallback: "unknown")
    }
    public enum Document {
      /// Read
      public static let done = L10n.tr("Localizable", "status.document.done", fallback: "Read")
      /// Failed
      public static let failed = L10n.tr("Localizable", "status.document.failed", fallback: "Failed")
      /// Queued
      public static let pending = L10n.tr("Localizable", "status.document.pending", fallback: "Queued")
      /// Reading…
      public static let processing = L10n.tr("Localizable", "status.document.processing", fallback: "Reading…")
    }
  }
  public enum Welcome {
    /// Get started
    public static let getStarted = L10n.tr("Localizable", "welcome.get_started", fallback: "Get started")
    /// Have an account?
    public static let haveAccount = L10n.tr("Localizable", "welcome.have_account", fallback: "Have an account?")
    /// Log in
    public static let logIn = L10n.tr("Localizable", "welcome.log_in", fallback: "Log in")
    public enum Slide1 {
      /// Every result together, over time — no more scattered PDFs and photos.
      public static let body = L10n.tr("Localizable", "welcome.slide1.body", fallback: "Every result together, over time — no more scattered PDFs and photos.")
      /// Your labs, in one calm place.
      public static let title = L10n.tr("Localizable", "welcome.slide1.title", fallback: "Your labs, in one calm place.")
    }
    public enum Slide2 {
      /// Point your camera at a lab result and Healthside reads and organizes it.
      public static let body = L10n.tr("Localizable", "welcome.slide2.body", fallback: "Point your camera at a lab result and Healthside reads and organizes it.")
      /// Snap a photo, we do the rest.
      public static let title = L10n.tr("Localizable", "welcome.slide2.title", fallback: "Snap a photo, we do the rest.")
    }
    public enum Slide3 {
      /// Track biomarkers across visits and spot what's changing.
      public static let body = L10n.tr("Localizable", "welcome.slide3.body", fallback: "Track biomarkers across visits and spot what's changing.")
      /// See your trends over time.
      public static let title = L10n.tr("Localizable", "welcome.slide3.title", fallback: "See your trends over time.")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
