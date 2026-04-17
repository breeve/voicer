import SwiftUI

struct AlarmView: View {
    @State private var alarm = AlarmService()
    @Environment(\.dismiss) private var dismiss
    @State private var customMinutes: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                alarmStatus
                quickSetGrid
                customSet
                Spacer()
            }
            .padding()
            .navigationTitle("闹钟")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private var alarmStatus: some View {
        if alarm.isSet, let remaining = alarm.remaining {
            VStack(spacing: 8) {
                Image(systemName: "alarm.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text(formatTime(remaining))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())

                Button("取消闹钟", role: .destructive) {
                    alarm.cancel()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 32)
        }
    }

    private var quickSetGrid: some View {
        VStack(spacing: 12) {
            Text("快速设置")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                ForEach([5, 15, 30, 60], id: \.self) { minutes in
                    Button("\(minutes)分钟") {
                        Task { await alarm.setAlarm(minutes: minutes) }
                    }
                    .buttonStyle(.bordered)
                    .disabled(alarm.isSet)
                }
            }
        }
    }

    private var customSet: some View {
        VStack(spacing: 12) {
            Text("自定义")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                TextField("分钟", text: $customMinutes)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Button("设置") {
                    if let m = Int(customMinutes), m > 0 {
                        Task { await alarm.setAlarm(minutes: m) }
                        customMinutes = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(alarm.isSet || customMinutes.isEmpty)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
