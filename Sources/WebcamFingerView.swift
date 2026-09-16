import SwiftUI
import AVFoundation

// MARK: - Webcam Finger View

struct WebcamFingerView: View {
    @EnvironmentObject var store: DaroodStore
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var experiments: ExperimentsManager
    @State private var isCameraActive = false
    @State private var cameraPermission = false
    @State private var errorMessage: String?
    @State private var showResetConfirm = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Webcam Finger Count")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(Date(), style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(store.todayTotalCount) / \(store.dailyTarget)")
                            .font(.headline)
                        Text("\(store.remainingBatches) batches left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Camera status
                HStack {
                    Circle()
                        .fill(isCameraActive ? .green : .red)
                        .frame(width: 10, height: 10)
                    Text(isCameraActive ? "Camera Active" : "Camera Inactive")
                        .font(.caption)
                    
                    Spacer()
                }
                
                // Camera preview
                ZStack {
                    CameraPreviewView(isActive: $isCameraActive)
                        .frame(height: 300)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(isCameraActive ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    
                    if !cameraPermission {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Camera Access Required")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Button("Grant Access") {
                                requestCameraPermission()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    if let error = errorMessage {
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                
                // Count buttons
                VStack(spacing: 12) {
                    Text("Count Using Buttons")
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        Button(action: { addCount(1) }) {
                            Label("+1", systemImage: "hand.point.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: { addCount(5) }) {
                            Label("+5", systemImage: "hand.raised")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: { addCount(10) }) {
                            Label("+10", systemImage: "hand.thumbsup")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                
                // Camera controls
                HStack(spacing: 20) {
                    Button(action: {
                        isCameraActive.toggle()
                    }) {
                        Label(isCameraActive ? "Stop Camera" : "Start Camera", systemImage: isCameraActive ? "stop.fill" : "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isCameraActive ? .red : .green)
                    
                    Button(action: { showResetConfirm = true }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .alert("Reset Today?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetToday()
                SoundManager.shared.play(.pop)
            }
        } message: {
            Text("This will set today's count back to 0.")
        }
        .onAppear {
            requestCameraPermission()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermission = granted
                if !granted {
                    errorMessage = "Camera access denied. Please enable in System Settings > Privacy & Security."
                } else {
                    errorMessage = nil
                }
            }
        }
    }
    
    private func addCount(_ count: Int) {
        store.addCount(count)
        if experiments.isEnabled("buttonSounds") {
            SoundManager.shared.play(.tick)
        }
        SoundManager.shared.playHaptic()
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: NSViewRepresentable {
    @Binding var isActive: Bool
    
    func makeNSView(context: Context) -> CameraPreviewNSView {
        let view = CameraPreviewNSView()
        view.isActive = isActive
        return view
    }
    
    func updateNSView(_ nsView: CameraPreviewNSView, context: Context) {
        nsView.isActive = isActive
        if isActive {
            nsView.startCapture()
        } else {
            nsView.stopCapture()
        }
    }
}

// MARK: - Camera Preview NS View

class CameraPreviewNSView: NSView, AVCaptureVideoDataOutputSampleBufferDelegate {
    var isActive = false
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        captureSession.addOutput(output)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = bounds
        
        if let previewLayer = previewLayer {
            layer?.addSublayer(previewLayer)
        }
    }
    
    func startCapture() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopCapture() {
        captureSession?.stopRunning()
    }
    
    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Camera feed is displayed by previewLayer
        // Hand detection would go here in a full implementation
    }
}
