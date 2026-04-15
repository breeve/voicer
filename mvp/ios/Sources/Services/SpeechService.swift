import Foundation
import Speech
import AVFoundation

@Observable
@MainActor
final class SpeechService: NSObject, @unchecked Sendable {
    var transcript: String = ""
    var partialTranscript: String = ""
    var isListening: Bool = false
    var isSpeaking: Bool = false
    var audioLevel: Float = 0.0

    var locale: Locale = Locale(identifier: "zh-CN") {
        didSet { speechRecognizer = SFSpeechRecognizer(locale: locale) }
    }

    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var audioEngine: AVAudioEngine?

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

    func requestPermissions() async -> (speech: Bool, mic: Bool) {
        let speechGranted = await requestAuthorization()
        let micGranted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
        return (speechGranted, micGranted)
    }

    func startListening() async throws {
        let (speechGranted, micGranted) = await requestPermissions()
        guard speechGranted else { return }
        guard micGranted else { return }

        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Simulator has no real microphone — show listening UI briefly then auto-stop
        guard recordingFormat.sampleRate > 0 else {
            isListening = true
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                self.stopListening()
            }
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.transcript = text
                        self.partialTranscript = ""
                    } else {
                        self.partialTranscript = text
                    }
                }
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)

            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = Int(buffer.frameLength)
            var sum: Float = 0
            for i in 0..<frameLength {
                sum += channelData[i] * channelData[i]
            }
            let rms = sqrtf(sum / Float(max(frameLength, 1)))
            let dB = 20 * log10(max(rms, 1e-6))
            let normalized = max(0, min(1, (dB + 50) / 40))
            Task { @MainActor in
                self?.audioLevel = normalized
            }
        }

        engine.prepare()
        try engine.start()
        self.audioEngine = engine
        isListening = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            if self.isListening {
                self.stopListening()
            }
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
        audioLevel = 0
        partialTranscript = ""
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
