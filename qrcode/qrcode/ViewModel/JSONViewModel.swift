//
//  JSONViewModel.swift
//  qrcode
//
//  Created by Debbie Yuen on 8/24/23.
//

import SwiftUI
import CoreData

class JSONViewModel: ObservableObject {
    @Published var movies : [MovieModel] = []
    
    // Save JSON to Core Data
    func saveData(context: NSManagedObjectContext){
        movies.forEach { (data) in
            let entity = MovieEntity(context: context)
            entity.name = data.name
            entity.city = data.city
            entity.playTime = data.playTime
        }
        do {
            try context.save()
            print("success")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchData(context: NSManagedObjectContext) {
        let url = "https://debbieyuen.me"
//        let url = "{\"name\":\"Inception\",\"playTime\":\"120\",\"city\":\"New York\"}"
//        let url = "{"name":"Inception","playTime": 120,"city":"New York"}"
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
                    self.saveData(context: context)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        } .resume()
    }
}
