//
//  JSONViewModel.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI

class JSONViewModel: ObservableObject {
    @Published var movies : [MovieModel] = []
    
    func fetchData() {
        let url = "https://debbieyuen.me"
        var request = URLRequest(url: URL(string: url)!)
        request.addValue("swiftui2.0", forHTTPHeaderField: "field")
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { (data, res, _) in
            guard let jsonData = data else { return }
            
            //checking for any internal api errors
            
            let response = res as! HTTPURLResponse
            //checking by status code
            
            if response.statusCode == 404{
                print("error API Error")
                return
            }
            
            // fetching JSON Data
            do {
                let movies = try JSONDecoder().decode([MovieModel].self, from: jsonData)
                DispatchQueue.main.async {
                    self.movies = movies
                }
            }
            catch {
                print(error.localizedDescription)
            }
        } .resume()
    }
}
