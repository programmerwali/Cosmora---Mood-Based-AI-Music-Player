//
//  constantsfile.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 20/03/2025.
//

import Foundation

struct APIConstants {
    static let geminiAPIKey = "AIzaSyADIv17NB2p8b2JN0JPrxJh8xZ-VpW21lE"
    static let geminiModel = "gemini-1.5-pro"
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1/models"
}

struct HomeDashboardConstants {
    static let title = "Home Dashboard"
    static let searchPlaceholder = "Want to search something..."
}


struct AppConfig {
    private(set) static var userName: String = "Wali K"
    private(set) static var profileImage: String = "walipfp"
    
    static let morningGreeting = "Good morning!"
    static let afternoonGreeting = "Good afternoon!"
    static let eveningGreeting = "Good evening!"
}

struct ActivityConstants {
    static let moodCapture = "Mood Capture"
    static let emotionalCompass = "Emotional Compass"
    static let meditationChatAI = "Meditate Chat"
    static let sentimentBeats = "Sentiment Beats"

    static let moodCaptureImage = "mooddetect"
    static let emotionalCompassImage = "moodcompass"
    static let meditationChatAIImage = "moodchange"
    static let sentimentBeatsImage = "sentimentbeats"
}

struct SpotifyConfiguration {
    static let clientID = "8ef6ffd15daf4ea293c824e874667700"
    static let redirectURI = "spotify-ios-quick-start://spotify-login-callback"
    static let scopes = "user-read-private user-read-email streaming user-library-read user-read-playback-state user-modify-playback-state"
}

struct AlertMessages {
    static let authFailedTitle = "Authentication Failed"
    static let authFailedMessage = "Failed to sign in with Spotify."
}

struct EmotionConstants {
    static let noEmotionDetected = "No emotion detected yet"
}

struct OnboardingConstants {
    static let page1Image = "onboarding1"
    static let page1Title = "Discover Cosmic Tunes"
    static let page1Description = "Let the universe choose the perfect soundtrack for your mood."

    static let page2Image = "onboarding2"
    static let page2Title = "AI-Powered Playlists"
    static let page2Description = "Advanced AI maps your emotions to celestial soundscapes."

    static let page3Image = "onboarding3"
    static let page3Title = "Explore the Sound Galaxy"
    static let page3Description = "Venture into a universe of personalized music recommendations."
}




