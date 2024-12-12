import SwiftUI

struct MuscleGroupList: View {
    let muscleValues: [String: Int]
    @Binding var expandedSections: Set<String>
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach(MuscleCategories.order, id: \.self) { category in
                        if let muscles = MuscleCategories.categories[category] {
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedSections.contains(category) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedSections.insert(category)
                                            if category == "Misc" {
                                                withAnimation {
                                                    proxy.scrollTo("bottom", anchor: .bottom)
                                                }
                                            }
                                        } else {
                                            expandedSections.remove(category)
                                        }
                                    }
                                )
                            ) {
                                ForEach(muscles, id: \.self) { muscle in
                                    HStack {
                                        Text(muscle)
                                        Spacer()
                                        Text("Sets: \(muscleValues[muscle, default: 0])")
                                    }
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 2)
                                }
                            } label: {
                                CategoryHeader(category: category, isExpanded: expandedSections.contains(category))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + ViewConstants.scrollIndicatorDelay) {
                    withAnimation(.easeInOut(duration: ViewConstants.scrollIndicatorDuration)) {}
                }
            }
        }
    }
}

private struct CategoryHeader: View {
    let category: String
    let isExpanded: Bool
    
    var body: some View {
        HStack {
            Text(category)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .foregroundColor(.blue)
                .font(.caption)
                .frame(width: 20)
        }
        .padding(.vertical, 4)
    }
} 