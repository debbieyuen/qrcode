//
//  QRScannerDelegate.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let scannedCode = readableObject.stringValue else { return }
            print(scannedCode)
        }
    }
}
