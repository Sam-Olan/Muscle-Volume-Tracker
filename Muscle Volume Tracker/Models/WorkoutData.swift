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
class WorkoutHistory: ObservableObject {
    @Published private(set) var weeks: [WorkoutWeek] = []
    private let saveKey = "WorkoutHistory"
    
    init() {
        loadData()
    }
    
    func addWeek(_ week: WorkoutWeek) {
        if let index = weeks.firstIndex(where: { Calendar.current.isDate($0.startDate, equalTo: week.startDate, toGranularity: .weekOfYear) }) {
            weeks[index] = week // Update existing week
        } else {
            weeks.append(week) // Add new week
        }
        weeks.sort { $0.startDate > $1.startDate } // Most recent first
        saveData()
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
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
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Error saving workout data: \(error.localizedDescription)")
            // Consider implementing proper error handling
        }
    }
    
    // MARK: - Helper Methods
    func clearAllData() {
        weeks = []
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    func deleteWeek(withID id: UUID) {
        weeks.removeAll { $0.id == id }
        saveData()
    }
} 