//
//  QRScannerDelegate.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let Code = readableObject.stringValue else { return }
            print(Code)
            let jsonResponse = Code
            
            // Decode JSON String
            // let jsonResponse = "{\"name\":\"Inception\",\"playTime\":\"120\",\"city\":\"New York\"}"
            let data = Data(jsonResponse.utf8)
            let str = try! JSONDecoder().decode(String.self, from: data)
            // let str = try! JSONDecoder().decode(Dictionary<String, String>.self, from: data)
            print(str)
            scannedCode = Code
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
