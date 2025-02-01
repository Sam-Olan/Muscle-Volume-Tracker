//
//  MainView.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//

import SwiftUI

class NoAnimationTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Disable animation by setting the selected view controller directly
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            tabBarController.selectedIndex = index
            return false
        }
        return true
    }
}

struct NoAnimationTabView: UIViewControllerRepresentable {
    let content: UITabBarController
    
    init(@ViewBuilder content: () -> UITabBarController) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> UITabBarController {
        content
    }
    
    func updateUIViewController(_ tabBarController: UITabBarController, context: Context) {
    }
}

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
        NoAnimationTabView {
            let tabController = NoAnimationTabBarController()
            let historyVC = UIHostingController(rootView: HistoryView())
            let muscleVC = UIHostingController(rootView: MuscleView())
            let personalVC = UIHostingController(rootView: PersonalView())
            
            historyVC.tabBarItem = UITabBarItem(
                title: "History",
                image: UIImage(systemName: "clock"),
                tag: 0
            )
            
            muscleVC.tabBarItem = UITabBarItem(
                title: "Volumes",
                image: UIImage(systemName: "figure.arms.open"),
                tag: 1
            )
            
            personalVC.tabBarItem = UITabBarItem(
                title: "Personal",
                image: UIImage(systemName: "person"),
                tag: 2
            )
            
            tabController.viewControllers = [historyVC, muscleVC, personalVC]
            tabController.selectedIndex = selectedTab
            
            return tabController
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MainView()
        .environmentObject(WorkoutHistory())
        .environmentObject(VolumeGoals())
}
