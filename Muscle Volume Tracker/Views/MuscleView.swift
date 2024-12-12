//
//  MuscleView.swift
//  Muscle Volume Tracker
//
//  Created by Sam Olan on 2024-12-10.
//

import SwiftUI

struct MuscleView: View {
    // MARK: - Properties
    @EnvironmentObject private var workoutHistory: WorkoutHistory
    
    // Constants
    private let muscleCategories = MuscleCategories.categories
    private let categoryOrder = MuscleCategories.order
    
    // State
    @State private var startDate = Date()
    @State private var expandedSections: Set<String> = ["Push", "Pull", "Legs", "Misc"]
    @State private var showingDatePicker = false
    @State private var editingMuscle: MuscleIdentifier? = nil
    @State private var tempValue = 0
    
    // MARK: - Computed Properties
    private var muscleValues: [String: Int] {
        workoutHistory.weeks.first { 
            Calendar.current.isDate($0.startDate, equalTo: startDate, toGranularity: .weekOfYear) 
        }?.muscleValues ?? [:]
    }
    
    private var isCurrentWeek: Bool {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        return (startDate...endDate).contains(Date())
    }
    
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func intensityColor(for sets: Int, maxSets: Int = 12) -> Color {
        let intensity = min(Double(sets) / Double(maxSets), 1.0)
        
        if sets >= maxSets {
            // Gold color that gets darker with more sets
            return Color(red: 1.0, green: 0.84, blue: 0.0).opacity(min(0.3 + (intensity * 0.7), 1.0))
        } else {
            // Regular blue color
            return .blue.opacity(intensity)
        }
    }
    
