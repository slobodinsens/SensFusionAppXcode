import SwiftUI

class UserData: ObservableObject {
    @Published var registeredUserName: String = ""
    @Published var registeredEmail: String = ""
    @Published var registeredPassword: String = ""
}
