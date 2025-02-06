import Foundation

struct WorkoutWeek: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    let muscleValues: [String: Int]
    
    init(startDate: Date, muscleValues: [String: Int]) {
        self.id = UUID()
        self.startDate = startDate
        self.muscleValues = muscleValues
    }
}

@MainActor
final class WorkoutHistory: ObservableObject {
    @Published private(set) var weeks: [WorkoutWeek] = []
    private let saveKey = "WorkoutHistory"
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadData()
    }
    
    func addWeek(_ week: WorkoutWeek) {
        // Check if all values are 0
        let hasNoData = week.muscleValues.isEmpty || week.muscleValues.allSatisfy { $0.value == 0 }
        
        if let index = weeks.firstIndex(where: { Calendar.shared.isDate($0.startDate, equalTo: week.startDate, toGranularity: .weekOfYear) }) {
            if hasNoData {
                weeks.remove(at: index)
            } else {
                weeks[index] = week
            }
        } else if !hasNoData {
            weeks.append(week)
        }
        
        weeks.sort { $0.startDate > $1.startDate }
        saveData()
    }
    
    private func loadData() {
        guard let data = userDefaults.data(forKey: saveKey) else { return }
        
        do {
            weeks = try JSONDecoder().decode([WorkoutWeek].self, from: data)
        } catch {
            print("Error loading workout data: \(error.localizedDescription)")
            // Consider implementing proper error handling
        }
    }
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(weeks)
            userDefaults.set(data, forKey: saveKey)
        } catch {
            print("Error saving workout data: \(error.localizedDescription)")
            // Consider implementing proper error handling
        }
    }
    
    // MARK: - Helper Methods
    func clearAllData() {
        weeks.removeAll()
        userDefaults.removeObject(forKey: saveKey)
    }
    
    func deleteWeek(withID id: UUID) {
        weeks.removeAll { $0.id == id }
        saveData()
    }
} 