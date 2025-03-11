import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData

    @State private var email = ""
    @State private var password = ""
    @State private var isLoginActive = false
    @State private var isSignUpActive = false
    @State private var loginErrorMessage = ""
    @State private var showLoginErrorAlert = false

    var body: some View {
        NavigationView {
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
                        // Validate the login credentials against the stored registration data.
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
                
                // Hidden Navigation Links triggered by state flags
                NavigationLink(destination: HomeView(), isActive: $isLoginActive) {
                    EmptyView()
                }
                
                NavigationLink(destination: RegistrationView(), isActive: $isSignUpActive) {
                    EmptyView()
                }
                
                Spacer()
            }
            .navigationTitle("Login")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
