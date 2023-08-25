//
//  ContentView.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            ScannerView()
//            MovieInfoView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
