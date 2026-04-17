import Foundation
import SwiftUI

@Observable
final class ChatStore {
    var messages: [Message] = [
        Message(role: .assistant, content: "你好！我是 Voicer，有什么可以帮你的吗？")
    ]
    var config: AppConfig = .defaults
    var isListening: Bool = false
    var transcript: String = ""
    var isAlarmSet: Bool = false
    var alarmRemaining: Int? = nil

    private let userDefaultsKey = "voicer-chat-store"

    init() {
        load()
    }

    func addMessage(_ message: Message) {
        messages.append(message)
        save()
    }

    func sendUserMessage(content: String) {
        let msg = Message(role: .user, content: content)
        addMessage(msg)
    }

    func updateConfig(_ config: AppConfig) {
        self.config = config
        save()
    }

    func clearMessages() {
        messages.removeAll()
        messages.append(Message(role: .assistant, content: "你好！我是 Voicer，有什么可以帮你的吗？"))
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey + "-config")
        }
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey + "-messages")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey + "-config"),
           let cfg = try? JSONDecoder().decode(AppConfig.self, from: data) {
            config = cfg
        }
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey + "-messages"),
           let msgs = try? JSONDecoder().decode([Message].self, from: data) {
            if !msgs.isEmpty {
                messages = msgs
            }
        }
    }
}
