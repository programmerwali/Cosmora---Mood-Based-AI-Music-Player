//
//  SpotifyPlayerViewController.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 01/03/2025.
//

import SafariServices
import UIKit


// MARK: - SpotifyPlayerViewController
class SpotifyPlayerViewController: UIViewController {
    
    // UI Components
    private let backgroundImageView = UIImageView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let albumArtView = UIImageView()
    private let trackNameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let progressSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let totalTimeLabel = UILabel()
    private let playPauseButton = UIButton()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private let backButton = UIButton()
    private let moodLabel = UILabel()
    
    // Track data
    private var currentTrack: Track?
    private var isPlaying = false
    private var timer: Timer?
    private var currentProgress: Float = 0.0
    
    private var currentTracks: [Track] = []
    private var currentTrackIndex: Int = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Check if user is logged in to Spotify
        if !SpotifyAuthManager.shared.isSignedIn {
            presentSpotifyLogin()
        } else {
            loadRecommendedTracks()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Background with blur
        setupBackgroundView()
        
        // Album Art
        setupAlbumArtView()
        
        // Track Info
        setupTrackInfoLabels()
        
        // Progress Controls
        setupProgressControls()
        
        // Playback Controls
        setupPlaybackControls()
        
        // Back Button
        setupBackButton()
        
        // Mood Label
        setupMoodLabel()
    }
    
    private func setupBackgroundView() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = UIImage(named: "background_placeholder")
        view.addSubview(backgroundImageView)
        
