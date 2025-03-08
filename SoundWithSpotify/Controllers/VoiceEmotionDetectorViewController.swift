//
//  VoiceEmotionDetectorViewController.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 3/03/2025.
//

import UIKit
import AVFoundation
import SoundAnalysis
import CoreMedia

class VoiceEmotionDetectorViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: - UI Properties
    private let contentView = UIView()
    private let recordButton = UIButton()
    private let statusLabel = UILabel()
    private let emotionLabel = UILabel()
    private let confidenceLabel = UILabel()
    private let emotionIconView = UIImageView()
    private let historyTableView = UITableView()
    private let headerView = UIView()
    private let headerTitle = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Audio Properties
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    private var recordingURL: URL?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    // MARK: - Classification Properties
    private var analyzer: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    
    // MARK: - Data Properties
    private var emotionHistory: [(emotion: String, confidence: Float, timestamp: Date)] = []
    
    // MARK: - UI Colors
    private let primaryPurple = UIColor(red: 0.5, green: 0.3, blue: 0.9, alpha: 1.0)
    private let secondaryPurple = UIColor(red: 0.4, green: 0.2, blue: 0.7, alpha: 1.0)
    private let lightPurple = UIColor(red: 0.85, green: 0.8, blue: 0.95, alpha: 1.0)
    private let darkPurple = UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        setupClassifier()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame
        gradientLayer.frame = view.bounds
        
        // Apply rounded corners to record button
        recordButton.layer.cornerRadius = recordButton.frame.height / 2
        recordButton.clipsToBounds = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupBackgroundGradient()
        setupHeaderView()
        setupContentView()
        setupRecordButton()
        setupStatusLabel()
        setupEmotionViews()
        setupHistoryTableView()
        setupConstraints()
    }
    
    private func setupBackgroundGradient() {
        gradientLayer.colors = [
            primaryPurple.cgColor,
            secondaryPurple.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = darkPurple.withAlphaComponent(0.7)
        headerView.layer.cornerRadius = 0
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowOpacity = 0.3
        headerView.layer.shadowRadius = 4
        view.addSubview(headerView)
        
        headerTitle.text = "Emotion Voice Analyzer"
        headerTitle.textColor = .white
        headerTitle.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        headerTitle.textAlignment = .center
        headerView.addSubview(headerTitle)
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false
        view.addSubview(contentView)
    }
    
    private func setupRecordButton() {
        // Create an inner shadow effect with layers
        recordButton.backgroundColor = primaryPurple
        
        // Set up button appearance
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .medium)
        recordButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: largeConfig), for: .normal)
        recordButton.setImage(UIImage(systemName: "stop.fill", withConfiguration: largeConfig), for: .selected)
        recordButton.tintColor = .white
        recordButton.layer.shadowColor = UIColor.black.cgColor
        recordButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        recordButton.layer.shadowOpacity = 0.3
        recordButton.layer.shadowRadius = 5
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        contentView.addSubview(recordButton)
    }
    
    private func setupStatusLabel() {
        statusLabel.text = "Tap to start voice analysis"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = darkPurple
        contentView.addSubview(statusLabel)
    }
    
    private func setupEmotionViews() {
        // Icon View setup
        emotionIconView.contentMode = .scaleAspectFit
        emotionIconView.tintColor = primaryPurple
        emotionIconView.image = UIImage(systemName: "waveform.circle")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 80))
        emotionIconView.layer.shadowColor = UIColor.black.cgColor
        emotionIconView.layer.shadowOffset = CGSize(width: 0, height: 2)
        emotionIconView.layer.shadowOpacity = 0.2
        emotionIconView.layer.shadowRadius = 4
        contentView.addSubview(emotionIconView)
        
        // Emotion Label setup
        emotionLabel.text = "No emotion detected yet"
        emotionLabel.textAlignment = .center
        emotionLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        emotionLabel.textColor = darkPurple
        contentView.addSubview(emotionLabel)
        
        // Confidence Label setup
        confidenceLabel.text = ""
        confidenceLabel.textAlignment = .center
        confidenceLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        confidenceLabel.textColor = UIColor.gray
        contentView.addSubview(confidenceLabel)
    }
    
    private func setupHistoryTableView() {
        historyTableView.backgroundColor = .clear
        historyTableView.separatorStyle = .none
        historyTableView.register(EmotionHistoryCell.self, forCellReuseIdentifier: "EmotionCell")
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.layer.cornerRadius = 12
        historyTableView.clipsToBounds = true
        contentView.addSubview(historyTableView)
        
        // Add a header for the table
        let headerLabel = UILabel()
        headerLabel.text = "Emotion History"
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.textColor = darkPurple
        headerLabel.textAlignment = .left
        headerLabel.frame = CGRect(x: 15, y: 10, width: view.frame.width - 30, height: 30)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        headerView.backgroundColor = .clear
        headerView.addSubview(headerLabel)
        historyTableView.tableHeaderView = headerView
    }
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        emotionIconView.translatesAutoresizingMaskIntoConstraints = false
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        confidenceLabel.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Header Title
            headerTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerTitle.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            // Emotion Icon
            emotionIconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            emotionIconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emotionIconView.widthAnchor.constraint(equalToConstant: 100),
            emotionIconView.heightAnchor.constraint(equalToConstant: 100),
            
            // Emotion Label
            emotionLabel.topAnchor.constraint(equalTo: emotionIconView.bottomAnchor, constant: 15),
            emotionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emotionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emotionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Confidence Label
            confidenceLabel.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 5),
            confidenceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            confidenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confidenceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Record Button
            recordButton.topAnchor.constraint(equalTo: confidenceLabel.bottomAnchor, constant: 25),
            recordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 15),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // History Table View
            historyTableView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            historyTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            historyTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            historyTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            statusLabel.text = "Audio session setup failed"
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    private func setupClassifier() {
        do {
            let soundClassifier = try emotionTestRecognizer()
            
            classificationRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            
            classificationRequest?.windowDuration = CMTime(seconds: 0.975, preferredTimescale: .max)
            classificationRequest?.overlapFactor = 0.5
            
            statusLabel.text = "Ready to analyze your voice"
        } catch {
            statusLabel.text = "Failed to load sound classification model"
            print("Failed to load sound classification model: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Recording Actions
    @objc private func recordButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else {
            statusLabel.text = "Failed to initialize audio engine"
            return
        }
        
        inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        
        guard let recordingFormat = recordingFormat else {
            statusLabel.text = "Failed to get recording format"
            return
        }
        
        analyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        
        guard let analyzer = analyzer, let request = classificationRequest else {
            statusLabel.text = "Failed to set up audio analyzer"
            return
        }
        
        do {
            try analyzer.add(request, withObserver: self)
            
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
                self?.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
            
            try audioEngine.start()
            
            isRecording = true
            recordButton.isSelected = true
            statusLabel.text = "Listening to your voice..."
            
            // Add pulse animation
            applyPulseAnimation()
            
        } catch {
            statusLabel.text = "Failed to start audio analysis"
            print("Failed to start audio analysis: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
    private func stopRecording() {
        guard isRecording else { return } // Prevent multiple stops
        
        // Remove tap on input node
        inputNode?.removeTap(onBus: 0)
        
        // Stop audio engine safely
        audioEngine?.stop()
        audioEngine = nil
        
        // Remove requests from analyzer
        if let analyzer = analyzer, let request = classificationRequest {
            analyzer.remove(request)
        }
        analyzer = nil
        
        isRecording = false
        recordButton.isSelected = false
        statusLabel.text = "Voice analysis complete"
        
        // Stop animation
        stopPulseAnimation()
    }
    
    // MARK: - Animations
    private func applyPulseAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.recordButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.recordButton.backgroundColor = self.darkPurple
        })
    }
    
    private func stopPulseAnimation() {
        UIView.animate(withDuration: 0.2) {
            self.recordButton.transform = .identity
            self.recordButton.backgroundColor = self.primaryPurple
        }
    }
    
    // MARK: - UI Updates
    private func updateEmotionDisplay(emotion: String, confidence: Float) {
        DispatchQueue.main.async {
            self.emotionLabel.text = self.formatEmotionText(emotion)
            self.confidenceLabel.text = "Confidence: \(Int(confidence * 100))%"
            
            // Add to history with most recent at the top
            let newEntry = (emotion: emotion, confidence: confidence, timestamp: Date())
            self.emotionHistory.insert(newEntry, at: 0)
            self.historyTableView.reloadData()
            
            // Update icon based on emotion
            self.updateEmotionIcon(for: emotion)
        }
    }
    
    private func formatEmotionText(_ emotion: String) -> String {
        // Capitalize first letter and make the rest lowercase
        let formatted = emotion.prefix(1).uppercased() + emotion.dropFirst().lowercased()
        return formatted
    }
    
    private func updateEmotionIcon(for emotion: String) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)

        switch emotion.lowercased() {
        case "happy", "joy":
            emotionIconView.image = UIImage(systemName: "face.smiling", withConfiguration: largeConfig)
            emotionIconView.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0) // Golden

        case "sad", "sadness":
            emotionIconView.image = UIImage(systemName: "cloud.drizzle.fill", withConfiguration: largeConfig) // Represents sadness like rain
            emotionIconView.tintColor = UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0) // Blue

        case "angry", "anger":
            emotionIconView.image = UIImage(systemName: "flame.fill", withConfiguration: largeConfig) // Fire represents rage
            emotionIconView.tintColor = UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0) // Red

        case "fear", "scared":
            emotionIconView.image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: largeConfig) // Warning sign for fear
            emotionIconView.tintColor = UIColor(red: 0.6, green: 0.0, blue: 0.7, alpha: 1.0) // Purple

        case "surprise", "surprised":
            emotionIconView.image = UIImage(systemName: "bolt.shield.fill", withConfiguration: largeConfig) // Shock or sudden reaction
            emotionIconView.tintColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0) // Orange

        case "neutral":
            emotionIconView.image = UIImage(systemName: "face.smiling.inverse", withConfiguration: largeConfig) // Simplest neutral expression
            emotionIconView.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Gray

        case "disgust", "disgusted":
            emotionIconView.image = UIImage(systemName: "xmark.octagon.fill", withConfiguration: largeConfig) // Disgust = rejection
            emotionIconView.tintColor = UIColor(red: 0.0, green: 0.6, blue: 0.3, alpha: 1.0) // Green

        case "contempt":
            emotionIconView.image = UIImage(systemName: "hand.thumbsdown.fill", withConfiguration: largeConfig) // Represents disapproval
            emotionIconView.tintColor = UIColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0) // Purple

        default:
            emotionIconView.image = UIImage(systemName: "waveform.circle.fill", withConfiguration: largeConfig) // Default icon
            emotionIconView.tintColor = primaryPurple
        }
    }

}

// MARK: - SNResultsObserving
extension VoiceEmotionDetectorViewController: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        
        // Get the most likely classification
        var bestClassification: SNClassification? = nil
        
        // Find the classification with the highest confidence
        for classification in result.classifications {
            if let currentBest = bestClassification {
                if classification.confidence > currentBest.confidence {
                    bestClassification = classification
                }
            } else {
                bestClassification = classification
            }
        }
        
        // Update the UI with the detected emotion
        if let classification = bestClassification {
            updateEmotionDisplay(emotion: classification.identifier, confidence: Float(classification.confidence))
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Analysis error: \(error.localizedDescription)"
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension VoiceEmotionDetectorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emotionHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmotionCell", for: indexPath) as! EmotionHistoryCell
        
        let entry = emotionHistory[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        cell.configure(
            emotion: entry.emotion,
            confidence: entry.confidence,
            time: dateFormatter.string(from: entry.timestamp),
            primaryColor: primaryPurple
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

