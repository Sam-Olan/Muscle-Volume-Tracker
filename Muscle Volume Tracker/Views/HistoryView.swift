//
//  HistoryView.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//


import SwiftUI

struct ModalView<Content: View>: View {
    let content: Content
    let title: String
    @Binding var isPresented: Bool
    @State private var showScrollIndicator = false
    
    init(title: String, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
                    .zIndex(1)
                
                VStack(spacing: 0) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        Spacer()
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    
                    Divider()
                    
                    ScrollView {
                        content
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .padding(.bottom, -4)
                    }
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.72)
                    .scrollIndicators(.hidden)
                }
                .frame(maxWidth: min(UIScreen.main.bounds.width - 40, 500))
                .background(Color(.systemBackground).opacity(0.98))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .padding(.vertical, 20)
                .zIndex(2)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 85)
                .onAppear {
                    showScrollIndicator = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showScrollIndicator = false
                    }
                }
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}

struct HistoryView: View {
    @EnvironmentObject private var workoutHistory: WorkoutHistory
    @State private var selectedWeek: WorkoutWeek?
    @State private var showingAllTimeStats = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    if workoutHistory.weeks.isEmpty {
                        VStack(spacing: 0) {
                            Spacer()
                                .frame(height: 60)
                            
                            Text("No workout data available")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Start tracking your sets in the Volumes tab")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationBarTitleDisplayMode(.inline)
                    } else {
                        VStack(spacing: 0) {
                            // Title
                            Text("Volume History")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 24)
                                .padding(.bottom, 8)
                                .padding(.horizontal, 20)
                                .background(Color(.systemGroupedBackground))
                            
                            // List
                            List {
                                Button {
                                    showingAllTimeStats = true
                                } label: {
                                    HStack {
                                        Text("All Time Stats")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                
                                Section {
                                    ForEach(workoutHistory.weeks) { week in
                                        Button {
                                            selectedWeek = week
                                        } label: {
                                            HStack {
                                                Text(getDateRange(for: week.startDate))
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.blue)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                } header: {
                                    Text("Volume Per Week")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .textCase(nil)
                                        .foregroundColor(.primary)
                                        .padding(.top, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, -19)
                                }
                                
                                Section {
                                    Button(role: .destructive) {
                                        showingResetConfirmation = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Reset All Data")
                                        }
                                    }
                                    .tint(.red)
                                } header: {
                                    Text("Data Management")
                                        .font(.headline)
                                        .textCase(nil)
                                        .foregroundColor(.primary)
                                }
                            }
                            .listStyle(.insetGrouped)
                        }
                        .background(Color(.systemGroupedBackground))
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            
            // Modal views
            if let week = selectedWeek {
                ModalView(title: getDateRange(for: week.startDate), isPresented: Binding(
                    get: { selectedWeek != nil },
                    set: { if !$0 { selectedWeek = nil } }
                )) {
                    WeekDetailContent(week: week)
                }
            }
            
            if showingAllTimeStats {
                ModalView(title: "All Time Stats", isPresented: $showingAllTimeStats) {
                    AllTimeStatsContent(workoutHistory: workoutHistory)
                }
            }
        }
        .confirmationDialog(
            "Reset All Data",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                workoutHistory.clearAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all workout data. This action cannot be undone.")
        }
    }
    
    private func getDateRange(for startDate: Date) -> String {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
}

struct WeekDetailContent: View {
    let week: WorkoutWeek
    @State private var expandedSections: Set<String> = Set(MuscleCategories.order)
    
    var body: some View {
        MuscleGroupList(
            muscleValues: week.muscleValues,
            expandedSections: $expandedSections
        )
    }
}

struct AllTimeStatsContent: View {
    let workoutHistory: WorkoutHistory
    @State private var expandedSections: Set<String> = Set(MuscleCategories.order)
    
    private var allTimeSets: [String: Int] {
        workoutHistory.weeks.reduce(into: [:]) { totals, week in
            for (muscle, sets) in week.muscleValues {
                totals[muscle, default: 0] += sets
            }
        }
    }
    
    var body: some View {
        MuscleGroupList(
            muscleValues: allTimeSets,
            expandedSections: $expandedSections
        )
    }
}
