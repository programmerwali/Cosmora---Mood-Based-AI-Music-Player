//
//  SpotifyPlayerManager.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 01/03/2025.
//

import Foundation
import UIKit
import AVFoundation


class SpotifyPlayerManager {
    static let shared = SpotifyPlayerManager()
    
    private var player: AVPlayer?
    private var currentTrackId: String?
    
    private init() {
        // Setup background audio
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func playTrack(id: String, completion: @escaping (Bool) -> Void) {
        guard let token = SpotifyAuthManager.shared.getAccessToken() else {
            completion(false)
            return
        }
        
        // Get the track's preview URL
        getTrackPreviewURL(trackId: id, token: token) { [weak self] previewURL in
            guard let self = self, let previewURL = previewURL else {
                completion(false)
                return
            }
            
            // Create and play the audio
            let playerItem = AVPlayerItem(url: previewURL)
            if self.player == nil {
                self.player = AVPlayer(playerItem: playerItem)
            } else {
                self.player?.replaceCurrentItem(with: playerItem)
            }
            
            self.player?.play()
            self.currentTrackId = id
            completion(true)
        }
    }
    
    func pauseTrack() {
        player?.pause()
    }
    
    func resumeTrack() {
        player?.play()
    }
    
    private func getTrackPreviewURL(trackId: String, token: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/tracks/\(trackId)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                   let previewURLString = json["preview_url"] as? String,
                   let previewURL = URL(string: previewURLString) {
                    completion(previewURL)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
