import SwiftUI

struct ConfigView: View {
    @Bindable var store: ChatStore
    @Bindable var speech: SpeechService
    @Environment(\.dismiss) private var dismiss
    @State private var localConfig: AppConfig = .defaults

    private let refiner = LLMRefiner.shared

    private let languages: [(String, String)] = [
        ("中文 (简体)", "zh-CN"),
        ("English (US)", "en-US"),
        ("日本語", "ja-JP"),
        ("한국어", "ko-KR"),
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("语音识别语言") {
                    Picker("语言", selection: Binding(
                        get: { localConfig.llm.locale },
                        set: {
                            localConfig.llm.locale = $0
                            speech.locale = Locale(identifier: $0)
                            store.updateConfig(localConfig)
                        }
                    )) {
                        ForEach(languages, id: \.1) { name, code in
                            Text(name).tag(code)
                        }
                    }
                }

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

                Section("LLM 识别优化") {
                    Toggle("启用 LLM 优化", isOn: Binding(
                        get: { refiner.isEnabled },
                        set: { newValue in
                            refiner.isEnabled = newValue
                            store.updateConfig(localConfig)
                        }
                    ))

                    if refiner.isEnabled {
                        TextField("API Base URL", text: Binding(
                            get: { refiner.apiBaseURL },
                            set: { refiner.apiBaseURL = $0 }
                        ))
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                        SecureField("API Key", text: Binding(
                            get: { refiner.apiKey },
                            set: { refiner.apiKey = $0 }
                        ))

                        TextField("模型", text: Binding(
                            get: { refiner.model },
                            set: { refiner.model = $0 }
                        ))
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                        if !refiner.isConfigured {
                            Text("请配置 API Key 以启用 LLM 优化")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Section("LLM 对话") {
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
