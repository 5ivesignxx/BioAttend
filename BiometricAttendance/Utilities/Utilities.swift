import UIKit
import CommonCrypto

// MARK: - Email Validation
extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// SHA-256 hash (for password storage – use proper KDF in production)
    var sha256: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest) }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Session Manager
final class SessionManager {
    static let shared = SessionManager()
    private init() {}

    private let defaults = UserDefaults.standard

    var isLoggedIn: Bool {
        get { defaults.bool(forKey: "isLoggedIn") }
        set { defaults.set(newValue, forKey: "isLoggedIn") }
    }

    var loggedInEmail: String {
        get { defaults.string(forKey: "loggedInEmail") ?? "" }
        set { defaults.set(newValue, forKey: "loggedInEmail") }
    }

    var loggedInName: String {
        get { defaults.string(forKey: "loggedInName") ?? "" }
        set { defaults.set(newValue, forKey: "loggedInName") }
    }

    func login(email: String, name: String) {
        isLoggedIn  = true
        loggedInEmail = email
        loggedInName  = name
    }

    func logout() {
        isLoggedIn    = false
        loggedInEmail = ""
        loggedInName  = ""
    }
}

// MARK: - Design Tokens
enum AppColors {
    static let primary    = UIColor(hex: "#1B2B4B")   // deep navy
    static let accent     = UIColor(hex: "#4F9CF9")   // bright blue
    static let surface    = UIColor(hex: "#F5F7FA")
    static let card       = UIColor.white
    static let success    = UIColor(hex: "#27AE60")
    static let danger     = UIColor(hex: "#E74C3C")
    static let warning    = UIColor(hex: "#F39C12")
    static let textPrimary = UIColor(hex: "#1B2B4B")
    static let textSecondary = UIColor(hex: "#6B7A99")
}

extension UIColor {
    convenience init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        self.init(red:   CGFloat((rgb >> 16) & 0xFF) / 255,
                  green: CGFloat((rgb >>  8) & 0xFF) / 255,
                  blue:  CGFloat( rgb        & 0xFF) / 255,
                  alpha: 1)
    }
}

// MARK: - Reusable UI Components
final class PrimaryButton: UIButton {
    init(title: String, color: UIColor = AppColors.accent) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        backgroundColor = color
        layer.cornerRadius = 14
        heightAnchor.constraint(equalToConstant: 54).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) { fatalError() }

    func setLoading(_ loading: Bool) {
        isEnabled = !loading
        alpha = loading ? 0.7 : 1.0
        setTitle(loading ? nil : currentTitle, for: .normal)
    }
}

final class FloatingTextField: UIView {
    let textField = UITextField()
    private let label = UILabel()
    private let line  = UIView()
    private let errorLabel = UILabel()

    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        label.text = placeholder
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.textSecondary

        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = AppColors.textPrimary
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false

        line.backgroundColor = UIColor.systemGray4
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1.5).isActive = true

        errorLabel.font = .systemFont(ofSize: 11)
        errorLabel.textColor = AppColors.danger
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [label, textField, line, errorLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        errorLabel.isHidden = true

        textField.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func editingBegan() { line.backgroundColor = AppColors.accent }
    @objc private func editingEnded() { line.backgroundColor = UIColor.systemGray4 }

    func showError(_ msg: String) {
        errorLabel.text = msg
        errorLabel.isHidden = false
        line.backgroundColor = AppColors.danger
    }

    func clearError() {
        errorLabel.isHidden = true
        line.backgroundColor = UIColor.systemGray4
    }
}

// MARK: - Alert Helper
extension UIViewController {
    func showAlert(title: String, message: String, action: String = "OK",
                   handler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default) { _ in handler?() })
        present(alert, animated: true)
    }

    func showErrorAlert(_ message: String) {
        showAlert(title: "Error", message: message)
    }
}
