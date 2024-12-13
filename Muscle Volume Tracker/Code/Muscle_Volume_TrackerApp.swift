//
//  Muscle_Volume_TrackerApp.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//

import SwiftUI

@main
struct Muscle_Volume_TrackerApp: App {
    @StateObject private var workoutHistory = WorkoutHistory()
    @StateObject private var volumeGoals = VolumeGoals()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(workoutHistory)
                .environmentObject(volumeGoals)
        }
    }
}
