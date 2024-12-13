import SwiftUI

struct MuscleGroupList: View {
    let muscleValues: [String: Int]
    @Binding var expandedSections: Set<String>
    var onMuscleSelected: ((String) -> Void)?
    var showEditArrows: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(MuscleCategories.order, id: \.self) { category in
                if let muscles = MuscleCategories.categories[category] {
                    VStack(alignment: .leading, spacing: 10) {
                        if category != "Cardio" {
                            Button {
                                if expandedSections.contains(category) {
                                    expandedSections.remove(category)
                                } else {
                                    expandedSections.insert(category)
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(category)
                                        .font(.headline)
                                    Image(systemName: expandedSections.contains(category) ? "chevron.down" : "chevron.right")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Spacer()
                                }
                                .foregroundColor(.primary)
                            }
                        } else {
                            Text(category)
                                .font(.headline)
                        }
                        
                        if category == "Cardio" || expandedSections.contains(category) {
                            ForEach(muscles, id: \.self) { muscle in
                                HStack(spacing: 10) {
                                    HStack {
                                        Text(muscle)
                                        Spacer()
                                        Text("\(category == "Cardio" ? "Sessions" : "Sets"): \(muscleValues[muscle, default: 0])")
                                        if showEditArrows {
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        onMuscleSelected?(muscle)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} 