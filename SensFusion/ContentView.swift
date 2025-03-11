import SwiftUI
import Combine

// A publisher that emits the keyboard height when it appears or disappears.
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return frame.height
                }
                return 0
            }
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

struct ContentView: View {
    @EnvironmentObject var userData: UserData

    @State private var email = ""
    @State private var password = ""
    @State private var isLoginActive = false
    @State private var isSignUpActive = false
    @State private var loginErrorMessage = ""
    @State private var showLoginErrorAlert = false
    
    // This state variable will track the current keyboard height.
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        NavigationView {
            ZStack {
                // Background image from Assets (file name "1.png")
                Image("1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
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
                    
                    // Buttons
                    HStack(spacing: 20) {
                        // Login Button
                        Button(action: {
                            if email == userData.registeredEmail &&
                               password == userData.registeredPassword &&
                               !email.isEmpty &&
                               !password.isEmpty {
                                isLoginActive = true
                            } else {
                                loginErrorMessage = "Invalid credentials. Please check your email and password."
                                showLoginErrorAlert = true
                            }
                        }) {
                            Text("Login")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .alert(isPresented: $showLoginErrorAlert) {
                            Alert(title: Text("Login Error"),
                                  message: Text(loginErrorMessage),
                                  dismissButton: .default(Text("OK")))
                        }
                        
                        // SignUp Button
                        Button(action: {
                            isSignUpActive = true
                        }) {
                            Text("SignUp")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: HomeView(), isActive: $isLoginActive) {
                        EmptyView()
                    }
                    
                    NavigationLink(destination: RegistrationView(), isActive: $isSignUpActive) {
                        EmptyView()
                    }
                    
                    Spacer()
                }
                // Apply a counter offset equal to the keyboard height.
                .offset(y: keyboardHeight)
                // Animate the offset change.
                .animation(.easeOut(duration: 0.16), value: keyboardHeight)
            }
            .navigationTitle("Login")
        }
        // Listen for keyboard height changes and update our state.
        .onReceive(Publishers.keyboardHeight) { height in
            // When the keyboard appears, system usually shifts the content up by "height".
            // We add the same amount as a positive offset to push it back down.
            self.keyboardHeight = height
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
