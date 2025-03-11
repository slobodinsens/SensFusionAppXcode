import SwiftUI

struct HomeView: View {
    @State private var serverText: String = "Loading text from server..."
    // Replace with your actual image URL from the server.
    @State private var imageUrl: URL? = URL(string: "https://via.placeholder.com/600x200.png?text=Server+Image")
    
    // Notification options state variables
    @State private var showNotificationOptions: Bool = false
    @State private var notificationsNewMessages: Bool = false
    @State private var notificationsUpdates: Bool = false
    @State private var notificationsPromotions: Bool = false

    var body: some View {
        ZStack {
            // Background image from Assets (file name "3.png")
            Image("3")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Canvas for image from the server
                    if let imageUrl = imageUrl {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            case .failure:
                                Color.red
                                    .frame(height: 200)
                                    .overlay(
                                        Text("Failed to load image")
                                            .foregroundColor(.white)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        // Tap on the image to show notification options.
                        .onTapGesture {
                            showNotificationOptions = true
                        }
                    } else {
                        Color.gray
                            .frame(height: 200)
                            .overlay(Text("No Image URL"))
                    }
                    
                    // Text fetched from the server
                    Text(serverText)
                        .padding()
                        // Tap on the text to show notification options.
                        .onTapGesture {
                            showNotificationOptions = true
                        }
                    
                    // Optional button to explicitly show notification options.
                    Button("Notification Options") {
                        showNotificationOptions = true
                    }
                    .padding()
                    .background(Color.blue.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Home")
        .task {
            await fetchServerText()
        }
        // Present a sheet with notification options.
        .sheet(isPresented: $showNotificationOptions) {
            NavigationView {
                Form {
                    Section(header: Text("Select Notifications")) {
                        Toggle("New Server Messages", isOn: $notificationsNewMessages)
                        Toggle("Server Updates", isOn: $notificationsUpdates)
                        Toggle("Promotional Notifications", isOn: $notificationsPromotions)
                    }
                }
                .navigationTitle("Notification Options")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showNotificationOptions = false
                        }
                    }
                }
            }
        }
    }
    
    // Simulate a network call to fetch text from a server.
    func fetchServerText() async {
        // Simulate a network delay.
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        // Update the state with the fetched text.
        serverText = "This text was loaded from the server!"
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
