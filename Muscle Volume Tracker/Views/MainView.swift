//
//  MainView.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var workoutHistory: WorkoutHistory
    @EnvironmentObject private var volumeGoals: VolumeGoals
    @State var selectedTab = 1
    
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
            HistoryView()
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("History")
                    }
                }
                .tag(0)

            MuscleView()
                .tabItem {
                    VStack {
                        Image(systemName: "figure.arms.open")
                        Text("Volumes")
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
    }
}

#Preview {
    MainView()
        .environmentObject(WorkoutHistory())
        .environmentObject(VolumeGoals())
}
