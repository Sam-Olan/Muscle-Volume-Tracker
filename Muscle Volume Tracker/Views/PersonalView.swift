import SwiftUI

struct PersonalView: View {
    @EnvironmentObject private var volumeGoals: VolumeGoals
    @State private var showingGoals = false
    @State private var showingColorPicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    GoalsButton(showingGoals: $showingGoals)
                }
                Section("Appearance") {
                    VStack(alignment: .leading, spacing: 4) {
                        Toggle("Goal Achieved Colour", isOn: Binding(
                            get: { volumeGoals.useCustomGoalColor },
                            set: { volumeGoals.toggleCustomColor($0) }
                        ))
                        .toggleStyle(BlueToggleStyle())
                        
                        Text("Muscle colour changes when goal is reached")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 4)
                    }
                    
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
                    
                    Toggle("Hide Cardio", isOn: Binding(
                        get: { volumeGoals.hideCardio },
                        set: { volumeGoals.toggleHideCardio($0) }
                    ))
                    .toggleStyle(BlueToggleStyle())
                }
            }
            .navigationTitle("Personal")
            .listStyle(.insetGrouped)
        }
        .overlay {
            if showingGoals {
                ModalView(title: "Volume Goals", isPresented: $showingGoals) {
                    GoalsContent()
                }
            }
        }
        .onDisappear {
            showingGoals = false
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorSelectionView(selectedColor: Binding(
                get: { volumeGoals.goalAchievedColor },
                set: { volumeGoals.updateGoalColor($0) }
            ))
            .transition(.move(edge: .bottom))
        }
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
    }
}

// Add this color selection view
private struct ColorSelectionView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    
    private let colors: [(String, Color)] = [
        ("Gold", Color(red: 1.0, green: 0.84, blue: 0.0)),
        ("Red", .red),
        ("Orange", .orange),
        ("Green", .green),
        ("Blue", .blue),
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