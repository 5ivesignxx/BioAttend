import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // FIX 1: Use UIWindow(windowScene:) via scene delegation fails on older setups.
        // Use the full-screen frame and explicitly set to device bounds so
        // iPhone 16 Pro Max renders edge-to-edge (not half-screen).
        let window = UIWindow()
        window.frame = UIScreen.main.bounds
        window.overrideUserInterfaceStyle = .light   // keep consistent light theme

        let rootVC: UIViewController
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            rootVC = HomeViewController()
        } else {
            rootVC = SignInViewController()
        }

        let nav = UINavigationController(rootViewController: rootVC)
        nav.setNavigationBarHidden(true, animated: false)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BiometricAttendance")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData store failed: \(error)") }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        let ctx = persistentContainer.viewContext
        if ctx.hasChanges { try? ctx.save() }
    }
}
