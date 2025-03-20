//
//  AppDelegate.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 27/02/2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received callback URL: \(url.absoluteString)")
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              urlComponents.scheme == "spotify-ios-quick-start",
              urlComponents.host == "spotify-login-callback" else {
            print("URL scheme or host doesn't match")
            return false
        }
        
        if let queryItems = urlComponents.queryItems,
           let code = queryItems.first(where: { $0.name == "code" })?.value {
            print("Received auth code: \(code)")
            
            SpotifyAuthManager.shared.exchangeCodeForToken(code: code) { success in
                print("Token exchange result: \(success)")
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .spotifyAuthCompleted, object: nil, userInfo: ["success": success])
                    
                    // Debug auth state
                    SpotifyAuthManager.shared.debugAuthenticationState()
                }
            }
            return true
        } else {
            print("No code found in callback URL")
        }
        
        return false
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

