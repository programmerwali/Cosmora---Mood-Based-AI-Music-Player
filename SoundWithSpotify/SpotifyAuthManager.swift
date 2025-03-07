//
//  SpotifyAuthManager.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 27/02/2025.
//

import UIKit
import SafariServices



// MARK: - SpotifyAuthManager
class SpotifyAuthManager {
    static let shared = SpotifyAuthManager()
    
    private var accessToken: String?
    private var refreshToken: String?
    private var expirationDate: Date?
    
    private init() {
        // Load tokens from UserDefaults
        accessToken = UserDefaults.standard.string(forKey: "spotify_access_token")
        refreshToken = UserDefaults.standard.string(forKey: "spotify_refresh_token")
        if let expirationTimeInterval = UserDefaults.standard.object(forKey: "spotify_token_expiration") as? TimeInterval {
            expirationDate = Date(timeIntervalSince1970: expirationTimeInterval)
        }
    }
    
    var isSignedIn: Bool {
        guard let expirationDate = expirationDate else { return false }
        return accessToken != nil && Date().compare(expirationDate) == .orderedAscending
    }
    
    func startAuthentication() {
        print("Starting Spotify authentication...")  // Debugging
        
        let authorizationURL = getAuthURL()
        
        guard let authURL = authorizationURL else {
            print("Authorization URL is nil!")  // Debugging
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(authURL, options: [:]) { success in
                print("Opened Spotify login:", success)  // Debugging
            }
        }
    }

    
    func getAuthURL() -> URL? {
        let baseURL = "https://accounts.spotify.com/authorize"
        let redirectURI = SpotifyConfiguration.redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let scopes = SpotifyConfiguration.scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let urlString = "\(baseURL)?client_id=\(SpotifyConfiguration.clientID)&response_type=code&redirect_uri=\(redirectURI!)&scope=\(scopes!)&show_dialog=true"
        
        return URL(string: urlString)
    }
    
    func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            print("Invalid token URL")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": SpotifyConfiguration.redirectURI,
            "client_id": SpotifyConfiguration.clientID,
            "client_secret": "54d2a7358a0e494497d7bf9a4d448800"  // in production
        ]
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        print("Exchanging code for token...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Token exchange network error: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Token exchange response code: \(httpResponse.statusCode)")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                print("Token response: \(json ?? [:])")
                
                if let error = json?["error"] as? String {
                    print("Auth error: \(error)")
                    completion(false)
                    return
                }
                
                self.accessToken = json?["access_token"] as? String
                self.refreshToken = json?["refresh_token"] as? String
                if let expiresIn = json?["expires_in"] as? TimeInterval {
                    self.expirationDate = Date().addingTimeInterval(expiresIn)
                }

                // Save tokens
                UserDefaults.standard.set(self.accessToken, forKey: "spotify_access_token")
                UserDefaults.standard.set(self.refreshToken, forKey: "spotify_refresh_token")
                UserDefaults.standard.set(self.expirationDate?.timeIntervalSince1970, forKey: "spotify_token_expiration")
                
                print("Successfully obtained access token: \(self.accessToken != nil)")
                
               

                print("Successfully obtained access token: \(self.accessToken != nil)")
                DispatchQueue.main.async {
                    // Force presentation of player view after successful auth
                    let rootVC = UIApplication.shared.windows.first?.rootViewController
                    let playerVC = SpotifyPlayerViewController()
                    playerVC.modalPresentationStyle = .fullScreen
                    rootVC?.present(playerVC, animated: true)
                }
                completion(true)
            } catch {
                print("Token parsing error: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = refreshToken, let url = URL(string: "https://accounts.spotify.com/api/token") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": SpotifyConfiguration.clientID,
            "client_secret": "54d2a7358a0e494497d7bf9a4d448800"
        ]
        request.httpBody = bodyParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                self.accessToken = json?["access_token"] as? String
                if let expiresIn = json?["expires_in"] as? TimeInterval {
                    self.expirationDate = Date().addingTimeInterval(expiresIn)
                }

                // Save new token
                UserDefaults.standard.set(self.accessToken, forKey: "spotify_access_token")
                UserDefaults.standard.set(self.expirationDate?.timeIntervalSince1970, forKey: "spotify_token_expiration")
                
                completion(true)
            } catch {
                completion(false)
            }
        }
        task.resume()
    }


    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func signOut() {
        accessToken = nil
        refreshToken = nil
        expirationDate = nil
        
        UserDefaults.standard.removeObject(forKey: "spotify_access_token")
        UserDefaults.standard.removeObject(forKey: "spotify_refresh_token")
        UserDefaults.standard.removeObject(forKey: "spotify_token_expiration")
    }
    
    // SpotifyAuthManager.swift

    func debugAuthenticationState() {
        print("=== SPOTIFY AUTH DEBUG ===")
        print("Access Token: \(accessToken != nil ? "Present" : "Missing")")
        print("Refresh Token: \(refreshToken != nil ? "Present" : "Missing")")
        if let expDate = expirationDate {
            print("Expiration: \(expDate), Is Valid: \(Date().compare(expDate) == .orderedAscending)")
        } else {
            print("Expiration: Missing")
        }
        print("isSignedIn reports: \(isSignedIn)")
        print("=========================")
    }
    
    
}



// MARK: - Extension for HomeDashboardViewController
extension HomeDashboardViewController {
    @objc func addButtonTapped() {
        SpotifyAuthManager.shared.startAuthentication()
        let playerVC = SpotifyPlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
    func setupAddButton() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
}


