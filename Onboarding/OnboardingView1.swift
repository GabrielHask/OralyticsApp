import SwiftUI

struct OnboardingView1: View {
    @EnvironmentObject var globalContent: GlobalContent // Access GlobalContent

    let questions: [Question] = [
        Question(id: 1, text: "Select Your Biological Gender", options: ["Male", "Female"]),
        Question(id: 2, text: "Select your Dental Goals", options: [ "Increase Whiteness", "Reduce Cavities", "Improve Gum Health", "Improve Teeth Structure", "Fresher Breath", "Improve Dental Routine"], allowsMultipleSelection: true),
    ]




    @State private var currentStep: Int = 1
    @State private var answers: [Int: Any] = [:]
    @Namespace private var animation
    @State private var navigateToTargetPhysique = false // State for navigation
    @State private var navigateToOnboardingView2 = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress bar and back button
                HStack(alignment: .center, spacing: 10) {
                    if currentStep > 1 {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(.leading, 10)
                        }
                    }
                    StepProgressBar1(currentStep: currentStep, totalSteps: questions.count)
                        .frame(maxWidth: .infinity, maxHeight: 6) // Prominent height
                }
                .padding([.leading, .trailing, .top])


                if currentStep <= questions.count {
                    let question = questions[currentStep - 1]

                    VStack(spacing: 30) {
                        Text(question.text)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        if question.allowsMultipleSelection {
                            MultiSelectQuestionView1(
                                question: question,
                                selectedOptions: Binding(
                                    get: { answers[question.id] as? Set<String> ?? Set<String>() },
                                    set: { answers[question.id] = $0 }
                                ),
                                onContinue: {
                                    withAnimation {
                                        currentStep += 1
                                    }
                                }
                            )
                            .transition(.move(edge: .trailing))
                        } else {
                            QuestionView1(
                                question: question,
                                onSelectOption: { selectedOption in
                                    withAnimation {
                                        answers[question.id] = selectedOption
                                        currentStep += 1
                                    }
                                    
                                    // Store selected gender to UserDefaults if it's Question 1
                                    if question.id == 1 {
                                        UserDefaults.standard.set(selectedOption, forKey: "selectedGender")
                                    }
                                },
                                selectedOptions: Binding(
                                    get: { answers[question.id] as? String },
                                    set: { answers[question.id] = $0 }
                                )
                            )
                            .transition(.move(edge: .trailing))
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // Hidden NavigationLink to TargetPhysiqueView
                NavigationLink(
                    destination: OnboardingView2().navigationBarBackButtonHidden(true),
                    isActive: $navigateToOnboardingView2,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
                .navigationViewStyle(.stack)

            }
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Set background to black
            .animation(.easeInOut, value: currentStep)
            .onChange(of: currentStep) { newStep in
                if newStep > questions.count {
                    navigateToOnboardingView2 = true
                }
            }
        }
        .navigationViewStyle(.stack)

    }
}

// Rest of your views (StepProgressBar1, MultiSelectQuestionView1, QuestionView1, etc.)

// Updated StepProgressBar with prominent white bar and rounded edges
struct StepProgressBar1: View {
    var currentStep: Int
    var totalSteps: Int

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let stepWidth = totalWidth / CGFloat(totalSteps)
            
            HStack(spacing: 0) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Rectangle()
                        .frame(width: stepWidth, height: 6)
                        .foregroundColor(step <= currentStep ? Color.white : Color.gray.opacity(0.3))
                        .cornerRadius(3) // Rounded edges for progress bar
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 6)
        }
        .frame(height: 6)
        .padding(.horizontal, 10)
    }
}
struct HapticFeedback {
    static func triggerFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func triggerSelectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}


struct MultiSelectQuestionView1: View {
    var question: Question
    @Binding var selectedOptions: Set<String>
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }
                    
                    // Trigger haptic feedback on selection change
                    HapticFeedback.triggerSelectionChanged()
                }) {
                    HStack {
                        Text(option)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedOptions.contains(option) ? .black : .white)
                        Spacer()
                        if selectedOptions.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .transition(.scale)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedOptions.contains(option) ? Color.white : Color.white.opacity(0.1))
                            .shadow(color: Color.black.opacity(0.1), radius: selectedOptions.contains(option) ? 4 : 2, x: 0, y: selectedOptions.contains(option) ? 4 : 2)
                    )
                    .scaleEffect(selectedOptions.contains(option) ? 1.02 : 1.0)
                    .opacity(selectedOptions.contains(option) ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.2), value: selectedOptions)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: {
                // Trigger haptic feedback on continue
                HapticFeedback.triggerFeedback(style: .light)
                onContinue()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedOptions.isEmpty ? Color.white.opacity(0.3) : Color.white)
                            .shadow(color: selectedOptions.isEmpty ? Color.clear : Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            .disabled(selectedOptions.isEmpty)
            .opacity(selectedOptions.isEmpty ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selectedOptions)
        }
        .padding(.horizontal, 20)
    }
}




// Updated QuestionView with modern button styling and black and white theme


struct QuestionView1: View {
    var question: Question
    var onSelectOption: (String) -> Void
    @Binding var selectedOptions: String?

    var body: some View {
        VStack(spacing: 20) {
            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    // Update selected option visually
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedOptions = option
                    }
                    
                    // Trigger haptic feedback on selection
                    HapticFeedback.triggerFeedback(style: .light)
                    
                    // Move to next question after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onSelectOption(option)
                    }
                }) {
                    Text(option)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(selectedOptions == option ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedOptions == option ? Color.white : Color.white.opacity(0.1))
                                .shadow(color: Color.black.opacity(0.1), radius: selectedOptions == option ? 4 : 2, x: 0, y: selectedOptions == option ? 4 : 2)
                        )
                        .scaleEffect(selectedOptions == option ? 1.05 : 1.0)
                        .opacity(selectedOptions == option ? 1.0 : 0.9)
                        .animation(.easeInOut(duration: 0.2), value: selectedOptions)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}











// Example TargetPhysiqueView

