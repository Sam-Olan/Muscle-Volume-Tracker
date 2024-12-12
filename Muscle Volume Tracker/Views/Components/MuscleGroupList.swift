import SwiftUI

struct MuscleGroupList: View {
    let muscleValues: [String: Int]
    @Binding var expandedSections: Set<String>
    var onMuscleSelected: ((String) -> Void)?
    
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
                                HStack {
                                    Text(muscle)
                                    Spacer()
                                    Text("\(category == "Cardio" ? "Sessions" : "Sets"): \(muscleValues[muscle, default: 0])")
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 2)
                                }
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