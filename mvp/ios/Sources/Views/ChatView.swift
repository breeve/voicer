import SwiftUI

struct ChatView: View {
    @Bindable var store: ChatStore
    @Bindable var speech: SpeechService
    @State private var inputText: String = ""
    @State private var showConfig: Bool = false
    @State private var showAlarm: Bool = false
    @State private var isLoading: Bool = false
    @State private var isRefining: Bool = false
    private let llm = LLMService()
    private let refiner = LLMRefiner.shared

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
                            speech.locale = Locale(identifier: store.config.llm.locale)
                            do {
                                try await speech.startListening()
                            } catch {
                                inputText = "语音识别不可用"
                            }
                        }
                    }
                } label: {
                    ZStack {
                        WaveformView(audioLevel: speech.audioLevel, isListening: speech.isListening)
                    }
                    .frame(width: 36, height: 24)
                }
                .disabled(isLoading)

                if speech.isListening {
                    HStack(spacing: 6) {
                        WaveformView(audioLevel: speech.audioLevel, isListening: speech.isListening)
                        Text(displayText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                let finalText = newValue
                if refiner.isEnabled && refiner.isConfigured {
                    isRefining = true
                    refiner.refine(finalText) { [self] result in
                        isRefining = false
                        switch result {
                        case .success(let refined):
                            inputText = refined.isEmpty ? finalText : refined
                        case .failure:
                            inputText = finalText
                        }
                    }
                } else {
                    inputText = finalText
                }
                speech.transcript = ""
            }
        }
    }

    private var displayText: String {
        let text = speech.partialTranscript.isEmpty ? speech.transcript : speech.partialTranscript
        if isRefining { return "优化中..." }
        return text.isEmpty ? "聆听中..." : text
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        speech.transcript = ""
        speech.partialTranscript = ""

        Task {
            store.sendUserMessage(content: text)
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
