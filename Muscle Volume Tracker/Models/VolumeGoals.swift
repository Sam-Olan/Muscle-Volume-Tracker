import Foundation
import SwiftUI

@MainActor
final class VolumeGoals: ObservableObject {
    @Published private(set) var goals: [String: Int] = [:]
    @Published var useCustomGoalColor: Bool = false
    @Published var goalAchievedColor: Color = .yellow
    @Published var hideCardio: Bool = false
    
    private let saveKey = "VolumeGoals"
    private let colorPrefsKey = "ColorPreferences"
    private let hideCardioKey = "HideCardio"
    private let userDefaults: UserDefaults
    
    private struct ColorPreferences: Codable {
        var useCustomColor: Bool
        var colorComponents: [CGFloat]
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadData()
        loadColorPreferences()
        hideCardio = userDefaults.bool(forKey: hideCardioKey)
    }
    
    func updateGoal(for muscle: String, value: Int) {
        goals[muscle] = max(0, value) // Ensure non-negative values
        saveData()
    }
    
    func getGoal(for muscle: String) -> Int {
        return goals[muscle] ?? getDefaultGoal(for: muscle)
    }
    
    func toggleCustomColor(_ enabled: Bool) {
        useCustomGoalColor = enabled
        saveColorPreferences()
    }
    
    func updateGoalColor(_ color: Color) {
        goalAchievedColor = color
        saveColorPreferences()
    }
    
    func toggleHideCardio(_ hide: Bool) {
        hideCardio = hide
        userDefaults.set(hide, forKey: hideCardioKey)
    }
    
    // MARK: - Private Methods
    
    private func getDefaultGoal(for muscle: String) -> Int {
        muscle == "Cardio" ? 3 : 12
    }
    
    private func loadData() {
        guard let data = userDefaults.data(forKey: saveKey) else { return }
        do {
            goals = try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            print("Error loading volume goals: \(error.localizedDescription)")
        }
    }
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(goals)
            userDefaults.set(data, forKey: saveKey)
        } catch {
            print("Error saving volume goals: \(error.localizedDescription)")
        }
    }
    
    private func loadColorPreferences() {
        guard let data = userDefaults.data(forKey: colorPrefsKey) else { return }
        do {
            let prefs = try JSONDecoder().decode(ColorPreferences.self, from: data)
            useCustomGoalColor = prefs.useCustomColor
            goalAchievedColor = Color(colorComponents: prefs.colorComponents)
        } catch {
            print("Error loading color preferences: \(error.localizedDescription)")
        }
    }
    
    private func saveColorPreferences() {
        do {
            let components = goalAchievedColor.components
            let prefs = ColorPreferences(useCustomColor: useCustomGoalColor, colorComponents: components)
            let data = try JSONEncoder().encode(prefs)
            userDefaults.set(data, forKey: colorPrefsKey)
        } catch {
            print("Error saving color preferences: \(error.localizedDescription)")
        }
    }
}

// MARK: - Color Extensions
private extension Color {
    var components: [CGFloat] {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }
    
    init(colorComponents: [CGFloat]) {
        self.init(red: colorComponents[0],
                 green: colorComponents[1],
                 blue: colorComponents[2],
                 opacity: colorComponents[3])
    }
}