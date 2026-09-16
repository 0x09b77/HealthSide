// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
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
