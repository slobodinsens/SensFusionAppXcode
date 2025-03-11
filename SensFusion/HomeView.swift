import SwiftUI

struct HomeView: View {
    @State private var serverText: String = "Loading text from server..."
    // Replace with your actual image URL from the server.
    @State private var imageUrl: URL? = URL(string: "https://via.placeholder.com/600x200.png?text=Server+Image")

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
                    } else {
                        Color.gray
                            .frame(height: 200)
                            .overlay(Text("No Image URL"))
                    }
                    
                    // Text fetched from the server
                    Text(serverText)
                        .padding()
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Home")
        .task {
            await fetchServerText()
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
