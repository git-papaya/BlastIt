import Foundation
import AVFoundation

public final class SoundManager: NSObject, AVAudioPlayerDelegate {
    public static let shared = SoundManager()

    public var isSoundEnabled: Bool = true
    private var players: [String: AVAudioPlayer] = [:]
    private var comboPlayers: [AVAudioPlayer] = []

    private override init() {
        super.init()
        setupAudioSession()
        generateProceduralSounds()
    }

    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration error: \(error)")
        }
        #endif
    }

    private func generateProceduralSounds() {
        // Place click sound
        if let placeData = createSynthWav(frequency: 320.0, duration: 0.08, decay: 35.0) {
            players["place"] = try? AVAudioPlayer(data: placeData)
            players["place"]?.prepareToPlay()
        }

        // Line clear chord sound
        if let clearData = createHarmonicWav(fundamental: 587.33, duration: 0.35, decay: 8.0) {
            players["clear"] = try? AVAudioPlayer(data: clearData)
            players["clear"]?.prepareToPlay()
        }

        // Game over sound
        if let gameOverData = createSynthWav(frequency: 180.0, duration: 0.5, decay: 5.0) {
            players["gameOver"] = try? AVAudioPlayer(data: gameOverData)
            players["gameOver"]?.prepareToPlay()
        }

        // Combo ascending scale: Pentatonic progression
        let comboFreqs: [Double] = [
            523.25, // C5
            587.33, // D5
            659.25, // E5
            783.99, // G5
            880.00, // A5
            1046.50, // C6
            1174.66, // D6
            1318.51, // E6
            1567.98, // G6
            2093.00  // C7
        ]

        comboPlayers = comboFreqs.compactMap { freq in
            guard let wavData = createHarmonicWav(fundamental: freq, duration: 0.38, decay: 7.0) else { return nil }
            let player = try? AVAudioPlayer(data: wavData)
            player?.prepareToPlay()
            return player
        }
    }

    public func playPlace() {
        guard isSoundEnabled else { return }
        players["place"]?.currentTime = 0
        players["place"]?.play()
    }

    public func playClear() {
        guard isSoundEnabled else { return }
        players["clear"]?.currentTime = 0
        players["clear"]?.play()
    }

    public func playCombo(streak: Int) {
        guard isSoundEnabled, !comboPlayers.isEmpty else { return }
        let index = max(0, min(streak - 1, comboPlayers.count - 1))
        let player = comboPlayers[index]
        player.currentTime = 0
        player.play()
    }

    public func playGameOver() {
        guard isSoundEnabled else { return }
        players["gameOver"]?.currentTime = 0
        players["gameOver"]?.play()
    }

    // MARK: - Procedural WAV Synthesis Engine

    private func createSynthWav(frequency: Double, duration: Double, decay: Double) -> Data? {
        let sampleRate = 44100
        let numSamples = Int(Double(sampleRate) * duration)
        var samples = [Int16](repeating: 0, count: numSamples)

        for i in 0..<numSamples {
            let t = Double(i) / Double(sampleRate)
            let envelope = exp(-decay * t)
            let angle = 2.0 * .pi * frequency * t
            let value = sin(angle) * envelope
            samples[i] = Int16(max(-1.0, min(1.0, value)) * 32767.0)
        }

        return encodeWav(samples: samples, sampleRate: sampleRate)
    }

    private func createHarmonicWav(fundamental: Double, duration: Double, decay: Double) -> Data? {
        let sampleRate = 44100
        let numSamples = Int(Double(sampleRate) * duration)
        var samples = [Int16](repeating: 0, count: numSamples)

        for i in 0..<numSamples {
            let t = Double(i) / Double(sampleRate)
            let envelope = exp(-decay * t)
            let f1 = sin(2.0 * .pi * fundamental * t)
            let f2 = 0.5 * sin(2.0 * .pi * (fundamental * 2.0) * t)
            let f3 = 0.25 * sin(2.0 * .pi * (fundamental * 3.0) * t)
            let mixed = (f1 + f2 + f3) / 1.75 * envelope
            samples[i] = Int16(max(-1.0, min(1.0, mixed)) * 32767.0)
        }

        return encodeWav(samples: samples, sampleRate: sampleRate)
    }

    private func encodeWav(samples: [Int16], sampleRate: Int) -> Data {
        let subchunk2Size = samples.count * 2
        let chunkSize = 36 + subchunk2Size
        var data = Data()

        // RIFF header
        data.append(contentsOf: "RIFF".utf8)
        data.append(UInt32(chunkSize).littleEndianData)
        data.append(contentsOf: "WAVE".utf8)

        // fmt subchunk
        data.append(contentsOf: "fmt ".utf8)
        data.append(UInt32(16).littleEndianData) // Subchunk1Size (16 for PCM)
        data.append(UInt16(1).littleEndianData)  // AudioFormat (1 = PCM)
        data.append(UInt16(1).littleEndianData)  // NumChannels (1 = Mono)
        data.append(UInt32(sampleRate).littleEndianData)
        data.append(UInt32(sampleRate * 2).littleEndianData) // ByteRate
        data.append(UInt16(2).littleEndianData)  // BlockAlign
        data.append(UInt16(16).littleEndianData) // BitsPerSample

        // data subchunk
        data.append(contentsOf: "data".utf8)
        data.append(UInt32(subchunk2Size).littleEndianData)

        // Audio sample data
        samples.withUnsafeBufferPointer { buffer in
            data.append(buffer)
        }

        return data
    }
}

private extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}
