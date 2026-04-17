import Foundation
import UserNotifications

@Observable
@MainActor
final class AlarmService: @unchecked Sendable {
    var remaining: Int? = nil
    var isSet: Bool = false

    private var timer: Timer?
    private var totalSeconds: Int = 0

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
            return granted
        } catch {
            return false
        }
    }

    func setAlarm(minutes: Int) async {
        await requestPermission()
        cancel()

        let seconds = minutes * 60
        totalSeconds = seconds
        remaining = seconds
        isSet = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let r = self.remaining else { return }
                if r > 0 {
                    self.remaining = r - 1
                } else {
                    self.fireAlarm()
                }
            }
        }
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        remaining = nil
        isSet = false
    }

    private func fireAlarm() {
        timer?.invalidate()
        timer = nil
        remaining = nil
        isSet = false

        let content = UNMutableNotificationContent()
        content.title = "Voicer 闹钟"
        content.body = "已过 \(totalSeconds / 60) 分钟"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
