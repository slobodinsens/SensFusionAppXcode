import SwiftUI
import Combine

// Keyboard height publisher extension
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
                        // Login Button with server logic.
                        Button(action: {
                            Task {
                                let success = await loginUser(email: email, password: password)
                                if success {
                                    isLoginActive = true
                                } else {
                                    loginErrorMessage = "Invalid credentials. Please check your email and password."
                                    showLoginErrorAlert = true
                                }
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
                        
                        // SignUp Button navigates to the registration screen.
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
            self.keyboardHeight = height
        }
    }
    
    // Function to send login request to server.
    func loginUser(email: String, password: String) async -> Bool {
        guard let url = URL(string: "https://example.com/api/login") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let payload = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool {
                return success
            }
            return false
        } catch {
            print("Login error: \(error)")
            return false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
