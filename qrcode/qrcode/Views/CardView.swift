//
//  CardView.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI

struct CardView: View {
    var movie: MovieModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text(movie.name)
            Text(movie.playTime)
            Text(movie.city)
        })
    }
}
