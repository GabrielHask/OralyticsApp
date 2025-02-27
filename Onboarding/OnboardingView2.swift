import SwiftUI

struct OnboardingView2: View {
    @EnvironmentObject var globalContent: GlobalContent // Access GlobalContent

    let questions: [Question] = [
        Question(id: 1, text: "How many times do you brush your teeth in a day", options: ["1", "2", "3", "4+"]),
        Question(id: 2, text: "How many times do you floss in a day", options: ["1", "2", "3", "4+"]),
        Question(id: 2, text: "Do you have any of the following", options: ["Braces", "Crowns", "Implants", "None"], allowsMultipleSelection: true),
        Question(id: 4, text: "Do you experience any of the following issues", options: ["Sensitivity", "Gum Bleeding", "Cavities", "Bad Breath", "None"], allowsMultipleSelection: true),
        
        // Updated text
    ]

    @State private var currentStep: Int = 1
    
    @State private var answers: [Int: Any] = [:]
    
    
    @Namespace private var animation
    
    
    @State private var navigateToTargetPhysique = false
    
    @State private var navigateToWeightInput = false
    
    
    
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
                        .frame(maxWidth: .infinity, maxHeight: 6)
                }
                .padding([.leading, .trailing, .top])

                
                
                // Navigate to WorkoutDaysView at question 2
                
                
                
                // Navigate to WeightInputView1 at question 5
                
                
                
//                else if currentStep == 5 {
//                    WeightInputView2(currentStep: $currentStep)
//                    
//                     Pass currentStep as binding
//                        .transition(.move(edge: .trailing))
//                }
                
                
                // Display other questions
                
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
                    destination: WorkoutProgramView().navigationBarBackButtonHidden(true),
                    isActive: $navigateToTargetPhysique,
                    label: {
                        EmptyView()
                    }
                )
                .navigationViewStyle(.stack)
                .hidden()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .animation(.easeInOut, value: currentStep)
            .onChange(of: currentStep) { newStep in
                if newStep > questions.count {
                    navigateToTargetPhysique = true
                }
            }
        }
        .navigationViewStyle(.stack)

    }
}
