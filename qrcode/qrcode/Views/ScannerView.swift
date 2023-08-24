//
//  ScannerView.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    // QR Code Scanner Properties
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: Permission = .idle
    
    // QR  Scanner AV Output
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    
    // Error Properties
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @Environment(\.openURL) private var openURL
    
    // Camera QR Output Delegate
    @StateObject private var qrDelegate = QRScannerDelegate()
    var body: some View {
        VStack(spacing: 8) {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(Color("Blue"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Scan QR Code")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)
            Text("Scanning wil lstart")
                .font(.callout)
                .foregroundColor(.gray)
            Spacer(minLength: 0)
            GeometryReader {
                let size = $0.size
                
                ZStack {
                    CameraView(frameSize: CGSize(width: size.width, height: size.height), session: $session)
//                    Rectangle()
//                    RoundedRectangle(cornerRadius: 2, style: .circular)
                }
                // Square Shape
//                .frame(width: size.width, height: size.width)
                // To Make it Center
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Spacer(minLength: 15)
            Button {
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
//                    .foregroundColor(.gray)
            }
        }
        // Checking camera permission when the view is visible
        .onAppear(perform: checkCameraPermissinon)
        .alert(errorMessage, isPresented: $showError) {
            // Showing setting's button, if permission is denied
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        // Opening App's Settings, Using openURL SwiftUI API
                        openURL(settingsURL)
                    }
                }
                
                // Cancel Button
                Button("Cancel", role: .cancel) {
                    
                }
            }
        }
    }
    
    func checkCameraPermissinon(){
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                setupCamera()
            case.notDetermined:
                // Request Camera Access
                if await AVCaptureDevice.requestAccess(for: .video) {
                    // Permission Granted
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    // Permission Denied
                    cameraPermission = .denied
                    // Presenting Error Message
                    presentError("Please Provide Access to Camera for scanning codes")
                    
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentError("Please Provide Access to Camera for scanning codes")
            default: break
            }
        }
    }
    
    // Setting Up Camera
    func setupCamera() {
        do {
            // Finding Back Camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else {
                presentError("Unknown Device Error")
                return
            }
            
            // Camera Input
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("Unknown Input or Output Error")
                return
            }
            
            // Add input and output to camera session
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            qrOutput.metadataObjectTypes = [.qr]
            // Add Delegate to retrieve the fetched QR Code From Camera
            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            session.commitConfiguration()
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            
            
        } catch {
            presentError(error.localizedDescription)
            
        }
    }
    
    // Presenting Error
    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
}

struct ScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
