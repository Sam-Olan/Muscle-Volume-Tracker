//
//  MainView.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//

import SwiftUI

struct CustomTabContainer: View {
    @Binding var selectedTab: Int
    let content: [TabItem]
    
    struct TabItem {
        let view: AnyView
        let icon: String
        let title: String
        let tag: Int
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content area
            content[selectedTab].view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<content.count, id: \.self) { index in
                        Button {
                            selectedTab = index
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: content[index].icon)
                                    .font(.system(size: 24))
                                Text(content[index].title)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(selectedTab == index ? .white : .gray)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 8)
                
                Color.clear
                    .frame(height: 20)
            }
            .background(Color(.darkGray))
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var workoutHistory: WorkoutHistory
    @EnvironmentObject private var volumeGoals: VolumeGoals
    @State var selectedTab = 1
    
    var body: some View {
        CustomTabContainer(selectedTab: $selectedTab, content: [
            .init(
                view: AnyView(HistoryView()),
                icon: "clock.fill",
                title: "History",
                tag: 0
            ),
            .init(
                view: AnyView(MuscleView()),
                icon: "figure.arms.open",
                title: "Volumes",
                tag: 1
            ),
            .init(
                view: AnyView(PersonalView()),
                icon: "person.fill",
                title: "Personal",
                tag: 2
            )
        ])
        .ignoresSafeArea(edges: .bottom)
    }
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .darkGray
        
        // Set selected icon and text color to white
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
}

#Preview {
    MainView()
        .environmentObject(WorkoutHistory())
        .environmentObject(VolumeGoals())
}