        visualEffectView.alpha = 0.8
        view.addSubview(visualEffectView)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupAlbumArtView() {
        albumArtView.contentMode = .scaleAspectFit
        albumArtView.layer.cornerRadius = 8
        albumArtView.clipsToBounds = true
        albumArtView.backgroundColor = .darkGray
        view.addSubview(albumArtView)
        
        albumArtView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            albumArtView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            albumArtView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            albumArtView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            albumArtView.heightAnchor.constraint(equalTo: albumArtView.widthAnchor)
        ])
    }
    
    private func setupTrackInfoLabels() {
        trackNameLabel.text = "Track Name"
        trackNameLabel.textColor = .white
        trackNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        trackNameLabel.textAlignment = .center
        view.addSubview(trackNameLabel)
        
        artistNameLabel.text = "Artist Name"
        artistNameLabel.textColor = .lightGray
        artistNameLabel.font = UIFont.systemFont(ofSize: 18)
        artistNameLabel.textAlignment = .center
        view.addSubview(artistNameLabel)
        
        trackNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackNameLabel.topAnchor.constraint(equalTo: albumArtView.bottomAnchor, constant: 20),
            trackNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trackNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 8),
            artistNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            artistNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupProgressControls() {
        progressSlider.minimumValue = 0.0
        progressSlider.maximumValue = 1.0
        progressSlider.value = 0.0
        progressSlider.tintColor = .systemPurple
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        view.addSubview(progressSlider)
        
        currentTimeLabel.text = "0:00"
        currentTimeLabel.textColor = .lightGray
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(currentTimeLabel)
        
        totalTimeLabel.text = "3:30"
        totalTimeLabel.textColor = .lightGray
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.textAlignment = .right
        view.addSubview(totalTimeLabel)
        
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressSlider.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 30),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 8),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            
            totalTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 8),
            totalTimeLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor)
        ])
    }
    
    private func setupPlaybackControls() {
        let controlsStackView = UIStackView()
        controlsStackView.axis = .horizontal
        controlsStackView.distribution = .equalSpacing
        controlsStackView.alignment = .center
        controlsStackView.spacing = 40
        view.addSubview(controlsStackView)
        
        previousButton.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        previousButton.tintColor = .white
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        
        nextButton.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        nextButton.tintColor = .white
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        controlsStackView.addArrangedSubview(previousButton)
        controlsStackView.addArrangedSubview(playPauseButton)
        controlsStackView.addArrangedSubview(nextButton)
        
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            controlsStackView.topAnchor.constraint(equalTo: totalTimeLabel.bottomAnchor, constant: 30),
            controlsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsStackView.widthAnchor.constraint(equalToConstant: 200),
            
            playPauseButton.widthAnchor.constraint(equalToConstant: 64),
            playPauseButton.heightAnchor.constraint(equalToConstant: 64),
            
            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32),
            
            nextButton.widthAnchor.constraint(equalToConstant: 32),
            nextButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupBackButton() {
        backButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupMoodLabel() {
        moodLabel.text = "✨ Happy Mood"
        moodLabel.textColor = .white
        moodLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        moodLabel.textAlignment = .center
        view.addSubview(moodLabel)
        
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moodLabel.topAnchor.constraint(equalTo: backButton.topAnchor),
            moodLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moodLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        updateTimeLabel(for: sender.value)
     
    }
    
    @objc private func playPauseButtonTapped() {
        isPlaying.toggle()
        
        if isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            startPlaybackTimer()
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            timer?.invalidate()
        }
        
       
    }
    
    @objc private func previousButtonTapped() {
       
        resetPlayback()
        loadPreviousTrack()
    }
    
    @objc private func nextButtonTapped() {
     
        resetPlayback()
        loadNextTrack()
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Spotify Integration
    
    private func presentSpotifyLogin() {
        guard let authURL = SpotifyAuthManager.shared.getAuthURL() else { return }
        
        let safariVC = SFSafariViewController(url: authURL)
        present(safariVC, animated: true)
    }
    
    func handleAuthCallback(url: URL) {
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        
        SpotifyAuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            if success {
                self?.loadRecommendedTracks()
            }
        }
    }
    
    private func loadRecommendedTracks() {
        // Show loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Get recommendations based on mood
        SpotifyAPIManager.shared.getRecommendations(mood: "happy") { [weak self] tracks in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                
                if !tracks.isEmpty {
                    self?.currentTracks = tracks
                    self?.currentTrackIndex = 0
                    if let track = tracks.first {
                        self?.updatePlayerWithTrack(track)
                    }
                } else {
                    // Use fallback tracks when API fails
                    self?.useFallbackTracks()
                }
            }
        }
    }
    
    

    private func useFallbackTracks() {
        // Create fallback tracks when API fails
        let fallbackTracks = [
            Track(id: "6", name: "Happy", artist: "Pharrell Williams", albumArt: nil),
            Track(id: "7", name: "Good Feeling", artist: "Flo Rida", albumArt: nil),
            Track(id: "8", name: "Walking on Sunshine", artist: "Katrina & The Waves", albumArt: nil),
            Track(id: "9", name: "Uptown Funk", artist: "Mark Ronson ft. Bruno Mars", albumArt: nil),
            Track(id: "10", name: "Can't Stop the Feeling!", artist: "Justin Timberlake", albumArt: nil)
        ]
        
        self.currentTracks = fallbackTracks
        self.currentTrackIndex = 0
        if let track = fallbackTracks.first {
            self.updatePlayerWithTrack(track)
        }
    }
    
    private func loadNextTrack() {
        if currentTracks.isEmpty {
            loadRecommendedTracks()
            return
        }
        
        currentTrackIndex = (currentTrackIndex + 1) % currentTracks.count
        let nextTrack = currentTracks[currentTrackIndex]
        updatePlayerWithTrack(nextTrack)
    }
    
    private func loadPreviousTrack() {
        if currentTracks.isEmpty {
            loadRecommendedTracks()
            return
        }
        
        currentTrackIndex = (currentTrackIndex - 1 + currentTracks.count) % currentTracks.count
        let previousTrack = currentTracks[currentTrackIndex]
        updatePlayerWithTrack(previousTrack)
    }
    
    private func updatePlayerWithTrack(_ track: Track) {
        var mutableTrack = track
        currentTrack = track
        
        trackNameLabel.text = track.name
        artistNameLabel.text = track.artist
        
        if let albumArt = track.albumArt {
            albumArtView.image = albumArt
            backgroundImageView.image = albumArt
        } else {
            albumArtView.image = UIImage(systemName: "music.note")
            albumArtView.tintColor = .white
            
            // Load album art asynchronously
            mutableTrack.loadAlbumArt { [weak self] in
                guard let self = self else { return }
                if let updatedArt = mutableTrack.albumArt {
                    self.albumArtView.image = updatedArt
                    self.backgroundImageView.image = updatedArt
                    
                    // Update the currentTrack with the loaded album art
                    if var currentTrack = self.currentTrack {
                        currentTrack.albumArt = updatedArt
                        self.currentTrack = currentTrack
                    }
                }
            }
        }
        
        // If was playing, start playing the new track
        if isPlaying {
            resetPlayback()
            startPlaybackTimer()
        } else {
            resetPlayback()
        }
    }
    
    // MARK: - Playback Simulation
    
    private func startPlaybackTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentProgress < 1.0 {
                self.currentProgress += 0.001
                self.progressSlider.value = self.currentProgress
                self.updateTimeLabel(for: self.currentProgress)
            } else {
                self.timer?.invalidate()
                self.nextButtonTapped() // Auto play next track
            }
        }
    }
    
    private func resetPlayback() {
        timer?.invalidate()
        currentProgress = 0.0
        progressSlider.value = 0.0
        updateTimeLabel(for: 0)
    }
    
    private func updateTimeLabel(for progress: Float) {
        let totalDuration: Float = 210 
        let currentTime = Int(progress * totalDuration)
        
        let minutes = currentTime / 60
        let seconds = currentTime % 60
        currentTimeLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
}
