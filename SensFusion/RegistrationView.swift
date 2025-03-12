import SwiftUI
import Combine

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
                    
                    // Register Button with server logic.
                    Button(action: {
                        Task {
                            let success = await registerUser(email: email, password: password)
                            if success {
                                registrationComplete = true
                            } else {
                                // You might want to handle error feedback here.
                            }
                            // Dismiss the keyboard.
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
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
    
    // Function to send registration data to the server.
    func registerUser(email: String, password: String) async -> Bool {
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
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView().environmentObject(UserData())
    }
}
