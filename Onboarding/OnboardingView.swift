import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var globalContent: GlobalContent // Access GlobalContent
    
    let questions: [Question] = [
        Question(id: 1, text: "Set your Fitness Goal", options: ["Lose Weight", "Gain Weight", "Maintain Weight", "Don't Know"]),
        Question(id: 2, text: "What is your target physique?", options: []), // Physique selection step
        Question(id: 3, text: "Which body parts are you targeting?", options: []),
        Question(id: 4, text: "Question 4?", options: ["Option 1", "Option 2"]),
        Question(id: 5, text: "Question 5?", options: ["Option 1", "Option 2"]),
        Question(id: 6, text: "Question 6?", options: ["Option 1", "Option 2"]),
        Question(id: 7, text: "Question 7?", options: ["Option 1", "Option 2"]),
        Question(id: 8, text: "Question 8?", options: ["Option 1", "Option 2"]),
        Question(id: 9, text: "Question 9", options: []),
        Question(id: 10, text: "Question 15?", options: ["Option 1", "Option 2"]),
        Question(id: 11, text: "How do you cope with stress?", subtext: "These can be positive or negative", options: ["Exercising", "Meditation", "Eating Comfort Food", "Talking to Friends", "Drinking Alcohol", "Other"], allowsMultipleSelection: true),
        Question(id: 12, text: "How many hours of sleep do you get on average?", options: ["Fewer than 5 hours", "Between 5 and 6 hours", "Between 7 and 8 hours", "Over 8 hours"]),
        Question(id: 13, text: "Question 12?", options: ["Option 1", "Option 2"]),
        Question(id: 14, text: "Question 13?", options: ["Option 1", "Option 2"]),
        Question(id: 15, text: "Question 14?", options: ["Option 1", "Option 2"])
        
    ]
    
    @State private var currentStep: Int = 1
    @State private var answers: [Int: Any] = [:] // Updated to Any to handle different types
    @Namespace private var animation
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 10) {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation {
                            currentStep -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                }
                
                StepProgressBar(currentStep: currentStep)
                    .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing, .top])
            
            Divider()
            
            // Handle different steps
        }
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}


struct MultiSelectQuestionView: View {
    let question: Question
    @Binding var selectedOptions: Set<String>
    var onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Question Text
            Text(question.text)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Subtext if available
            if let subtext = question.subtext {
                Text(subtext)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Options
            VStack(spacing: 15) {
                ForEach(question.options, id: \.self) { option in
                    MultipleOptionButton(
                        text: option,
                        isSelected: selectedOptions.contains(option)
                    )
                    .onTapGesture {
                        withAnimation {
                            toggleSelection(option: option)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Continue Button
            Button(action: {
                onContinue()
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedOptions.isEmpty ? Color.gray : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(selectedOptions.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    // Function to toggle selection for multiple options
    private func toggleSelection(option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}

struct QuestionView: View {
    let question: Question
    var onSelectOption: (Any) -> Void
    @Binding var selectedOptions: Any
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Question Text
                Text(question.text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                // Subtext if available
                if let subtext = question.subtext {
                    Text(subtext)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                // Options
                VStack(spacing: 15) {
                    if question.allowsMultipleSelection {
                        // Multiple Selection (Checkboxes)
                        ForEach(question.options, id: \.self) { option in
                            MultipleOptionButton(
                                text: option,
                                isSelected: (selectedOptions as? Set<String>)?.contains(option) ?? false
                            )
                            .onTapGesture {
                                withAnimation {
                                    toggleSelection(option: option)
                                }
                            }
                        }
                    } else {
                        // Single Selection (Radio Buttons)
                        ForEach(question.options, id: \.self) { option in
                            OptionButton(
                                text: option,
                                isSelected: (selectedOptions as? String) == option
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedOptions = option
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        onSelectOption(option)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
    
    // Function to toggle selection for multiple options
    private func toggleSelection(option: String) {
        if var selectedSet = selectedOptions as? Set<String> {
            if selectedSet.contains(option) {
                selectedSet.remove(option)
            } else {
                selectedSet.insert(option)
            }
            selectedOptions = selectedSet
            onSelectOption(selectedSet)
        }
    }
}



struct MultipleOptionButton: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? Color.accentColor : Color.gray)
                .font(.title2)
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.1), radius: 5, x: 0, y: 3)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}


struct OptionButton: View {
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.1), radius: 5, x: 0, y: 3)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}


struct StepProgressBar: View {
    var currentStep: Int
    let totalSteps = 15
    let majorSteps = [5, 10, 15]
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let stepWidth = (totalWidth - CGFloat(majorSteps.count * 12)) / CGFloat(totalSteps - majorSteps.count)
            
            HStack(spacing: 0) {
                ForEach(1...totalSteps, id: \.self) { step in
                    if majorSteps.contains(step) {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(step <= currentStep ? Color.black : Color.gray.opacity(0.3))
                            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 1))
                            .shadow(color: step <= currentStep ? Color.black.opacity(0.5) : Color.clear, radius: 2)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    } else {
                        Rectangle()
                            .frame(width: stepWidth, height: 2)
                            .foregroundColor(step <= currentStep ? Color.black : Color.gray.opacity(0.3))
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
            }
            .frame(height: 20)
        }
        .frame(height: 20)
        .padding(.horizontal, 10)
    }
}






struct Question: Identifiable {
    let id: Int
    let text: String
    let subtext: String?
    let options: [String]
    let allowsMultipleSelection: Bool
    
    init(id: Int, text: String, subtext: String? = nil, options: [String], allowsMultipleSelection: Bool = false) {
        self.id = id
        self.text = text
        self.subtext = subtext
        self.options = options
        self.allowsMultipleSelection = allowsMultipleSelection
    }
}
