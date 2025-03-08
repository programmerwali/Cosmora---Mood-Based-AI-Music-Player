//
//  SpotifyConfiguration.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 01/03/2025.
//

import Foundation

// MARK: - SpotifyConfiguration
struct SpotifyConfiguration {
    static let clientID = "8ef6ffd15daf4ea293c824e874667700"
    static let redirectURI = "spotify-ios-quick-start://spotify-login-callback"
    static let scopes = "user-read-private user-read-email streaming user-library-read user-read-playback-state user-modify-playback-state"
}
