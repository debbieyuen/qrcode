//
//  MovieInfoView.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI

struct MovieInfoView: View {
    @StateObject var jsonModel = JSONViewModel()
    @Environment(\.managedObjectContext) var context
    var body: some View {
        VStack {
            List() {
                if jsonModel.movies.isEmpty {
                    ProgressView()
                        .onAppear(perform: {
                            jsonModel.fetchData(context: context)
                        })
                } else {
                    List(jsonModel.movies, id: \.self) { movie in
                        CardView(movie: movie)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
        }.navigationTitle("Movie Information")
//            .navigationBarTitleDisplayMode(.inline)
    }
}

struct MovieInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MovieInfoView()
    }
}
