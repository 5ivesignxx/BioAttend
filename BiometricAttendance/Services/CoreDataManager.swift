import CoreData
import UIKit

// MARK: - CoreData Entity Names
enum Entity: String {
    case user       = "UserEntity"
    case attendance = "AttendanceEntity"
}

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).context
    }

    func save() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    // MARK: - User Operations

    /// Creates a new user record. Returns false if email already exists.
    @discardableResult
    func createUser(name: String, email: String, passwordHash: String) -> Bool {
        guard fetchUser(byEmail: email) == nil else { return false }
        let entity = NSEntityDescription.insertNewObject(forEntityName: Entity.user.rawValue, into: context)
        entity.setValue(UUID().uuidString, forKey: "id")
        entity.setValue(name,              forKey: "name")
        entity.setValue(email.lowercased(), forKey: "email")
        entity.setValue(passwordHash,       forKey: "passwordHash")
        entity.setValue(false,              forKey: "biometricRegistered")
        entity.setValue(Date(),             forKey: "createdAt")
        save()
        return true
    }

    func fetchUser(byEmail email: String) -> NSManagedObject? {
        let req = NSFetchRequest<NSManagedObject>(entityName: Entity.user.rawValue)
        req.predicate = NSPredicate(format: "email == %@", email.lowercased())
        return try? context.fetch(req).first
    }

    func updateBiometricRegistered(email: String, registered: Bool) {
        guard let user = fetchUser(byEmail: email) else { return }
        user.setValue(registered, forKey: "biometricRegistered")
        save()
    }

    func isBiometricRegistered(email: String) -> Bool {
        return fetchUser(byEmail: email)?.value(forKey: "biometricRegistered") as? Bool ?? false
    }

    // MARK: - Attendance Operations

    func todayAttendance(email: String) -> NSManagedObject? {
        let req = NSFetchRequest<NSManagedObject>(entityName: Entity.attendance.rawValue)
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end   = calendar.date(byAdding: .day, value: 1, to: start)!
        req.predicate = NSPredicate(
            format: "userEmail == %@ AND date >= %@ AND date < %@",
            email.lowercased(), start as NSDate, end as NSDate
        )
        return try? context.fetch(req).first
    }

    func recordCheckIn(email: String) {
        let record: NSManagedObject
        if let existing = todayAttendance(email: email) {
            record = existing
        } else {
            record = NSEntityDescription.insertNewObject(
                forEntityName: Entity.attendance.rawValue, into: context)
            record.setValue(UUID().uuidString,    forKey: "id")
            record.setValue(email.lowercased(),   forKey: "userEmail")
            record.setValue(Calendar.current.startOfDay(for: Date()), forKey: "date")
        }
        record.setValue(Date(), forKey: "checkInTime")
        save()
    }

    func recordCheckOut(email: String) {
        guard let record = todayAttendance(email: email) else { return }
        record.setValue(Date(), forKey: "checkOutTime")
        save()
    }

    func hasCheckedIn(email: String) -> Bool {
        return todayAttendance(email: email)?.value(forKey: "checkInTime") != nil
    }

    func hasCheckedOut(email: String) -> Bool {
        return todayAttendance(email: email)?.value(forKey: "checkOutTime") != nil
    }

    // MARK: - All Attendance Records for a User
    func allAttendance(email: String) -> [NSManagedObject] {
        let req = NSFetchRequest<NSManagedObject>(entityName: Entity.attendance.rawValue)
        req.predicate  = NSPredicate(format: "userEmail == %@", email.lowercased())
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(req)) ?? []
    }
}
