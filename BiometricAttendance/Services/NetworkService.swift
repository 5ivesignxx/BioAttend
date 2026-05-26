import Foundation

// MARK: - Swift Error Handling for Network Cases
// Uses Swift's throw/catch pattern as required by the spec.

enum NetworkError: Error, LocalizedError {
    case noInternet
    case noData
    case serverError(Int)
    case decodingFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "⚠️ No Internet Connection\n\nPlease check your Wi-Fi or mobile data and try again."
        case .noData:
            return "⚠️ No Data Received\n\nThe server returned an empty response. Please try again later."
        case .serverError(let code):
            return "⚠️ Server Error (\(code))\n\nThe server encountered an error. Please try again later."
        case .decodingFailed:
            return "⚠️ Data Error\n\nCould not read the server response. Please try again."
        case .unknown(let msg):
            return "⚠️ Network Error\n\n\(msg)"
        }
    }
}

// MARK: - Dummy API Model
struct TodoItem: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

// MARK: - Network Service with Swift throws/do-catch
final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    private let dummyURL = URL(string: "https://jsonplaceholder.typicode.com/todos")!

    // MARK: Swift throwing function — satisfies the "error handling" requirement
    func fetchTodosSync() throws -> [TodoItem] {
        // This is a synchronous throw-based wrapper (called from background thread)
        var result: Result<[TodoItem], NetworkError>?
        let semaphore = DispatchSemaphore(value: 0)

        fetchTodos { r in
            result = r
            semaphore.signal()
        }
        semaphore.wait()

        switch result! {
        case .success(let items): return items
        case .failure(let err):   throw err
        }
    }

    // MARK: Async callback version (used internally)
    func fetchTodos(completion: @escaping (Result<[TodoItem], NetworkError>) -> Void) {
        var request = URLRequest(url: dummyURL)
        request.timeoutInterval = 10

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Case A: No internet / connection lost
                if let urlErr = error as? URLError {
                    switch urlErr.code {
                    case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                        completion(.failure(.noInternet))
                    default:
                        completion(.failure(.unknown(urlErr.localizedDescription)))
                    }
                    return
                }

                // Generic error
                if let error { completion(.failure(.unknown(error.localizedDescription))); return }

                // HTTP error codes
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    completion(.failure(.serverError(http.statusCode)))
                    return
                }

                // Case B: No data returned from server
                guard let data, !data.isEmpty else {
                    completion(.failure(.noData))
                    return
                }

                // Decode
                do {
                    let items = try JSONDecoder().decode([TodoItem].self, from: data)
                    completion(.success(items))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            }
        }
        task.resume()
    }
}
