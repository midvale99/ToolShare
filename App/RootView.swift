import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            BoardView()
                .tabItem {
                    Label("Board", systemImage: "square.grid.2x2")
                }

            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "bubble.left.and.bubble.right")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

