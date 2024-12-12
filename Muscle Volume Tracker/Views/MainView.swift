//
//  MainView.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//

import SwiftUI

struct MainView: View {
    @StateObject private var workoutHistory: WorkoutHistory = {
        let history = WorkoutHistory()
        // Any additional setup if needed
        return history
    }()
    @State var selectedTab = 0
    @State private var shouldCloseTiles = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .darkGray
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MuscleView()
                .environmentObject(workoutHistory)
                .tabItem {
                    VStack {
                        Image(systemName: "figure.arms.open")
                        Text("Volumes")
                    }
                }
                .tag(0)

            HistoryView(closeModalsOnTabChange: shouldCloseTiles)
                .environmentObject(workoutHistory)
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("History")
                    }
                }
                .tag(1)
            
            PersonalView()
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("Personal")
                    }
                }
                .tag(2)
        }
        .accentColor(.white)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 0 {
                // Immediately close tiles when switching to Volumes tab
                shouldCloseTiles = true
            } else {
                shouldCloseTiles = false
            }
        }
    }
}

#Preview {
    MainView()
}
