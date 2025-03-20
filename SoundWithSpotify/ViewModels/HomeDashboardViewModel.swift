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
    private(set) var userName: String = AppConfig.userName
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return AppConfig.morningGreeting
        case 12..<17:
            return AppConfig.afternoonGreeting
        default:
            return AppConfig.eveningGreeting
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
            // Return  view controller for Emotional Compass -  coming soon
            return nil
        case 2:
            // Return  view controller for Meditation
            return MeditationChatViewController()
        case 3:
            // Return  view controller for Sentiment Beats - coming soon
            return nil
        default:
            return nil
        }
    }
    
    func handleSpotifyAuthResult(success: Bool) -> UIAlertController? {
        if !success {
            let alert = UIAlertController(
                title: AlertMessages.authFailedTitle,
                message: AlertMessages.authFailedMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: AlertMessages.authFailedTitle, style: .default))
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
            ActivityItem(id: 0, title: ActivityConstants.moodCapture, imageName: ActivityConstants.moodCaptureImage),
            ActivityItem(id: 1, title: ActivityConstants.emotionalCompass, imageName: ActivityConstants.emotionalCompassImage),
            ActivityItem(id: 2, title: ActivityConstants.meditationChatAI, imageName: ActivityConstants.meditationChatAIImage),
            ActivityItem(id: 3, title: ActivityConstants.sentimentBeats, imageName: ActivityConstants.sentimentBeatsImage)
        ]
    }

}
