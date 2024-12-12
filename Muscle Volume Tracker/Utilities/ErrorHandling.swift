import Foundation

enum AppError: LocalizedError {
    case dataLoadFailed
    case dataSaveFailed
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .dataLoadFailed:
            return "Failed to load workout data"
        case .dataSaveFailed:
            return "Failed to save workout data"
        case .invalidData:
            return "The workout data appears to be invalid"
        }
    }
}

protocol ErrorHandler {
    func handle(_ error: Error)
}

class DefaultErrorHandler: ErrorHandler {
    static let shared = DefaultErrorHandler()
    
    func handle(_ error: Error) {
        // Log the error
        print("Error occurred: \(error.localizedDescription)")
        
        // In a production app, you might want to:
        // 1. Send to analytics
        // 2. Show user feedback
        // 3. Attempt recovery
        // 4. Log to a service like Firebase Crashlytics
    }
} 