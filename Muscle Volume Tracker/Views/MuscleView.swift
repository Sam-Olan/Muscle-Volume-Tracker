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
    @EnvironmentObject private var volumeGoals: VolumeGoals
    @Environment(\.presentationMode) var presentationMode
    
    // Constants
    private let muscleCategories = MuscleCategories.categories
    private let categoryOrder = MuscleCategories.order
    
    // State
    @State private var startDate: Date = MuscleView.getInitialStartDate()
    @State private var expandedSections: Set<String> = ["Push", "Pull", "Legs", "Misc"]
    @State private var showingDatePicker = false
    @State private var editingMuscle: MuscleIdentifier? = nil
    @State private var tempValue: Int? = nil
    @State private var pulseAnimation = false
    @State private var isWeekLocked = true
    
    // Haptics
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
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
    
    private var isPastWeek: Bool {
        startDate < Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
    
    private func intensityColor(for sets: Int, muscle: String) -> Color {
        let maxSets = volumeGoals.getGoal(for: muscle)
        
        // Handle special cases for low goals
        if maxSets <= 1 {
            if sets >= maxSets {
                return volumeGoals.useCustomGoalColor ? volumeGoals.goalAchievedColor : .blue
            } else {
                return .blue.opacity(sets > 0 ? 1.0 : 0.0)
            }
        }
        
        // Normal case
        let intensity = min(Double(sets) / Double(maxSets - 1), 1.0)
        
        if sets >= maxSets {
            return volumeGoals.useCustomGoalColor ? volumeGoals.goalAchievedColor : .blue
        } else {
            return .blue.opacity(intensity)
        }
    }
    
    private var chestIntensity: Color {
        let sets = muscleValues["Chest"] ?? 0
        return intensityColor(for: sets, muscle: "Chest")
    }
    
    private var frontDeltIntensity: Color {
        let sets = muscleValues["Front Delts"] ?? 0
        return intensityColor(for: sets, muscle: "Front Delts")
    }
    
    private var latDeltIntensity: Color {
        let sets = muscleValues["Side Delts"] ?? 0
        return intensityColor(for: sets, muscle: "Side Delts")
    }
    
    private var tricepsIntensity: Color {
        let sets = muscleValues["Triceps"] ?? 0
        return intensityColor(for: sets, muscle: "Triceps")
    }
    
    private var latsIntensity: Color {
        let sets = muscleValues["Lats"] ?? 0
        return intensityColor(for: sets, muscle: "Lats")
    }
    
    private var bicepsIntensity: Color {
        let sets = muscleValues["Biceps"] ?? 0
        return intensityColor(for: sets, muscle: "Biceps")
    }
    
    private var coreIntensity: Color {
        let sets = muscleValues["Core"] ?? 0
        return intensityColor(for: sets, muscle: "Core")
    }
    
    private var quadsIntensity: Color {
        let sets = muscleValues["Quads"] ?? 0
        return intensityColor(for: sets, muscle: "Quads")
    }
    
    private var hamstringsIntensity: Color {
        let sets = muscleValues["Hamstrings"] ?? 0
        return intensityColor(for: sets, muscle: "Hamstrings")
    }
    
    private var calvesIntensity: Color {
        let sets = muscleValues["Calves"] ?? 0
        return intensityColor(for: sets, muscle: "Calves")
    }
    
    private var forearmIntensity: Color {
        let sets = muscleValues["Forearms"] ?? 0
        return intensityColor(for: sets, muscle: "Forearms")
    }
    
    private var glutesIntensity: Color {
        let sets = muscleValues["Glutes"] ?? 0
        return intensityColor(for: sets, muscle: "Glutes")
    }
    
    private var midBackIntensity: Color {
        let sets = muscleValues["Mid Back"] ?? 0
        return intensityColor(for: sets, muscle: "Mid Back")
    }
    
    private var rearDeltIntensity: Color {
        let sets = muscleValues["Rear Delts"] ?? 0
        return intensityColor(for: sets, muscle: "Rear Delts")
    }
    
    private var lowerBackIntensity: Color {
        let sets = muscleValues["Lower Back"] ?? 0
        return intensityColor(for: sets, muscle: "Lower Back")
    }
    
    private var cardioIntensity: Color {
        let sessions = muscleValues["Cardio"] ?? 0
        let maxSessions = volumeGoals.getGoal(for: "Cardio")
        
        // Always use red, but vary the opacity based on progress
        if sessions >= maxSessions {
            return .red // Full red when goal is met
        } else {
            let intensity = min(Double(sessions) / Double(maxSessions), 1.0)
            return .red.opacity(intensity)
        }
    }
    
    // MARK: - Methods
    private func saveCurrentWeek(updatedValues: [String: Int]) {
        let week = WorkoutWeek(startDate: startDate, muscleValues: updatedValues)
        workoutHistory.addWeek(week)
    }
    
    private func incrementMuscleValue(_ muscle: String) {
        // Don't allow changes if week is locked
        guard !isPastWeek || !isWeekLocked else { return }
        
        var newValues = muscleValues
        let currentValue = newValues[muscle, default: 0]
        newValues[muscle] = currentValue + 1
        
        // Get the goal value
        let goalValue = volumeGoals.getGoal(for: muscle)
        
        // Determine if this increment reaches the goal
        if currentValue + 1 == goalValue {
            // Strong double haptic for reaching goal
            let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
            let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
            
            heavyHaptic.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                mediumHaptic.impactOccurred(intensity: 0.8)
            }
        } else {
            // Light haptic for normal increment
            lightHaptic.impactOccurred()
        }
        
        saveCurrentWeek(updatedValues: newValues)
    }
    
    private func updateMuscleValue(_ muscle: String, value: Int) {
        // Don't allow changes if week is locked
        guard !isPastWeek || !isWeekLocked else { return }
        
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
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
                .foregroundColor(isPastWeek && isWeekLocked ? .gray.opacity(0.5) : .gray)
                .padding(.leading, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .opacity(isPastWeek && isWeekLocked ? 0.7 : 1)
        .onTapGesture {
            if !isPastWeek || !isWeekLocked {
                tempValue = nil
                editingMuscle = MuscleIdentifier(name: muscle)
            }
        }
    }
    
    private func incrementButton(for muscle: String) -> some View {
        Button {
            incrementMuscleValue(muscle)
        } label: {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(isPastWeek && isWeekLocked ? .gray : .blue)
                .font(.title2)
        }
        .disabled(isPastWeek && isWeekLocked)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    // Base background
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    // Heart layers at the top
                    ZStack {
                        if !volumeGoals.hideCardio {
                            // Heart fill that changes color
                            Image("HeartFill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 60)
                                .colorMultiply(cardioIntensity)
                                .shadow(color: cardioIntensity, radius: pulseAnimation ? 10 : 0)
                                .animation(.easeInOut(duration: 0.3), value: cardioIntensity)
                                .animation(.easeInOut(duration: 0.3), value: pulseAnimation)
                                .onAppear {
                                    if (muscleValues["Cardio"] ?? 0) >= volumeGoals.getGoal(for: "Cardio") {
                                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                            pulseAnimation = true
                                        }
                                    }
                                }
                                .onChange(of: muscleValues["Cardio"]) { _, newValue in
                                    if (newValue ?? 0) >= volumeGoals.getGoal(for: "Cardio") {
                                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                            pulseAnimation = true
                                        }
                                    }
                                }
                            
                            // Heart outline on top
                            Image("HeartOutline")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 60)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !volumeGoals.hideCardio {
                            tempValue = muscleValues["Cardio", default: 0]
                            editingMuscle = MuscleIdentifier(name: "Cardio")
                        }
                    }
                    .frame(width: 60, height: 60)
                    .padding(.leading, 25)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: -155)
                    .zIndex(1)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Cardio sessions")
                    .accessibilityValue("\(muscleValues["Cardio", default: 0]) sessions")
                    .accessibilityAddTraits(.isButton)
                    
                    // Muscle images
                    Group {
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
                    .frame(width: geometry.size.width)
                }
                .frame(height: 350)
                
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
                        
                        if !volumeGoals.hideCardio {
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
                                            .foregroundColor(isPastWeek && isWeekLocked ? .gray.opacity(0.5) : .gray)
                                            .padding(.leading, 2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .opacity(isPastWeek && isWeekLocked ? 0.7 : 1)
                                    .onTapGesture {
                                        if !isPastWeek || !isWeekLocked {
                                            tempValue = muscleValues["Cardio", default: 0]
                                            editingMuscle = MuscleIdentifier(name: "Cardio")
                                        }
                                    }
                                    
                                    Button {
                                        incrementMuscleValue("Cardio")
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(isPastWeek && isWeekLocked ? .gray : .blue)
                                            .font(.title2)
                                    }
                                    .disabled(isPastWeek && isWeekLocked)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top, 8)
                        }
                        
                        // Add bottom padding to ensure cardio is visible
                        Color.clear.frame(height: 100)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $editingMuscle) { muscle in
            setsPickerSheet(for: muscle.name)
                .transition(.move(edge: .bottom))
        }
        .sheet(isPresented: $showingDatePicker) {
            weekPickerSheet
                .transition(.move(edge: .bottom))
        }
        .onDisappear {
            editingMuscle = nil
            showingDatePicker = false
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
            
            // Add lock icon for past weeks
            if isPastWeek {
                Button {
                    withAnimation(.spring()) {
                        isWeekLocked.toggle()
                    }
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                } label: {
                    Image(systemName: isWeekLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: ViewConstants.lockIconSize))
                        .foregroundColor(.gray)
                }
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
            moveToWeek(direction: direction)
        } label: {
            Image(systemName: direction.image)
                .foregroundColor(.blue)
                .font(.title3)
                .padding(direction.padding, 25)
        }
    }
    
    func setsPickerSheet(for muscle: String) -> some View {
        NavigationView {
            VStack(spacing: 8) {
                if isPastWeek && isWeekLocked {
                    Text("Unlock week to make changes")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                Text(muscle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Picker(muscle == "Cardio" ? "Sessions" : "Sets", selection: $tempValue) {
                    ForEach(0...99, id: \.self) { value in
                        Text("\(value)").tag(Optional(value))
                    }
                }
                .pickerStyle(.wheel)
                .disabled(isPastWeek && isWeekLocked)
                .onChange(of: tempValue) { _, newValue in
                    if let value = newValue {
                        updateMuscleValue(muscle, value: value)
                    }
                }
            }
            .navigationTitle(muscle == "Cardio" ? "Select Sessions" : "Select Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        editingMuscle = nil
                    }
                }
            }
            .onAppear {
                tempValue = muscleValues[muscle, default: 0]
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
                        // Lock the week if it's in the past
                        if isPastWeek {
                            isWeekLocked = true
                        }
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
    
    private static func getInitialStartDate() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 1  // 1 = Sunday
        return calendar.date(from: components) ?? Date()
    }
    
    private func moveToWeek(direction: NavigationDirection) {
        let calendar = Calendar.current
        
        // Get the current week's Sunday
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startDate)
        components.weekday = 1  // 1 = Sunday
        
        // Adjust the week
        if direction == .forward {
            components.weekOfYear! += 1
        } else {
            components.weekOfYear! -= 1
        }
        
        // Get the new date for Sunday of that week
        if let newDate = calendar.date(from: components) {
            startDate = newDate
            // Lock the week if it's in the past
            if isPastWeek {
                isWeekLocked = true
            }
        }
    }
}


