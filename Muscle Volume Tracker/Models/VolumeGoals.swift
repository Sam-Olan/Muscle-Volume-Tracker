import Foundation
import SwiftUI

@MainActor
class VolumeGoals: ObservableObject {
    @Published private(set) var goals: [String: Int] = [:]
    @Published var useCustomGoalColor: Bool = false
    @Published var goalAchievedColor: Color = .yellow // Default color
    @Published var hideCardio: Bool = false
    
    private let saveKey = "VolumeGoals"
    private let colorPrefsKey = "ColorPreferences"
    private let hideCardioKey = "HideCardio"
    
    init() {
        loadData()
        loadColorPreferences()
        hideCardio = UserDefaults.standard.bool(forKey: hideCardioKey)
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
    
    private func loadColorPreferences() {
        if let data = UserDefaults.standard.data(forKey: colorPrefsKey) {
            do {
                let prefs = try JSONDecoder().decode(ColorPreferences.self, from: data)
                useCustomGoalColor = prefs.useCustomColor
                if let uiColor = UIColor(hex: prefs.colorHex) {
                    goalAchievedColor = Color(uiColor: uiColor)
                }
            } catch {
                print("Error loading color preferences: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveColorPreferences() {
        do {
            let uiColor = UIColor(goalAchievedColor)
            let colorHex = uiColor.toHex() ?? "#FFDD00"
            let prefs = ColorPreferences(useCustomColor: useCustomGoalColor, colorHex: colorHex)
            let data = try JSONEncoder().encode(prefs)
            UserDefaults.standard.set(data, forKey: colorPrefsKey)
        } catch {
            print("Error saving color preferences: \(error.localizedDescription)")
        }
    }
    
    func updateGoalColor(_ color: Color) {
        goalAchievedColor = color
        saveColorPreferences()
    }
    
    func toggleCustomColor(_ enabled: Bool) {
        useCustomGoalColor = enabled
        saveColorPreferences()
    }
    
    func toggleHideCardio(_ hidden: Bool) {
        hideCardio = hidden
        UserDefaults.standard.set(hidden, forKey: hideCardioKey)
    }
}

// Helper struct for color preferences
private struct ColorPreferences: Codable {
    let useCustomColor: Bool
    let colorHex: String
}

// Helper extensions for color conversion
private extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
    
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        return nil
    }
}