import SwiftUI

struct PersonalView: View {
    @StateObject private var volumeGoals = VolumeGoals()
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
                    GoalsContent(volumeGoals: volumeGoals)
                }
            }
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
    // MARK: - Properties
    @ObservedObject var volumeGoals: VolumeGoals
    @State private var expandedSections: Set<String> = Set(MuscleCategories.order)
    @State private var editingMuscle: MuscleIdentifier?
    @State private var tempValue = ""
    
    // MARK: - Body
    var body: some View {
        ZStack {
            muscleGroupList
            
            if editingMuscle != nil {
                overlayView
                if let muscle = editingMuscle?.name {
                    inputModal(for: muscle)
                }
            }
        }
    }
    
    // MARK: - Subviews
    private var muscleGroupList: some View {
        MuscleGroupList(
            muscleValues: volumeGoals.goals,
            expandedSections: $expandedSections,
            onMuscleSelected: handleMuscleSelection
        )
    }
    
    private var overlayView: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
                editingMuscle = nil
            }
    }
    
    private func inputModal(for muscle: String) -> some View {
        VStack(spacing: 16) {
            Text("Target \(muscle == "Cardio" ? "Sessions" : "Sets") Per Week")
                .font(.headline)
            
            TextField("Enter target", text: $tempValue)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 100)
            
            saveButton(for: muscle)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(maxWidth: 300)
        .padding(.horizontal, 20)
        .transition(.scale)
    }
    
    private func saveButton(for muscle: String) -> some View {
        Button("Save") {
            saveValue(for: muscle)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    private func handleMuscleSelection(_ muscle: String) {
        tempValue = "\(volumeGoals.goals[muscle] ?? 0)"
        editingMuscle = MuscleIdentifier(name: muscle)
    }
    
    private func saveValue(for muscle: String) {
        if let value = Int(tempValue) {
            volumeGoals.updateGoal(for: muscle, value: value)
        }
        editingMuscle = nil
    }
}

// MARK: - Preview
#Preview {
    PersonalView()
} 