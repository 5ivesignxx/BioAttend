import UIKit

final class SignUpViewController: UIViewController {

    // MARK: - UI
    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    private let logoView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.accent
        v.layer.cornerRadius = 30
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let logoLabel: UILabel = {
        let l = UILabel()
        l.text = "🏢"
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Create Account"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = AppColors.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Register to access biometric attendance"
        l.font = .systemFont(ofSize: 14)
        l.textColor = AppColors.textSecondary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameField     = FloatingTextField(placeholder: "Full Name")
    private let emailField    = FloatingTextField(placeholder: "Work Email")
    private let passwordField = FloatingTextField(placeholder: "Password", isSecure: true)
    private let confirmField  = FloatingTextField(placeholder: "Confirm Password", isSecure: true)
    private let signUpButton  = PrimaryButton(title: "Create Account")

    private let signInButton: UIButton = {
        let b = UIButton(type: .system)
        let attr = NSMutableAttributedString(
            string: "Already have an account? ",
            attributes: [.foregroundColor: AppColors.textSecondary,
                         .font: UIFont.systemFont(ofSize: 14)])
        attr.append(NSAttributedString(
            string: "Sign In",
            attributes: [.foregroundColor: AppColors.accent,
                         .font: UIFont.systemFont(ofSize: 14, weight: .semibold)]))
        b.setAttributedTitle(attr, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.surface
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        setupActions()
        setupKeyboard()
    }

    // MARK: - Layout
    private func setupLayout() {
        // FIX: Full-screen scroll with proper safe-area anchoring
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),        // from very top
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        logoView.addSubview(logoLabel)
        [logoView, titleLabel, subtitleLabel,
         nameField, emailField, passwordField, confirmField,
         signUpButton, signInButton].forEach { contentView.addSubview($0) }

        let pad: CGFloat = 28
        // Use safeAreaLayoutGuide for top spacing so content clears Dynamic Island
        let safeTop = view.safeAreaLayoutGuide.topAnchor

        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            logoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 60),
            logoView.heightAnchor.constraint(equalToConstant: 60),

            logoLabel.centerXAnchor.constraint(equalTo: logoView.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),

            nameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 36),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 24),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            confirmField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            confirmField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            confirmField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            signUpButton.topAnchor.constraint(equalTo: confirmField.bottomAnchor, constant: 40),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: pad),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -pad),

            signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            signInButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signInButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }

    // MARK: - Keyboard (FIX: scroll active field above keyboard)
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
        // Return key moves to next field / triggers submit
        nameField.textField.returnKeyType     = .next
        emailField.textField.returnKeyType    = .next
        passwordField.textField.returnKeyType = .next
        confirmField.textField.returnKeyType  = .done
        nameField.textField.delegate     = self
        emailField.textField.delegate    = self
        passwordField.textField.delegate = self
        confirmField.textField.delegate  = self
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame    = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = frame.height + 24
            self.scrollView.verticalScrollIndicatorInsets.bottom = frame.height
        }
        // Scroll to the currently active field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.scrollToActiveField(keyboardHeight: frame.height)
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        guard let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    private func scrollToActiveField(keyboardHeight: CGFloat) {
        let fields: [FloatingTextField] = [nameField, emailField, passwordField, confirmField]
        for field in fields where field.textField.isFirstResponder {
            // Convert field frame to scrollView coordinates
            let fieldFrameInScroll = field.convert(field.bounds, to: scrollView)
            let visibleHeight = scrollView.bounds.height - keyboardHeight
            let targetOffset = fieldFrameInScroll.maxY - visibleHeight + 24
            if targetOffset > scrollView.contentOffset.y {
                scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: true)
            }
            break
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Actions
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleSignUp() {
        view.endEditing(true)
        clearErrors()

        let name     = nameField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let email    = emailField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.textField.text ?? ""
        let confirm  = confirmField.textField.text ?? ""
        var hasError = false

        if name.isEmpty {
            nameField.showError("Please enter your full name.")
            hasError = true
        }
        if !email.isValidEmail {
            emailField.showError("Please enter a valid work email address.")
            hasError = true
        }
        if password.count < 6 {
            passwordField.showError("Password must be at least 6 characters.")
            hasError = true
        }
        if confirm != password {
            confirmField.showError("Passwords do not match.")
            hasError = true
        }
        if hasError { return }

        let created = CoreDataManager.shared.createUser(name: name, email: email, passwordHash: password.sha256)
        guard created else {
            emailField.showError("An account with this email already exists.")
            return
        }

        showAlert(title: "✅ Account Created",
                  message: "Your account has been successfully created. Please sign in.") {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func goToSignIn() { navigationController?.popViewController(animated: true) }

    private func clearErrors() {
        [nameField, emailField, passwordField, confirmField].forEach { $0.clearError() }
    }
}

// MARK: - UITextFieldDelegate (Return key navigation)
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField.textField:     emailField.textField.becomeFirstResponder()
        case emailField.textField:    passwordField.textField.becomeFirstResponder()
        case passwordField.textField: confirmField.textField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            handleSignUp()
        }
        return true
    }
}
