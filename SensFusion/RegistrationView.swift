import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var userData: UserData

    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var registrationComplete = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Registration Page")
                .font(.title)
                .padding()

            // User Name Field
            TextField("User Name", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
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
                // Save the registration data in the shared model.
                userData.registeredUserName = username
                userData.registeredEmail = email
                userData.registeredPassword = password
                
                registrationComplete = true
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
        .navigationTitle("Register")
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegistrationView().environmentObject(UserData())
        }
    }
}
