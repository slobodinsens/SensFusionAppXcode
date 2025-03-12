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
    @State private var message = ""
    @State private var showMessageAlert = false
    
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
                            Task {
                                let success = await loginUser(email: email, password: password)
                                if success {
                                    isLoginActive = true
                                } else {
                                    message = "Invalid credentials. Please check your email and password."
                                    showMessageAlert = true
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

                        // SignUp Button (with temporary registration logic)
                        Button(action: {
                            Task {
                                let success = await registerUser(email: email, password: password)
                                if success {
                                    message = "Registration successful! You can now log in."
                                    showMessageAlert = true
                                } else {
                                    message = "Registration failed. Try again."
                                    showMessageAlert = true
                                }
                            }
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
                    
                    // Navigation Links
                    NavigationLink(destination: HomeView(), isActive: $isLoginActive) {
                        EmptyView()
                    }
                    
                    Spacer()
                }
                // Apply a counter offset equal to the keyboard height.
                .offset(y: keyboardHeight)
                .animation(.easeOut(duration: 0.16), value: keyboardHeight)
            }
            .navigationTitle("Login")
            .alert(isPresented: $showMessageAlert) {
                Alert(title: Text("Message"), message: Text(message), dismissButton: .default(Text("OK")))
            }
        }
        // Listen for keyboard height changes and update our state.
        .onReceive(Publishers.keyboardHeight) { height in
            self.keyboardHeight = height
        }
    }
    
    // MARK: - 🔐 Login Function (Checks Saved Data)
    func loginUser(email: String, password: String) async -> Bool {
        // First, try to fetch locally stored registration data for testing.
        if let savedData = loadRegistrationData() {
            return email == savedData.0 && password == savedData.1
        }
        
        // If no saved data exists, try to authenticate with the server.
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

    // MARK: - 📝 Registration Function (Temporarily Saves Locally)
    func registerUser(email: String, password: String) async -> Bool {
        // First, try to save locally for testing.
        saveRegistrationData(email: email, password: password)
        
        // Uncomment the server request when the backend is ready.
        /*
        guard let url = URL(string: "https://example.com/api/register") else { return false }
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
            print("Registration error: \(error)")
            return false
        }
        */
        
        return true // Return success since we're using local storage for now.
    }

    // MARK: - 💾 Save & Load Registration Data Locally (For Testing)
    func saveRegistrationData(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "registeredEmail")
        UserDefaults.standard.set(password, forKey: "registeredPassword")
        print("✅ Registration Data Saved Locally - Email: \(email), Password: \(password)")
    }

    func loadRegistrationData() -> (String, String)? {
        if let email = UserDefaults.standard.string(forKey: "registeredEmail"),
           let password = UserDefaults.standard.string(forKey: "registeredPassword") {
            return (email, password)
        }
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
