import UIKit

final class HomeViewController: UIViewController {

    // MARK: - State
    private let email = SessionManager.shared.loggedInEmail
    private let name  = SessionManager.shared.loggedInName
    private var isProcessing = false

    // MARK: - UI
    private let navBar: UIView = {
        let v = UIView()
        v.backgroundColor = AppColors.primary
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let greetingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let logoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // Status card
    private let statusCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.layer.shadowRadius  = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let statusIconLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 44)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusTitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = AppColors.textPrimary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // FIX: Show date AND time for check-in/out
    private let checkInTimeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = AppColors.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let checkOutTimeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = AppColors.textSecondary
        l.textAlignment = .center
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let checkInButton  = PrimaryButton(title: "  Check In",  color: AppColors.success)
    private let checkOutButton = PrimaryButton(title: "  Check Out", color: AppColors.warning)

    // Network fetch section
    private let sectionLabel: UILabel = {
        let l = UILabel()
        l.text = "NETWORK TEST"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = AppColors.textSecondary
        l.letterSpacing(1.2)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let fetchDataButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Fetch Data from Server", for: .normal)
        b.setTitleColor(AppColors.accent, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.backgroundColor = UIColor(hex: "#EEF5FF")
        b.layer.cornerRadius = 14
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.hidesWhenStopped = true
        a.color = AppColors.accent
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.surface
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Add icons to buttons
        checkInButton.setImage(UIImage(systemName: "arrow.right.circle.fill"), for: .normal)
        checkInButton.tintColor = .white
        checkInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        checkOutButton.setImage(UIImage(systemName: "arrow.left.circle.fill"), for: .normal)
        checkOutButton.tintColor = .white
        checkOutButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        setupLayout()
        setupActions()
        refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refresh()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(navBar)
        navBar.addSubview(greetingLabel)
        navBar.addSubview(dateLabel)
        navBar.addSubview(logoutButton)

        view.addSubview(statusCard)
        statusCard.addSubview(statusIconLabel)
        statusCard.addSubview(statusTitleLabel)
        statusCard.addSubview(checkInTimeLabel)
        statusCard.addSubview(checkOutTimeLabel)

        view.addSubview(checkInButton)
        view.addSubview(checkOutButton)
        view.addSubview(sectionLabel)
        view.addSubview(fetchDataButton)
        view.addSubview(activityIndicator)

        let pad: CGFloat = 24

        NSLayoutConstraint.activate([
            // Nav bar anchored to very top (covers Dynamic Island area)
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Extend below safe area so content sits below Dynamic Island
            navBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),

            greetingLabel.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: pad),
            greetingLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -14),

            logoutButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -pad),
            logoutButton.centerYAnchor.constraint(equalTo: greetingLabel.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),

            dateLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 2),

            statusCard.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
            statusCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            statusCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            statusIconLabel.topAnchor.constraint(equalTo: statusCard.topAnchor, constant: 24),
            statusIconLabel.centerXAnchor.constraint(equalTo: statusCard.centerXAnchor),

            statusTitleLabel.topAnchor.constraint(equalTo: statusIconLabel.bottomAnchor, constant: 10),
            statusTitleLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 16),
            statusTitleLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -16),

            checkInTimeLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 8),
            checkInTimeLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 16),
            checkInTimeLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -16),

            checkOutTimeLabel.topAnchor.constraint(equalTo: checkInTimeLabel.bottomAnchor, constant: 4),
            checkOutTimeLabel.leadingAnchor.constraint(equalTo: statusCard.leadingAnchor, constant: 16),
            checkOutTimeLabel.trailingAnchor.constraint(equalTo: statusCard.trailingAnchor, constant: -16),
            checkOutTimeLabel.bottomAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: -24),

            checkInButton.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: 28),
            checkInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            checkInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            checkOutButton.topAnchor.constraint(equalTo: checkInButton.bottomAnchor, constant: 14),
            checkOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            checkOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            sectionLabel.topAnchor.constraint(equalTo: checkOutButton.bottomAnchor, constant: 32),
            sectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            fetchDataButton.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            fetchDataButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            fetchDataButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            activityIndicator.centerYAnchor.constraint(equalTo: fetchDataButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: fetchDataButton.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Refresh UI
    private func refresh() {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "EEEE, d MMMM yyyy"
        dateLabel.text = dateFmt.string(from: Date())

        let firstName = name.components(separatedBy: " ").first ?? name
        greetingLabel.text = "Hello, \(firstName) 👋"

        let db = CoreDataManager.shared
        let checkedIn  = db.hasCheckedIn(email: email)
        let checkedOut = db.hasCheckedOut(email: email)
        let record     = db.todayAttendance(email: email)

        // FIX: Show date AND time (e.g. "Mon, 25 May 2026 · 9:04 AM")
        let stampFmt = DateFormatter()
        stampFmt.dateFormat = "EEE, d MMM yyyy · h:mm a"

        if checkedOut {
            statusIconLabel.text  = "✅"
            statusTitleLabel.text = "Day Complete — Checked Out"
            statusTitleLabel.textColor = AppColors.success
        } else if checkedIn {
            statusIconLabel.text  = "🏢"
            statusTitleLabel.text = "Currently Checked In"
            statusTitleLabel.textColor = AppColors.accent
        } else {
            statusIconLabel.text  = "📍"
            statusTitleLabel.text = "Not Yet Checked In Today"
            statusTitleLabel.textColor = AppColors.textPrimary
        }

        if let t = record?.value(forKey: "checkInTime") as? Date {
            checkInTimeLabel.text = "✅ Checked in: \(stampFmt.string(from: t))"
            checkInTimeLabel.isHidden = false
        } else {
            checkInTimeLabel.isHidden = true
        }

        if let t = record?.value(forKey: "checkOutTime") as? Date {
            checkOutTimeLabel.text = "🚪 Checked out: \(stampFmt.string(from: t))"
            checkOutTimeLabel.isHidden = false
        } else {
            checkOutTimeLabel.isHidden = true
        }

        // FIX: Disable buttons AND keep disabled even if user taps again
        // Buttons are greyed out and show clear tooltips via alerts when tapped while disabled
        checkInButton.isEnabled  = !checkedIn
        checkInButton.alpha      = checkedIn ? 0.45 : 1.0
        checkOutButton.isEnabled = checkedIn && !checkedOut
        checkOutButton.alpha     = (checkedIn && !checkedOut) ? 1.0 : 0.45
    }

    // MARK: - Actions
    private func setupActions() {
        checkInButton.addTarget(self,   action: #selector(handleCheckIn),   for: .touchUpInside)
        checkOutButton.addTarget(self,  action: #selector(handleCheckOut),  for: .touchUpInside)
        fetchDataButton.addTarget(self, action: #selector(handleFetchData), for: .touchUpInside)
        logoutButton.addTarget(self,    action: #selector(handleLogout),    for: .touchUpInside)

        // FIX: Also handle taps when button is disabled to show informative message
        // We add gesture recognisers that fire regardless of enabled state
        let checkInTap  = UITapGestureRecognizer(target: self, action: #selector(checkInTapped))
        let checkOutTap = UITapGestureRecognizer(target: self, action: #selector(checkOutTapped))
        checkInButton.addGestureRecognizer(checkInTap)
        checkOutButton.addGestureRecognizer(checkOutTap)
    }

    // These intercept ALL taps on the button (enabled or not)
    @objc private func checkInTapped() {
        if CoreDataManager.shared.hasCheckedIn(email: email) {
            // FIX: Proper message when already checked in
            let db = CoreDataManager.shared
            let stampFmt = DateFormatter()
            stampFmt.dateFormat = "h:mm a"
            var msg = "You have already checked in today."
            if let t = db.todayAttendance(email: email)?.value(forKey: "checkInTime") as? Date {
                msg = "You already checked in at \(stampFmt.string(from: t)) today.\n\nYou can only check in once per day."
            }
            showAlert(title: "Already Checked In", message: msg)
            return
        }
        performAttendanceAction(isCheckIn: true)
    }

    @objc private func checkOutTapped() {
        let db = CoreDataManager.shared
        let stampFmt = DateFormatter()
        stampFmt.dateFormat = "h:mm a"

        if !db.hasCheckedIn(email: email) {
            showAlert(title: "Not Checked In",
                      message: "You haven't checked in yet today. Please check in first.")
            return
        }
        if db.hasCheckedOut(email: email) {
            // FIX: Proper message when already checked out
            var msg = "You have already checked out today."
            if let t = db.todayAttendance(email: email)?.value(forKey: "checkOutTime") as? Date {
                msg = "You already checked out at \(stampFmt.string(from: t)) today.\n\nYou can only check out once per day."
            }
            showAlert(title: "Already Checked Out", message: msg)
            return
        }
        performAttendanceAction(isCheckIn: false)
    }

    @objc private func handleCheckIn()  { /* handled by gesture above */ }
    @objc private func handleCheckOut() { /* handled by gesture above */ }

    // MARK: - Attendance Flow
    private func performAttendanceAction(isCheckIn: Bool) {
        guard !isProcessing else { return }
        isProcessing = true
        let action = isCheckIn ? "Check In" : "Check Out"

        let bio = BiometricService.shared

        // CASE 1: Biometric not yet registered
        if !CoreDataManager.shared.isBiometricRegistered(email: email) {
            isProcessing = false
            let alert = UIAlertController(
                title: "Register \(bio.biometricType)",
                message: "You need to register your \(bio.biometricType) before you can mark attendance.\n\nWould you like to register now?",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Register Now", style: .default) { [weak self] _ in
                self?.registerBiometric()
            })
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
            present(alert, animated: true)
            return
        }

        // CASE 2: Biometric registered — authenticate
        bio.authenticate(reason: "\(action): Verify your identity") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.verifyLocationThenRecord(isCheckIn: isCheckIn)
            case .failure(let err):
                self.isProcessing = false
                if case .cancelled = err { return }
                self.showAlert(title: "Authentication Failed", message: err.localizedDescription)
            }
        }
    }

    private func registerBiometric() {
        let bio = BiometricService.shared
        bio.authenticate(reason: "Scan your \(bio.biometricType) to register it with BioAttend.") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                CoreDataManager.shared.updateBiometricRegistered(email: self.email, registered: true)
                // FIX: Success notification with clear message
                self.showAlert(
                    title: "✅ \(bio.biometricType) Registered!",
                    message: "Your \(bio.biometricType) has been successfully registered.\n\nYou can now use it to check in and out.") {
                    // After registration, allow them to immediately proceed
                }
            case .failure(let err):
                if case .cancelled = err { return }
                self.showAlert(title: "Registration Failed", message: err.localizedDescription)
            }
        }
    }

    private func verifyLocationThenRecord(isCheckIn: Bool) {
        LocationService.shared.verifyOfficeLocation { [weak self] result in
            guard let self else { return }
            self.isProcessing = false
            switch result {
            case .success:
                let stampFmt = DateFormatter()
                stampFmt.dateFormat = "EEE, d MMM yyyy · h:mm a"
                let now = stampFmt.string(from: Date())

                if isCheckIn {
                    CoreDataManager.shared.recordCheckIn(email: self.email)
                    self.showAlert(
                        title: "✅ Checked In Successfully",
                        message: "You have been checked in.\n\n📅 \(now)") { self.refresh() }
                } else {
                    CoreDataManager.shared.recordCheckOut(email: self.email)
                    self.showAlert(
                        title: "👋 Checked Out Successfully",
                        message: "You have been checked out.\n\n📅 \(now)") { self.refresh() }
                }
            case .failure(let err):
                self.showAlert(title: "Location Error", message: err.localizedDescription)
            }
        }
    }

    // MARK: - Network Fetch with Swift do-catch error handling
    @objc private func handleFetchData() {
        activityIndicator.startAnimating()
        fetchDataButton.isEnabled = false

        // FIX: Use Swift throws/do-catch pattern as required
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            do {
                // fetchTodosSync() uses Swift's throw mechanism
                let items = try NetworkService.shared.fetchTodosSync()
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.fetchDataButton.isEnabled = true
                    let preview = items.prefix(3).map { "• \($0.title)" }.joined(separator: "\n")
                    self.showAlert(
                        title: "✅ Data Fetched",
                        message: "Successfully received \(items.count) records.\n\nSample:\n\(preview)")
                }
            } catch let error as NetworkError {
                // Caught via Swift error handling — specific NetworkError cases
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.fetchDataButton.isEnabled = true
                    // Show distinct UI for each error case
                    switch error {
                    case .noInternet:
                        self.showNetworkErrorAlert(
                            title: "No Internet Connection",
                            message: "Your device is not connected to the internet.\n\nPlease check your Wi-Fi or mobile data and try again.",
                            icon: "wifi.slash")
                    case .noData:
                        self.showNetworkErrorAlert(
                            title: "No Data Received",
                            message: "The server responded but returned no data.\n\nPlease try again later.",
                            icon: "tray.slash")
                    default:
                        self.showErrorAlert(error.localizedDescription ?? "Unknown error")
                    }
                }
            } catch {
                // Catch-all for any other Swift Error
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.fetchDataButton.isEnabled = true
                    self.showErrorAlert(error.localizedDescription)
                }
            }
        }
    }

    private func showNetworkErrorAlert(title: String, message: String, icon: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.handleFetchData()
        })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Logout
    @objc private func handleLogout() {
        let alert = UIAlertController(title: "Log Out",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            SessionManager.shared.logout()
            let nav = UINavigationController(rootViewController: SignInViewController())
            nav.setNavigationBarHidden(true, animated: false)
            self?.view.window?.rootViewController = nav
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UILabel extension for letter spacing
private extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        if let text = self.text {
            let attributed = NSAttributedString(string: text, attributes: [
                .kern: spacing,
                .foregroundColor: self.textColor ?? .label,
                .font: self.font ?? .systemFont(ofSize: 12)
            ])
            self.attributedText = attributed
        }
    }
}
