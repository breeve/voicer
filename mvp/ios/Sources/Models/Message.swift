import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct Message: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

struct LLMConfig: Codable {
    var provider: String // "mock" or "ollama"
    var ollamaUrl: String
    var model: String
    var voiceRate: Double
    var voicePitch: Double
    var locale: String // BCP-47 locale identifier for speech recognition

    static var defaults: LLMConfig {
        LLMConfig(
            provider: "mock",
            ollamaUrl: "http://localhost:11434",
            model: "llama3.2",
            voiceRate: 1.0,
            voicePitch: 1.0,
            locale: "zh-CN"
        )
    }
}

struct AppConfig: Codable {
    var llm: LLMConfig
    var theme: String // "light" or "dark"

    static var defaults: AppConfig {
        AppConfig(llm: .defaults, theme: "light")
    }
}
