import SwiftUI

struct ConfigView: View {
    @Bindable var store: ChatStore
    @Bindable var speech: SpeechService
    @Environment(\.dismiss) private var dismiss
    @State private var localConfig: AppConfig = .defaults

    var body: some View {
        NavigationStack {
            Form {
                Section("音色") {
                    VStack(alignment: .leading) {
                        Text("语速: \(localConfig.llm.voiceRate, specifier: "%.1f")")
                        Slider(value: Binding(
                            get: { localConfig.llm.voiceRate },
                            set: {
                                localConfig.llm.voiceRate = $0
                                store.updateConfig(localConfig)
                            }
                        ), in: 0.5...2.0, step: 0.1)
                    }
                    VStack(alignment: .leading) {
                        Text("音调: \(localConfig.llm.voicePitch, specifier: "%.1f")")
                        Slider(value: Binding(
                            get: { localConfig.llm.voicePitch },
                            set: {
                                localConfig.llm.voicePitch = $0
                                store.updateConfig(localConfig)
                            }
                        ), in: 0.5...2.0, step: 0.1)
                    }
                    Button("测试语音") {
                        speech.speak("你好，这是一段测试语音。",
                                   rate: localConfig.llm.voiceRate,
                                   pitch: localConfig.llm.voicePitch)
                    }
                }

                Section("LLM") {
                    Picker("模式", selection: Binding(
                        get: { localConfig.llm.provider },
                        set: {
                            localConfig.llm.provider = $0
                            store.updateConfig(localConfig)
                        }
                    )) {
                        Text("Mock 响应").tag("mock")
                        Text("Ollama 本地").tag("ollama")
                    }
                    .pickerStyle(.segmented)

                    if localConfig.llm.provider == "ollama" {
                        TextField("Ollama URL", text: Binding(
                            get: { localConfig.llm.ollamaUrl },
                            set: {
                                localConfig.llm.ollamaUrl = $0
                                store.updateConfig(localConfig)
                            }
                        ))
                        .textContentType(.URL)
                        .autocapitalization(.none)

                        TextField("模型名称", text: Binding(
                            get: { localConfig.llm.model },
                            set: {
                                localConfig.llm.model = $0
                                store.updateConfig(localConfig)
                            }
                        ))
                        .autocapitalization(.none)
                    }
                }

                Section("主题") {
                    Picker("外观", selection: Binding(
                        get: { localConfig.theme },
                        set: {
                            localConfig.theme = $0
                            store.updateConfig(localConfig)
                        }
                    )) {
                        Text("浅色").tag("light")
                        Text("深色").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button("清除对话历史", role: .destructive) {
                        store.clearMessages()
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .onAppear { localConfig = store.config }
        }
    }
}
