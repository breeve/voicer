import Foundation
import Speech
import AVFoundation

@Observable
@MainActor
final class SpeechService: NSObject, @unchecked Sendable {
    var transcript: String = ""
    var isListening: Bool = false
    var isSpeaking: Bool = false

    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private var audioEngine: AVAudioEngine?

    func startListening() async throws {
        guard await requestAuthorization() else { return }

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Simulator has no real microphone — skip audio tap gracefully
        guard recordingFormat.sampleRate > 0 else {
            await MainActor.run { self.isListening = false }
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = false

        let locale = Locale(identifier: "zh-CN")
        let recognizer = SFSpeechRecognizer(locale: locale)!

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    self?.transcript = result.bestTranscription.formattedString
                }
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        engine.prepare()
        try engine.start()
        self.audioEngine = engine
        isListening = true

        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await MainActor.run { self.stopListening() }
        }
    }

    func stopListening() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
    }

    nonisolated func speak(_ text: String, rate: Double = 1.0, pitch: Double = 1.0) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = Float(rate) * AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = Float(pitch)
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
        Task { @MainActor in self.isSpeaking = true }
    }

    nonisolated func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        Task { @MainActor in self.isSpeaking = false }
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
