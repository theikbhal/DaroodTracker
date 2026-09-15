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
    
    init() {
        // Pre-load sounds if needed
    }
    
    func play(_ sound: SoundType) {
        guard ExperimentsManager.shared.isEnabled("sounds") else { return }
        
        // Create a simple tone using AVAudioEngine
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let format = engine.outputNode.outputFormat(forBus: 0)
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        // Generate a simple sine wave tone
        let sampleRate = Float(format.sampleRate)
        let frequency: Float
        let duration: Float
        
        switch sound {
        case .tap:
            frequency = 800
            duration = 0.05
        case .batchComplete:
            frequency = 523.25 // C5
            duration = 0.2
        case .goalComplete:
            frequency = 659.25 // E5
            duration = 0.5
        case .streak:
            frequency = 783.99 // G5
            duration = 0.3
        case .welcome:
            frequency = 440 // A4
            duration = 0.3
        case .congrats:
            frequency = 880 // A5
            duration = 0.5
        case .tick:
            frequency = 1000
            duration = 0.02
        case .pop:
            frequency = 600
            duration = 0.08
        }
        
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        if let channelData = buffer.floatChannelData?[0] {
            for frame in 0..<Int(frameCount) {
                let value = sin(2.0 * .pi * Float(frame) * frequency / sampleRate) * 0.3
                channelData[frame] = value
            }
        }
        
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            engine.stop()
        }
        
        do {
            try engine.start()
            player.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func playHaptic() {
        guard ExperimentsManager.shared.isEnabled("haptics") else { return }
        
        #if os(macOS)
        // macOS doesn't have haptic feedback built-in, but we can use NSHapticFeedbackManager
        NSHapticFeedbackManager.defaultPerformer.perform(
            .generic,
            performanceTime: .default
        )
        #endif
    }
}
