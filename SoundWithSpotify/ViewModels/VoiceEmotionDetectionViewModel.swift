//
//  VoiceEmotionDetectionViewModel.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 12/03/2025.
//


import Foundation
import AVFoundation
import SoundAnalysis
import CoreMedia
import Combine

class VoiceEmotionDetectorViewModel: NSObject {
    
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var statusMessage = "Tap to start voice analysis"
    @Published var currentEmotion = "No emotion detected yet"
    @Published var confidenceLevel = ""
    @Published var emotionHistory: [(emotion: String, confidence: Float, timestamp: Date)] = []
    
    // MARK: - Audio Properties
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    // MARK: - Classification Properties
    private var analyzer: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupAudioSession()
        setupClassifier()
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            statusMessage = "Audio session setup failed"
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    private func setupClassifier() {
        do {
            let soundClassifier = try emotionTestRecognizer()
            
            classificationRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            
            classificationRequest?.windowDuration = CMTime(seconds: 0.975, preferredTimescale: .max)
            classificationRequest?.overlapFactor = 0.5
            
            statusMessage = "Ready to analyze your voice"
        } catch {
            statusMessage = "Failed to load sound classification model"
            print("Failed to load sound classification model: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Recording Actions
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else {
            statusMessage = "Failed to initialize audio engine"
            return
        }
        
        inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        
        guard let recordingFormat = recordingFormat else {
            statusMessage = "Failed to get recording format"
            return
        }
        
        analyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        
        guard let analyzer = analyzer, let request = classificationRequest else {
            statusMessage = "Failed to set up audio analyzer"
            return
        }
        
        do {
            try analyzer.add(request, withObserver: self)
            
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
                self?.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
            
            try audioEngine.start()
            
            isRecording = true
            statusMessage = "Listening to your voice..."
            
        } catch {
            statusMessage = "Failed to start audio analysis"
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
        statusMessage = "Voice analysis complete"
    }
    
    // MARK: - Helpers
    func formatEmotionText(_ emotion: String) -> String {
        // Capitalize first letter and make the rest lowercase
        let formatted = emotion.prefix(1).uppercased() + emotion.dropFirst().lowercased()
        return formatted
    }
    
    func getEmotionIcon(for emotion: String) -> (systemName: String, color: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)) {
        switch emotion.lowercased() {
        case "happy", "joy":
            return ("face.smiling", (1.0, 0.8, 0.0, 1.0)) // Golden
            
        case "sad", "sadness":
            return ("cloud.drizzle.fill", (0.3, 0.5, 0.8, 1.0)) // Blue
            
        case "angry", "anger":
            return ("flame.fill", (0.9, 0.2, 0.2, 1.0)) // Red
            
        case "fear", "scared":
            return ("exclamationmark.triangle.fill", (0.6, 0.0, 0.7, 1.0)) // Purple
            
        case "surprise", "surprised":
            return ("bolt.shield.fill", (1.0, 0.5, 0.0, 1.0)) // Orange
            
        case "neutral":
            return ("face.smiling.inverse", (0.5, 0.5, 0.5, 1.0)) // Gray
            
        case "disgust", "disgusted":
            return ("xmark.octagon.fill", (0.0, 0.6, 0.3, 1.0)) // Green
            
        case "contempt":
            return ("hand.thumbsdown.fill", (0.5, 0.0, 0.5, 1.0)) // Purple
            
        default:
            return ("waveform.circle.fill", (0.5, 0.3, 0.9, 1.0)) // Default purple
        }
    }
    
    // MARK: - UI Updates
    private func updateEmotionDisplay(emotion: String, confidence: Float) {
        // Update emotion and confidence values
        currentEmotion = formatEmotionText(emotion)
        confidenceLevel = "Confidence: \(Int(confidence * 100))%"
        
        // Add to history with most recent at the top
        let newEntry = (emotion: emotion, confidence: confidence, timestamp: Date())
        emotionHistory.insert(newEntry, at: 0)
    }
}

// MARK: - SNResultsObserving
extension VoiceEmotionDetectorViewModel: SNResultsObserving {
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
        statusMessage = "Analysis error: \(error.localizedDescription)"
    }
}