    private var chestIntensity: Color {
        let sets = muscleValues["Chest"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var frontDeltIntensity: Color {
        let sets = muscleValues["Front Delts"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var latDeltIntensity: Color {
        let sets = muscleValues["Side Delts"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var tricepsIntensity: Color {
        let sets = muscleValues["Triceps"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var latsIntensity: Color {
        let sets = muscleValues["Lats"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var bicepsIntensity: Color {
        let sets = muscleValues["Biceps"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var coreIntensity: Color {
        let sets = muscleValues["Core"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var quadsIntensity: Color {
        let sets = muscleValues["Quads"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var hamstringsIntensity: Color {
        let sets = muscleValues["Hamstrings"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var calvesIntensity: Color {
        let sets = muscleValues["Calves"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var forearmIntensity: Color {
        let sets = muscleValues["Forearms"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var glutesIntensity: Color {
        let sets = muscleValues["Glutes"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var midBackIntensity: Color {
        let sets = muscleValues["Mid Back"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var rearDeltIntensity: Color {
        let sets = muscleValues["Rear Delts"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var lowerBackIntensity: Color {
        let sets = muscleValues["Lower Back"] ?? 0
        return intensityColor(for: sets)
    }
    
    private var cardioIntensity: Color {
        let sessions = muscleValues["Cardio"] ?? 0
        let intensity = min(Double(sessions) / 3.0, 1.0)
        
        if sessions >= 4 {
            // Gold color for 4 or more sessions
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        } else {
            // Red color scaling - making it fill faster by using intensity
            return .red.opacity(intensity)
        }
    }
    
    // MARK: - Methods
    private func saveCurrentWeek(updatedValues: [String: Int]) {
        let week = WorkoutWeek(startDate: startDate, muscleValues: updatedValues)
        workoutHistory.addWeek(week)
    }
    
    private func incrementMuscleValue(_ muscle: String) {
        var newValues = muscleValues
        newValues[muscle, default: 0] += 1
        saveCurrentWeek(updatedValues: newValues)
    }
    
    private func updateMuscleValue(_ muscle: String, value: Int) {
        var newValues = muscleValues
        newValues[muscle] = value
        saveCurrentWeek(updatedValues: newValues)
    }
    
    // MARK: - Views
    private func muscleSection(_ title: String, muscles: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title)
            
            if expandedSections.contains(title) {
                muscleList(muscles)
            }
        }
        .padding(.horizontal)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Button {
            if expandedSections.contains(title) {
                expandedSections.remove(title)
            } else {
                expandedSections.insert(title)
            }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                Image(systemName: expandedSections.contains(title) ? "chevron.down" : "chevron.right")
                    .foregroundColor(.blue)
                    .font(.caption)
                Spacer()
            }
            .foregroundColor(.primary)
        }
    }
    
    private func muscleList(_ muscles: [String]) -> some View {
        VStack(spacing: 8) {
            ForEach(muscles, id: \.self) { muscle in
                HStack(spacing: 10) {
                    muscleRow(muscle)
                    incrementButton(for: muscle)
                }
            }
        }
    }
    
    private func muscleRow(_ muscle: String) -> some View {
        HStack {
            Text(muscle)
            Spacer()
            Text("Sets: \(muscleValues[muscle, default: 0])")
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .onTapGesture {
            tempValue = muscleValues[muscle, default: 0]
            editingMuscle = MuscleIdentifier(name: muscle)
        }
    }
    
    private func incrementButton(for muscle: String) -> some View {
        Button {
            incrementMuscleValue(muscle)
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Heart layers at the top
                ZStack {
                    // Heart fill that changes color
                    Image("HeartFill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .colorMultiply(cardioIntensity)
                        .animation(.easeInOut(duration: 0.3), value: cardioIntensity)
                    
                    // Heart outline on top
                    Image("HeartOutline")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                }
                .padding(.leading, 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(y: -155)
                
                // Legs
                Image("Quads")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(quadsIntensity)
                    .animation(.easeInOut(duration: 0.3), value: quadsIntensity)
                
                Image("Hamstrings")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(hamstringsIntensity)
                    .animation(.easeInOut(duration: 0.3), value: hamstringsIntensity)
                
                Image("Calves")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(calvesIntensity)
                    .animation(.easeInOut(duration: 0.3), value: calvesIntensity)
                
                // Back
                Image("Lats")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(latsIntensity)
                    .animation(.easeInOut(duration: 0.3), value: latsIntensity)
                
                // Arms
                Image("Biceps")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(bicepsIntensity)
                    .animation(.easeInOut(duration: 0.3), value: bicepsIntensity)
                
                Image("Triceps")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(tricepsIntensity)
                    .animation(.easeInOut(duration: 0.3), value: tricepsIntensity)
                
                // Shoulders
                Image("Front Delts")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(frontDeltIntensity)
                    .animation(.easeInOut(duration: 0.3), value: frontDeltIntensity)
                
                Image("Side Delts")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(latDeltIntensity)
                    .animation(.easeInOut(duration: 0.3), value: latDeltIntensity)
                
                // Core and Upper Body
                Image("Core")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(coreIntensity)
                    .animation(.easeInOut(duration: 0.3), value: coreIntensity)
                
                Image("Chest")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(chestIntensity)
                    .animation(.easeInOut(duration: 0.3), value: chestIntensity)
                
                Image("Forearms")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(forearmIntensity)
                    .animation(.easeInOut(duration: 0.3), value: forearmIntensity)
                
                Image("Glutes")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(glutesIntensity)
                    .animation(.easeInOut(duration: 0.3), value: glutesIntensity)
                
                Image("Mid Back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(midBackIntensity)
                    .animation(.easeInOut(duration: 0.3), value: midBackIntensity)
                
                Image("Rear Delts")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(rearDeltIntensity)
                    .animation(.easeInOut(duration: 0.3), value: rearDeltIntensity)
                
                Image("Lower Back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
                    .colorMultiply(lowerBackIntensity)
                    .animation(.easeInOut(duration: 0.3), value: lowerBackIntensity)
                
                // Anatomy outline on top
                Image("Anatomy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 440, height: 350)
            }
            
            weekSelector
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sets Per Week")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    
                    ForEach(MuscleCategories.muscleViewCategories, id: \.self) { category in
                        if let muscles = muscleCategories[category] {
                            muscleSection(category, muscles: muscles)
                        }
                    }
                    
                    // Cardio section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cardio")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 10) {
                            HStack {
                                Text("Cardio")
                                Spacer()
                                Text("Sessions: \(muscleValues["Cardio", default: 0])")
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .onTapGesture {
                                tempValue = muscleValues["Cardio", default: 0]
                                editingMuscle = MuscleIdentifier(name: "Cardio")
                            }
                            
                            Button {
                                incrementMuscleValue("Cardio")
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
        }
        .sheet(item: $editingMuscle) { muscle in
            setsPickerSheet(for: muscle.name)
        }
    }
}

// MARK: - Helper Views
private extension MuscleView {
    var weekSelector: some View {
        HStack {
            weekNavigationButton(direction: .backward)
            Spacer()
            weekDisplay
            Spacer()
            if !isCurrentWeek {
                weekNavigationButton(direction: .forward)
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
                    .padding(.trailing, 25)
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingDatePicker) {
            weekPickerSheet
        }
    }
    
    var weekDisplay: some View {
        VStack(spacing: 4) {
            if isCurrentWeek {
                Text("Current Week")
                    .italic()
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(dateRangeText)
        }
        .frame(minWidth: 150)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onTapGesture {
            showingDatePicker = true
        }
    }
    
    enum NavigationDirection {
        case forward, backward
        
        var image: String {
            self == .forward ? "chevron.right" : "chevron.left"
        }
        
        var padding: Edge.Set {
            self == .forward ? .trailing : .leading
        }
    }
    
    func weekNavigationButton(direction: NavigationDirection) -> some View {
        Button {
            let value = direction == .forward ? 7 : -7
            startDate = Calendar.current.date(byAdding: .day, value: value, to: startDate)!
        } label: {
            Image(systemName: direction.image)
                .foregroundColor(.blue)
                .font(.title3)
                .padding(direction.padding, 25)
        }
    }
    
    func setsPickerSheet(for muscle: String) -> some View {
        NavigationView {
            VStack {
                Picker("Sets", selection: $tempValue) {
                    ForEach(0...99, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: tempValue) { _, newValue in
                    updateMuscleValue(muscle, value: newValue)
                }
            }
            .navigationTitle("Select Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        editingMuscle = nil as MuscleIdentifier?
                    }
                }
            }
        }
        .presentationDetents([.height(250)])
    }
    
    var weekPickerSheet: some View {
        NavigationView {
            CustomCalendarView(selectedDate: $startDate, maxDate: Date())
                .onChange(of: startDate) { _, newDate in
                    if let weekStart = Calendar.current.date(
                        from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: newDate)
                    ) {
                        startDate = weekStart
                    }
                }
                .navigationTitle("Select Week")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingDatePicker = false
                        }
                    }
                }
        }
        .presentationDetents([.medium])
    }
}

