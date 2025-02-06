import SwiftUI

struct PersonalView: View {
    @EnvironmentObject private var volumeGoals: VolumeGoals
    @State private var showingGoals = false
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                titleHeader
                mainList
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            goalsOverlay
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorSelectionView(selectedColor: colorBinding)
        }
        .onDisappear {
            showingGoals = false
        }
    }
    
    // MARK: - Subviews
    
    private var titleHeader: some View {
        Text("Personal")
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.bottom, 8)
            .padding(.horizontal, 20)
            .background(Color(.systemGroupedBackground))
    }
    
    private var mainList: some View {
        List {
            // Goals Section
            Section {
                GoalsButton(showingGoals: $showingGoals)
            }
            
            // Goal Appearance Section
            Section("Appearance") {
                // Goal Color Toggle
                Toggle(isOn: customColorBinding) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Goal Achieved Colour")
                        Text("Muscle colour changes when goal is reached")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .toggleStyle(BlueToggleStyle())
                
                if volumeGoals.useCustomGoalColor {
                    Button {
                        showingColorPicker = true
                    } label: {
                        HStack {
                            Text("Select Colour")
                                .foregroundColor(.primary)
                            Spacer()
                            Circle()
                                .fill(volumeGoals.goalAchievedColor)
                                .frame(width: 24, height: 24)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
            }
            
            // Display Settings Section
            Section {
                Toggle("Hide Cardio", isOn: hideCardioBinding)
                    .toggleStyle(BlueToggleStyle())
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var goalsOverlay: some View {
        Group {
            if showingGoals {
                ModalView(title: "Volume Goals", isPresented: $showingGoals) {
                    GoalsContent()
                }
            }
        }
    }
    
    // MARK: - Bindings
    
    private var customColorBinding: Binding<Bool> {
        Binding(
            get: { volumeGoals.useCustomGoalColor },
            set: { volumeGoals.toggleCustomColor($0) }
        )
    }
    
    private var colorBinding: Binding<Color> {
        Binding(
            get: { volumeGoals.goalAchievedColor },
            set: { volumeGoals.updateGoalColor($0) }
        )
    }
    
    private var hideCardioBinding: Binding<Bool> {
        Binding(
            get: { volumeGoals.hideCardio },
            set: { volumeGoals.toggleHideCardio($0) }
        )
    }
}

// MARK: - Supporting Views
private struct GoalsButton: View {
    @Binding var showingGoals: Bool
    
    var body: some View {
        Button {
            showingGoals = true
        } label: {
            HStack {
                Label("Goals", systemImage: "target")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
    }
}

struct GoalsContent: View {
    @EnvironmentObject var volumeGoals: VolumeGoals
    @State private var expandedSections = Set(MuscleCategories.order)
    @State private var editingMuscle: MuscleIdentifier?
    @State private var tempValue = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Change your weekly volume goals")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .padding(.top, 8)
            
            MuscleGroupList(
                muscleValues: volumeGoals.goals,
                expandedSections: $expandedSections,
                onMuscleSelected: handleMuscleSelection,
                showEditArrows: true
            )
        }
        .sheet(item: $editingMuscle) { muscle in
            pickerView(for: muscle.name)
        }
        .onDisappear {
            editingMuscle = nil
        }
    }
    
    private func pickerView(for muscle: String) -> some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(muscle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                
                Picker("Target \(muscle == "Cardio" ? "Sessions" : "Sets")", selection: $tempValue) {
                    ForEach(0...50, id: \.self) { value in
                        Text("\(value)").tag("\(value)")
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: tempValue) { _, newValue in
                    if let value = Int(newValue) {
                        volumeGoals.updateGoal(for: muscle, value: value)
                    }
                }
                
                Text("Muscle will turn gold when this target is reached")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .navigationTitle("Target \(muscle == "Cardio" ? "Sessions" : "Sets")")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
    }
    
    private func handleMuscleSelection(_ muscle: String) {
        tempValue = "\(volumeGoals.goals[muscle] ?? 0)"
        editingMuscle = MuscleIdentifier(name: muscle)
    }
}

// Add this custom toggle style near the bottom of the file
private struct BlueToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? .blue : Color(.systemGray5))
                .frame(width: 51, height: 31)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(2)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(), value: configuration.isOn)
                )
                .cornerRadius(20)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isOn.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}

// Add this color selection view
private struct ColorSelectionView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    
    private let colors: [(String, Color)] = [
        ("Gold", Color(red: 1.0, green: 0.84, blue: 0.0)),
        ("Pink", Color(red: 1.0, green: 0.71, blue: 0.76)),  // Soft pink
        ("Red", .red),
        ("Orange", .orange),
        ("Green", .green),
        ("Indigo", Color(red: 0.294, green: 0.0, blue: 0.509)),
        ("Violet", .purple)
    ]
    
    var body: some View {
        NavigationView {
            List {
                Text("Muscle colour changes when goal is reached")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Section {
                    ForEach(colors, id: \.0) { name, color in
                        Button {
                            withAnimation {
                                selectedColor = color
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Text(name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Circle()
                                    .fill(color)
                                    .frame(width: 24, height: 24)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
            }
            .navigationTitle("Select Muscle Goal Colour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PersonalView()
        .environmentObject(WorkoutHistory())
        .environmentObject(VolumeGoals())
} 