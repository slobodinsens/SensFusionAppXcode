import SwiftUI
import Combine
import UserNotifications

// Define a struct that matches the expected server JSON response.
struct HomeData: Codable {
    let text: String
    let imageURL: String
}

struct HomeView: View {
    @State private var serverText: String = "Loading text from server..."
    // Initially, we keep a placeholder URL (optional) that will be updated.
    @State private var imageUrl: URL? = nil
    
    // Notification options state variables (as before)
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
            await fetchServerData()
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
    
    // MARK: - Networking & Image Saving
    
    // This function fetches both text and image URL from the server,
    // then downloads and saves the image locally, and finally sends a notification.
    func fetchServerData() async {
        guard let url = URL(string: "https://example.com/api/homeData") else {
            print("Invalid URL")
            return
        }
        
        do {
            // Fetch JSON data from the server.
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Server error")
                return
            }
            
            // Decode the JSON into HomeData.
            let homeData = try JSONDecoder().decode(HomeData.self, from: data)
            
            // Update UI on the main thread.
            await MainActor.run {
                self.serverText = homeData.text
                // Update imageUrl so AsyncImage will load it.
                if let remoteImageURL = URL(string: homeData.imageURL) {
                    self.imageUrl = remoteImageURL
                }
            }
            
            // Download the image data.
            if let remoteImageURL = URL(string: homeData.imageURL) {
                let (imageData, _) = try await URLSession.shared.data(from: remoteImageURL)
                // Save image to local storage.
                if let savedURL = saveImageToDocuments(data: imageData) {
                    print("Image saved to: \(savedURL)")
                    // Trigger a local notification informing the image has been received.
                    await sendLocalNotification(title: "Image Received", body: "A new image was downloaded and saved.")
                }
            }
        } catch {
            print("Error fetching server data: \(error)")
        }
    }
    
    // Save the image data to the app's Documents directory.
    func saveImageToDocuments(data: Data) -> URL? {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
            let fileURL = documentsURL.appendingPathComponent("downloadedImage.png")
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // Request notification permissions and send a local notification.
    func sendLocalNotification(title: String, body: String) async {
        let center = UNUserNotificationCenter.current()
        
        do {
            // ✅ Marked `try` before `await` to handle potential errors
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            
            if granted {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // ✅ `try await` added inside a `do/catch`
                try await center.add(request)
                print("Notification scheduled")
            } else {
                print("Notification permission not granted")
            }
        } catch {
            print("Error requesting notification permission or scheduling: \(error)")
        }
    }

}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
