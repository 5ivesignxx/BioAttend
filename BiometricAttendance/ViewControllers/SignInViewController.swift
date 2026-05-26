import UIKit

final class SignInViewController: UIViewController {

    // MARK: - UI
    private let scrollView   = UIScrollView()
    private let contentView  = UIView()

    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.primary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let brandLabel: UILabel = {
        let l = UILabel()
        l.text = "BioAttend"
        l.font = .systemFont(ofSize: 36, weight: .black)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let taglineLabel: UILabel = {
        let l = UILabel()
        l.text = "Touchless. Secure. Accurate."
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.65)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.10
        v.layer.shadowOffset  = CGSize(width: 0, height: -6)
        v.layer.shadowRadius  = 24
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let signInTitle: UILabel = {
        let l = UILabel()
        l.text = "Welcome back"
        l.font = .systemFont(ofSize: 26, weight: .bold)
        l.textColor = AppColors.textPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let emailField    = FloatingTextField(placeholder: "Email Address")
    private let passwordField = FloatingTextField(placeholder: "Password", isSecure: true)
    private let signInButton  = PrimaryButton(title: "Sign In")

    private let signUpButton: UIButton = {
        let b = UIButton(type: .system)
        let attr = NSMutableAttributedString(
            string: "Don't have an account? ",
            attributes: [.foregroundColor: AppColors.textSecondary,
                         .font: UIFont.systemFont(ofSize: 14)])
        attr.append(NSAttributedString(
            string: "Sign Up",
            attributes: [.foregroundColor: AppColors.accent,
                         .font: UIFont.systemFont(ofSize: 14, weight: .semibold)]))
        b.setAttributedTitle(attr, for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // FIX: keyboard bottom constraint (animated up/down)
    private var cardBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.primary
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        setupActions()
        setupKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Layout
    private func setupLayout() {
        // FIX: pin scrollView to safeArea edges (full screen incl. Dynamic Island area)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        contentView.addSubview(headerView)
        headerView.addSubview(brandLabel)
        headerView.addSubview(taglineLabel)
        contentView.addSubview(cardView)
        cardView.addSubview(signInTitle)
        cardView.addSubview(emailField)
        cardView.addSubview(passwordField)
        cardView.addSubview(signInButton)
        cardView.addSubview(signUpButton)

        let pad: CGFloat = 28

        // FIX: header uses safeArea top so it fills from very top on iPhone 16 Pro Max
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.38),

            brandLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            brandLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 8),

            taglineLabel.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 8),
            taglineLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            // Card fills rest of screen from 30pt below header top-overlap
            cardView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // FIX: extend to real bottom of screen (safe area included)
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.65),

            signInTitle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            signInTitle.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),

            emailField.topAnchor.constraint(equalTo: signInTitle.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -pad),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 24),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -pad),

            signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 40),
            signInButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            signInButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -pad),

            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
        ])
    }

    // MARK: - Keyboard (FIX: scroll active field above keyboard)
    private func setupKeyboard() {
        scrollView.keyboardDismissMode = .interactive
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = frame.height + 24
            self.scrollView.verticalScrollIndicatorInsets.bottom = frame.height
            // Scroll so the password field (bottom-most) stays visible
            let target = self.signInButton.frame.maxY + 24
            self.scrollView.setContentOffset(CGPoint(x: 0, y: max(0, target - self.view.bounds.height + frame.height)), animated: false)
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        guard let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Actions
    private func setupActions() {
        signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(goToSignUp), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func handleSignIn() {
        emailField.clearError()
        passwordField.clearError()

        let email    = emailField.textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.textField.text ?? ""
        var hasError = false

        if !email.isValidEmail {
            emailField.showError("Please enter a valid email address.")
            hasError = true
        }
        if password.isEmpty {
            passwordField.showError("Please enter your password.")
            hasError = true
        }
        if hasError { return }

        guard let user = CoreDataManager.shared.fetchUser(byEmail: email) else {
            emailField.showError("No account found with this email.")
            return
        }

        let storedHash = user.value(forKey: "passwordHash") as? String ?? ""
        guard password.sha256 == storedHash else {
            passwordField.showError("Incorrect password. Please try again.")
            return
        }

        view.endEditing(true)
        let name = user.value(forKey: "name") as? String ?? ""
        SessionManager.shared.login(email: email, name: name)

        let homeVC = HomeViewController()
        navigationController?.setViewControllers([homeVC], animated: true)
    }

    @objc private func goToSignUp() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
}
