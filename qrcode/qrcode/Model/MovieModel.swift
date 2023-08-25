//
//  MovieModel.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI

struct MovieModel: Decodable, Hashable {
    var name: String
    var playTime: String
    var city: String
}
