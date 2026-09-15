import AVFoundation
import AppKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    enum SoundType: String, CaseIterable {
        case tap = "tap"
        case batchComplete = "batch_complete"
        case goalComplete = "goal_complete"
        case streak = "streak"
        case welcome = "welcome"
        case congrats = "congrats"
        case tick = "tick"
        case pop = "pop"
    }
    
    init() {}
    
    func play(_ sound: SoundType) {
        guard ExperimentsManager.shared.isEnabled("sounds") else { return }
        
        let frequency: Float
        let duration: Float
        let volume: Float
        
        switch sound {
        case .tap:
            frequency = 800; duration = 0.05; volume = 0.2
        case .batchComplete:
            frequency = 523.25; duration = 0.15; volume = 0.3
        case .goalComplete:
            frequency = 659.25; duration = 0.4; volume = 0.4
        case .streak:
            frequency = 783.99; duration = 0.25; volume = 0.3
        case .welcome:
            frequency = 440; duration = 0.2; volume = 0.3
        case .congrats:
            frequency = 880; duration = 0.35; volume = 0.35
        case .tick:
            frequency = 1000; duration = 0.02; volume = 0.15
        case .pop:
            frequency = 600; duration = 0.06; volume = 0.2
        }
        
        playTone(frequency: frequency, duration: duration, volume: volume)
    }
    
    private func playTone(frequency: Float, duration: Float, volume: Float) {
        let sampleRate: Float = 44100
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        if let channelData = buffer.floatChannelData?[0] {
            for frame in 0..<Int(frameCount) {
                let envelope = min(1.0, Float(frame) / (sampleRate * 0.01)) * max(0, 1.0 - Float(frame) / (sampleRate * duration))
                channelData[frame] = sin(2.0 * .pi * Float(frame) * frequency / sampleRate) * volume * envelope
            }
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: bufferIntodata(buffer))
            audioPlayer?.play()
        } catch {
            print("Sound error: \(error.localizedDescription)")
        }
    }
    
    private func bufferIntodata(_ buffer: AVAudioPCMBuffer) -> Data {
        let channelData = buffer.floatChannelData![0]
        let frames = Int(buffer.frameLength)
        var data = Data(count: frames * 2)
        
        for i in 0..<frames {
            let sample = Int16(channelData[i] * Float(Int16.max))
            data[i*2] = UInt8(truncatingIfNeeded: sample)
            data[i*2+1] = UInt8(truncatingIfNeeded: sample >> 8)
        }
        
        return data
    }
    
    func playHaptic() {
        guard ExperimentsManager.shared.isEnabled("haptics") else { return }
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }
}
