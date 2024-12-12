import Foundation

@MainActor
class VolumeGoals: ObservableObject {
    @Published private(set) var goals: [String: Int] = [:]
    private let saveKey = "VolumeGoals"
    
    init() {
        loadData()
        setDefaultGoalsIfNeeded()
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
    
    func updateGoal(for muscle: String, value: Int) {
        goals[muscle] = value
        saveData()
    }
    
    private func setDefaultGoalsIfNeeded() {
        let defaultGoals: [String: Int] = [
            // Push
            "Chest": 12,
            "Triceps": 12,
            "Front Delts": 12,
            "Side Delts": 12,
            // Pull
            "Lats": 12,
            "Biceps": 12,
            "Mid Back": 12,
            "Rear Delts": 12,
            // Legs
            "Quads": 12,
            "Hamstrings": 12,
            "Glutes": 12,
            "Calves": 12,
            // Misc
            "Core": 12,
            "Forearms": 12,
            "Lower Back": 12,
            // Cardio
            "Cardio": 3
        ]
        
        for (muscle, defaultValue) in defaultGoals {
            if goals[muscle] == nil {
                goals[muscle] = defaultValue
            }
        }
        saveData()
    }
} 