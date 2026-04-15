import SwiftUI

struct WaveformView: View {
    let audioLevel: Float
    let isListening: Bool

    private let barCount = 5
    private let barWeights: [CGFloat] = [0.5, 0.8, 1.0, 0.75, 0.55]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { i in
                WaveformBar(
                    weight: barWeights[i],
                    audioLevel: audioLevel,
                    isAnimating: isListening,
                    index: i
                )
            }
        }
        .frame(width: 36, height: 24)
    }
}

private struct WaveformBar: View {
    let weight: CGFloat
    let audioLevel: Float
    let isAnimating: Bool
    let index: Int

    @State private var animatedHeight: CGFloat = 0.15

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.red.opacity(0.85))
            .frame(width: 4, height: barHeight)
            .animation(.easeOut(duration: 0.08), value: barHeight)
    }

    private var barHeight: CGFloat {
        guard isAnimating else { return 4 }
        let fraction = 0.15 + (1 - 0.15) * CGFloat(audioLevel) * weight
        let jitter = CGFloat.random(in: -0.04...0.04)
        return max(4, min(24, 24 * min(max(fraction + jitter, 0.15), 1.0)))
    }
}
