import SwiftUI

struct ChatView: View {
    @Bindable var store: ChatStore
    @Bindable var speech: SpeechService
    @State private var inputText: String = ""
    @State private var showConfig: Bool = false
    @State private var showAlarm: Bool = false
    @State private var isLoading: Bool = false
    private let llm = LLMService()

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: store.messages.count) { _, _ in
                    if let lastId = store.messages.last?.id {
                        withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Input
            HStack(spacing: 12) {
                Button {
                    Task {
                        if speech.isListening {
                            speech.stopListening()
                        } else {
                            do {
                                try await speech.startListening()
                            } catch {
                                inputText = "语音识别不可用"
                            }
                        }
                    }
                } label: {
                    Image(systemName: speech.isListening ? "waveform" : "mic.fill")
                        .font(.title2)
                        .foregroundStyle(speech.isListening ? .red : .accentColor)
                }
                .disabled(isLoading)

                if speech.isListening {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(speech.transcript.isEmpty ? "聆听中..." : speech.transcript)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
                } else {
                    TextField("输入消息...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.send)
                        .onSubmit { send() }
                }

                Button { send() } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(inputText.isEmpty || isLoading)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showAlarm = true
                } label: {
                    Image(systemName: store.isAlarmSet ? "alarm.fill" : "alarm")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showConfig = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showConfig) {
            ConfigView(store: store, speech: speech)
        }
        .sheet(isPresented: $showAlarm) {
            AlarmView()
        }
        .onChange(of: speech.transcript) { _, newValue in
            if !newValue.isEmpty && !speech.isListening {
                inputText = newValue
            }
        }
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        let userMsg = text
        speech.transcript = ""

        Task {
            store.sendUserMessage(content: userMsg)
            isLoading = true

            let aiContent = await llm.send(messages: store.messages, config: store.config.llm)

            await MainActor.run {
                store.addMessage(Message(role: .assistant, content: aiContent))
                speech.speak(aiContent, rate: store.config.llm.voiceRate, pitch: store.config.llm.voicePitch)
                isLoading = false
            }
        }
    }
}
