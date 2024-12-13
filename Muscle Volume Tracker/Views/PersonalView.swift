import SwiftUI

struct PersonalView: View {
    @EnvironmentObject private var volumeGoals: VolumeGoals
    @State private var showingGoals = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    GoalsButton(showingGoals: $showingGoals)
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

#Preview {
    PersonalView()
        .environmentObject(WorkoutHistory())
        .environmentObject(VolumeGoals())
} 