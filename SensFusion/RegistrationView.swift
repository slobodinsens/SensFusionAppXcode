import SwiftUI
import Combine

// Remove the following extension if it’s already defined in your project.
// extension Publishers {
//     static var keyboardHeight: AnyPublisher<CGFloat, Never> {
//         let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//             .map { notification -> CGFloat in
//                 if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                     return frame.height
//                 }
//                 return 0
//             }
//         let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//             .map { _ in CGFloat(0) }
//         return MergeMany(willShow, willHide)
//             .eraseToAnyPublisher()
//     }
// }

struct RegistrationView: View {
    @EnvironmentObject var userData: UserData

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var registrationComplete = false

    // This state variable tracks the current keyboard height.
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack {
                // Background image from Assets (file name "2.png")
                Image("2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Registration Page")
                        .font(.title)
                        .padding()
                    
                    // Email Field
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Register Button
                    Button(action: {
                        // Save registration data in the shared model.
                        userData.registeredEmail = email
                        userData.registeredPassword = password
                        registrationComplete = true
                        // Dismiss the keyboard.
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    if registrationComplete {
                        Text("Registration complete!")
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                // Apply an offset: a fixed upward shift of 30 points, plus a dynamic offset
                // that leaves a 50-point gap between the form and the keyboard.
                .offset(y: -30 + max(keyboardHeight - 50, 0))
                .animation(.easeOut(duration: 0.16), value: keyboardHeight)
            }
            .navigationTitle("Register")
        }
        // Listen for keyboard height changes and update our state.
        .onReceive(Publishers.keyboardHeight) { height in
            self.keyboardHeight = height
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView().environmentObject(UserData())
    }
}
