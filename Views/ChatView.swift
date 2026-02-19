import SwiftUI

struct ChatView: View {
    let request: BorrowRequest
    @EnvironmentObject private var backend: FirebaseBackendService
    @State private var input: String = ""

    private var messages: [ChatMessage] {
        backend.messagesByRequest[request.id] ?? []
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            ChatBubble(message: message, isCurrentUser: message.senderId == backend.currentUser?.id)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Message…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await sendMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .task {
            await backend.subscribeToMessages(for: request)
        }
    }

    private func sendMessage() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        await backend.sendMessage(text, for: request)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            Text(message.text)
                .padding(10)
                .background(isCurrentUser ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                .foregroundColor(isCurrentUser ? .white : .primary)
                .cornerRadius(12)

            if !isCurrentUser { Spacer() }
        }
    }
}

