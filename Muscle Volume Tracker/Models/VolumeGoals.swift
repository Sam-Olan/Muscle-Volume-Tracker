import Foundation

@MainActor
class VolumeGoals: ObservableObject {
    @Published private(set) var goals: [String: Int] = [:]
    private let saveKey = "VolumeGoals"
    
    init() {
        loadData()
    }
    
    func updateGoal(for muscle: String, value: Int) {
        goals[muscle] = value
        saveData()
    }
    
    func getGoal(for muscle: String) -> Int {
        return goals[muscle] ?? (muscle == "Cardio" ? 3 : 12) // Default values
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        do {
            goals = try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            print("Error loading volume goals: \(error.localizedDescription)")
        }
    }
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Error saving volume goals: \(error.localizedDescription)")
        }
    }
} 