//
//  Track.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 08/03/2025.
//

import Foundation
import UIKit

// MARK: - Track Model
class Track {
    let id: String
    let name: String
    let artist: String
    var albumArt: UIImage?
    
    
    init(id: String, name: String, artist: String, albumArt: UIImage?) {
        self.id = id
        self.name = name
        self.artist = artist
        self.albumArt = albumArt
    }
    
    func loadAlbumArt(completion: @escaping () -> Void) {
        SpotifyAPIManager.shared.loadAlbumArt(for: id) { [weak self] image in
            self?.albumArt = image
            completion()
        }
    }
}
