//
//  ScannerView.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    /// QR Code Scanner Properties
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    /// QR Scanner AV Output
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    /// Error Properties
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @Environment(\.openURL) private var openURL
    /// Camera QR Output Delegate
    @StateObject private var qrDelegate = QRScannerDelegate()
    /// Scanned Code
    @State private var scannedCode: String = ""
    /// Device Orientation
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    var body: some View {
        VStack(spacing: 8) {
            // Button to 2nd View
            HStack{
                NavigationLink(destination: MovieInfoView()) { Text("View Movies")}
                    .buttonStyle(.borderedProminent)
                Spacer()
            }

            // Scanner
            GeometryReader {
                let size = $0.size
//                let sqareWidth = min(size.width, 300)
                
                ZStack {
                    CameraView(frameSize: CGSize(width: size.width, height: size.height), session: $session, orientation: $orientation)
                }
                // Center
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(10)
            }
        }
        .navigationTitle("Scan QR Code")
        .padding(15)
        // Check Camera Permission, when the View is Visible
        .onAppear(perform: checkCameraPermission)
        .onDisappear {
            session.stopRunning()
        }
        .alert(errorMessage, isPresented: $showError) {
            // Show Setting's Button, if permission is denied
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        // Open App's Setting, Using openURL SwiftUI API
                        openURL(settingsURL)
                    }
                }
                
                // Cancel Button
                Button("Cancel", role: .cancel) {
                }
            }
        }
        .onChange(of: qrDelegate.scannedCode) { newValue in
            if let code = newValue {
                scannedCode = code
                // When the first code scan is available, immediately stop the camera.
                session.stopRunning()
                // Stop Scanner Animation
                deActivateScannerAnimation()
                // Clear the Data on Delegate
                qrDelegate.scannedCode = nil
                // Present Scanned Code
                presentError(scannedCode)
            }
        }
        .onChange(of: session.isRunning) { newValue in
            if newValue {
                orientation = UIDevice.current.orientation
            }
        }
    }
    
    func reactivateCamera() {
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    // Activate Scanner Animation Method
    func activateScannerAnimation() {
        // Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85).delay(0.1).repeatForever(autoreverses: true)) {
            isScanning = true
        }
    }
    
    // De-Activate Scanner Animation Method
    func deActivateScannerAnimation() {
        /// Adding Delay for Each Reversal
        withAnimation(.easeInOut(duration: 0.85)) {
            isScanning = false
        }
    }
    
    // Check Camera Permissions
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty {
                    // New Setup
                    setupCamera()
                } else {
                    // Reactivate Camera
                    reactivateCamera()
                }
            case .notDetermined:
                // Request Camera Access
                if await AVCaptureDevice.requestAccess(for: .video) {
                    // Permission Granted
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    // Permission Denied
                    cameraPermission = .denied
                    // Error Message
                    presentError("Please Provide Access to Camera for scanning codes")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please Provide Access to Camera for scanning codes")
            default: break
            }
        }
    }
    
    // Set Up Camera
    func setupCamera() {
        do {
            // Finding Back Camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                presentError("UNKNOWN DEVICE ERROR")
                return
            }
            
            // Camera Input
            let input = try AVCaptureDeviceInput(device: device)

            // Checking Whether input & output can be added to the session
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("UNKNOWN INPUT/OUTPUT ERROR")
                return
            }
            
            // Adding Input & ouptut to Camera Session
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            // Setting Ouput config to read QR Codes
            qrOutput.metadataObjectTypes = [.qr]
            // Adding Delegate to Retreive the Fetched QR Code From Camera
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            // Session must be started on Background thread else error
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            activateScannerAnimation()
        } catch {
            presentError(error.localizedDescription)
        }
    }
    
    // Present Error
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
