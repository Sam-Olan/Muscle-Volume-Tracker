import Foundation
import SwiftUI

enum MuscleCategories {
    static let categories: [String: [String]] = [
        "Push": ["Chest", "Triceps", "Front Delts", "Side Delts"],
        "Pull": ["Lats", "Mid Back", "Biceps", "Rear Delts"],
        "Legs": ["Quads", "Hamstrings", "Glutes", "Calves"],
        "Misc": ["Core", "Forearms", "Lower Back"],
        "Cardio": ["Cardio"]
    ]
    
    static let order = ["Push", "Pull", "Legs", "Misc", "Cardio"]
    
    static let muscleViewCategories = ["Push", "Pull", "Legs", "Misc"]
}

enum CalendarConstants {
    static let weekDays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    static let cellHeight: CGFloat = 44
    static let monthSpacing: CGFloat = 20
}

enum ViewConstants {
    static let modalMaxWidth: CGFloat = 500
    static let modalVerticalPadding: CGFloat = 25
    static let scrollIndicatorDelay: Double = 0.5
    static let scrollIndicatorDuration: Double = 1.0
    static let lockIconSize: CGFloat = 24
} 