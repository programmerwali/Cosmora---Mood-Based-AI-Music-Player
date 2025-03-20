//
//  SpotifyAPIManager.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 01/03/2025.
//

import Foundation
import UIKit


// MARK: - SpotifyAPIManger
class SpotifyAPIManager {
    static let shared = SpotifyAPIManager()
    
    private init() {}
    
    func searchTracks(query: String, completion: @escaping ([Track]) -> Void) {
        guard let token = SpotifyAuthManager.shared.getAccessToken(),
              let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=20") else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("API Error: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                if let tracksJSON = json?["tracks"] as? [String: Any],
                   let items = tracksJSON["items"] as? [[String: Any]] {

                    let tracks = items.compactMap { item -> Track? in
                        guard let id = item["id"] as? String,
                              let name = item["name"] as? String,
                              let artists = item["artists"] as? [[String: Any]],
                              let artistName = artists.first?["name"] as? String else {
                            return nil
                        }
                        
                        // Extract album art URL and load image asynchronously
                        var albumArt: UIImage? = nil
                        if let album = item["album"] as? [String: Any],
                           let images = album["images"] as? [[String: Any]],
                           let imageURL = images.first?["url"] as? String {
                     
                        }

                        return Track(id: id, name: name, artist: artistName, albumArt: albumArt)
                    }
                    
                    DispatchQueue.main.async {
                        completion(tracks)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        task.resume()
    }
    
    func getRecommendations(mood: String, completion: @escaping ([Track]) -> Void) {
        guard let token = SpotifyAuthManager.shared.getAccessToken() else {
            print("Error: No access token available")
            completion([])
            return
        }
        
        // Convert mood to seed genres or seed tracks
        let seedGenres: String
        switch mood.lowercased() {
        case "happy":
            seedGenres = "pop,happy"
        case "sad":
            seedGenres = "sad,indie"
        case "energetic":
            seedGenres = "edm,dance"
        case "relaxed":
            seedGenres = "chill,ambient"
        default:
            seedGenres = "pop"
        }
        
        guard let encodedGenres = seedGenres.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.spotify.com/v1/recommendations?limit=10&seed_genres=\(encodedGenres)") else {
            print("Error: Invalid URL")
            completion([])
            return
        }

        print("Making API request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("API Response Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    if let data = data, let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("API Error Response: \(errorJson)")
                    }
                }
            }

            guard let data = data else {
                print("Error: No data received")
                completion([])
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                print("Response JSON: \(json ?? [:])")
                
                if let tracks = json?["tracks"] as? [[String: Any]] {
                    let mappedTracks = tracks.compactMap { track -> Track? in
                        guard let id = track["id"] as? String,
                              let name = track["name"] as? String,
                              let artists = track["artists"] as? [[String: Any]],
                              let artistName = artists.first?["name"] as? String else {
                            print("Error parsing track: \(track)")
                            return nil
                        }
                        
                        return Track(id: id, name: name, artist: artistName, albumArt: nil)
                    }
                    
                    print("Successfully parsed \(mappedTracks.count) tracks")
                    DispatchQueue.main.async {
                        completion(mappedTracks)
                    }
                } else {
                    print("No tracks found in response")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
        task.resume()
    }
    
    
    func loadAlbumArt(for trackId: String, completion: @escaping (UIImage?) -> Void) {
        guard let token = SpotifyAuthManager.shared.getAccessToken(),
              let url = URL(string: "https://api.spotify.com/v1/tracks/\(trackId)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let album = json["album"] as? [String: Any],
                   let images = album["images"] as? [[String: Any]],
                   let imageURLString = images.first?["url"] as? String,
                   let imageURL = URL(string: imageURLString) {
                    
                    self.downloadImage(from: imageURL) { image in
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
}


