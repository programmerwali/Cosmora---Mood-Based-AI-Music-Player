//
//  HomeDashboardViewModel.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 12/03/2025.
//


import Foundation
import UIKit

struct ActivityItem {
    let id: Int
    let title: String
    let imageName: String
}

class HomeDashboardViewModel {
    // MARK: - Properties
    
    private(set) var activities: [ActivityItem] = []
    private(set) var userName: String = "Wali K"  // Could be loaded from UserDefaults or a user service
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good morning!"
        case 12..<17:
            return "Good afternoon!"
        default:
            return "Good evening!"
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadActivities()
    }
    
    // MARK: - Public Methods
    
    func numberOfActivities() -> Int {
        return activities.count
    }
    
    func activity(at index: Int) -> ActivityItem? {
        guard index >= 0 && index < activities.count else { return nil }
        return activities[index]
    }
    
    func handleActivitySelection(at index: Int) -> UIViewController? {
        guard let activity = activity(at: index) else { return nil }
        
        switch activity.id {
        case 0:
            return VoiceEmotionDetectorViewController()
        case 1:
            // Return the appropriate view controller for Emotional Compass
            return nil // Replace with actual implementation when available
        case 2:
            // Return the appropriate view controller for Meditation
            return nil // Replace with actual implementation when available
        case 3:
            // Return the appropriate view controller for Sentiment Beats
            return nil // Replace with actual implementation when available
        default:
            return nil
        }
    }
    
    func handleSpotifyAuthResult(success: Bool) -> UIAlertController? {
        if !success {
            let alert = UIAlertController(
                title: "Authentication Failed",
                message: "Failed to sign in with Spotify.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            return alert
        }
        return nil
    }
    
    func createSpotifyPlayerViewController() -> UIViewController {
        return SpotifyPlayerViewController()
    }
    
    // MARK: - Private Methods
    
    private func loadActivities() {
        activities = [
            ActivityItem(id: 0, title: "Mood Capture", imageName: "mooddetect"),
            ActivityItem(id: 1, title: "Emotional Compass", imageName: "moodcompass"),
            ActivityItem(id: 2, title: "Meditation", imageName: "moodchange"),
            ActivityItem(id: 3, title: "Sentiment Beats", imageName: "sentimentbeats")
        ]
    }
}
