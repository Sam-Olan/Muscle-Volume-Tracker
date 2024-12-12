import Foundation

struct MuscleIdentifier: Identifiable {
    let name: String
    var id: String { name }
} 