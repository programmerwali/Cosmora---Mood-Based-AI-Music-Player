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

// Global variable to store the detected emotion
var globalDetectedEmotion: String = "No emotion detected"
var globalConfidenceLevel: Float = 0.0

class VoiceEmotionDetectorViewModel: NSObject {
    
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var statusMessage = "Tap to start 30-second voice recording"
    @Published var currentEmotion = "No emotion detected yet"
    @Published var confidenceLevel = ""
    @Published var emotionHistory: [(emotion: String, confidence: Float, timestamp: Date)] = []
    @Published var recordingProgress: Float = 0.0 // For tracking recording progress
    
    // MARK: - Audio Properties
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL
    private var recordingTimer: Timer?
    private var recordingDuration: TimeInterval = 30.0 // 30-second recording
    private var startTime: Date?
    
    // MARK: - Classification Properties
    private var analyzer: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    
    // MARK: - Initialization
    override init() {
        //  URL for the recording in the temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        recordingURL = tempDir.appendingPathComponent("voiceRecording.m4a")
        
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
            statusMessage = "Ready to record your voice for 30 seconds"
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
        // Delete any previous recording
        try? FileManager.default.removeItem(at: recordingURL)
        
        // Setup recorder
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            startTime = Date()
            statusMessage = "Recording your voice (30 seconds)..."
            
            // Start a timer to update progress and stop recording after 30 seconds
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self, let startTime = self.startTime else { return }
                
                let elapsedTime = Date().timeIntervalSince(startTime)
                self.recordingProgress = Float(elapsedTime / self.recordingDuration)
                
                if elapsedTime >= self.recordingDuration {
                    self.stopRecording()
                }
            }
            
        } catch {
            statusMessage = "Failed to start recording"
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        guard isRecording else { return } // Prevent multiple stops
        
        // Stop recording timer
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Stop audio recorder
        audioRecorder?.stop()
        audioRecorder = nil
        
        isRecording = false
        recordingProgress = 1.0
        statusMessage = "Analyzing your voice recording..."
        
        // Process the recorded audio
        analyzeRecordedAudio()
    }
    
    // MARK: - Audio Analysis
    private func analyzeRecordedAudio() {
        // Check if the recording file exists
        guard FileManager.default.fileExists(atPath: recordingURL.path) else {
            statusMessage = "Recording file not found"
            return
        }
        
        do {
            // Create an audio file for analysis
            let audioFile = try AVAudioFile(forReading: recordingURL)
            let format = audioFile.processingFormat
            
            // Create analyzer with the audio format
            analyzer = SNAudioStreamAnalyzer(format: format)
            
            guard let currentAnalyzer = analyzer, let request = classificationRequest else {
                statusMessage = "Failed to set up audio analyzer"
                return
            }
            
            // Dictionary to track emotion counts
            var emotionCounts: [String: (count: Int, totalConfidence: Float)] = [:]
            
            // Add request to analyzer
            try currentAnalyzer.add(request, withObserver: self)
            
            // Create a buffer for reading the audio file
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)!
            
            
            while audioFile.framePosition < audioFile.length {
                try audioFile.read(into: buffer)
                
         
                let framePosition = audioFile.framePosition
                
                // Analyze this chunk of audio
                currentAnalyzer.analyze(buffer, atAudioFramePosition: framePosition)
            }
            
            // Remove the request after analysis
            if let request = classificationRequest {
                currentAnalyzer.remove(request)
            }
            analyzer = nil
            
            // Determine the dominant emotion from emotionHistory
            if !emotionHistory.isEmpty {
           
                for entry in emotionHistory {
                    let emotion = entry.emotion
                    let existingEntry = emotionCounts[emotion]
                    let newCount = (existingEntry?.count ?? 0) + 1
                    let newTotalConfidence = (existingEntry?.totalConfidence ?? 0) + entry.confidence
                    emotionCounts[emotion] = (newCount, newTotalConfidence)
                }
                
                // Find the emotion with the highest confidence average
                var dominantEmotion = "neutral"
                var highestAvgConfidence: Float = 0
                
                for (emotion, data) in emotionCounts {
                    let avgConfidence = data.totalConfidence / Float(data.count)
                    if avgConfidence > highestAvgConfidence {
                        highestAvgConfidence = avgConfidence
                        dominantEmotion = emotion
                    }
                }
                
                // Update the global variables
                globalDetectedEmotion = dominantEmotion
                globalConfidenceLevel = highestAvgConfidence
                
                // Update display
                currentEmotion = formatEmotionText(dominantEmotion)
                confidenceLevel = "Confidence: \(Int(highestAvgConfidence * 100))%"
                statusMessage = "Analysis complete. Dominant emotion: \(formatEmotionText(dominantEmotion))"
            } else {
                statusMessage = "Analysis complete. No clear emotion detected."
                currentEmotion = "Neutral"
                globalDetectedEmotion = "neutral"
                globalConfidenceLevel = 0.0
            }
            
        } catch {
            statusMessage = "Failed to analyze recording: \(error.localizedDescription)"
            print("Failed to analyze recording: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    func formatEmotionText(_ emotion: String) -> String {

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
        // Add to history with most recent at the top
        let newEntry = (emotion: emotion, confidence: confidence, timestamp: Date())
        emotionHistory.insert(newEntry, at: 0)
    }
}

// MARK: - AVAudioRecorderDelegate
extension VoiceEmotionDetectorViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            statusMessage = "Recording failed"
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        statusMessage = "Recording error: \(error?.localizedDescription ?? "unknown error")"
    }
}

// MARK: - SNResultsObserving
extension VoiceEmotionDetectorViewModel: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        
        
        var bestClassification: SNClassification? = nil
        
      
        for classification in result.classifications {
            if let currentBest = bestClassification {
                if classification.confidence > currentBest.confidence {
                    bestClassification = classification
                }
            } else {
                bestClassification = classification
            }
        }
        
    
        if let classification = bestClassification {
            updateEmotionDisplay(emotion: classification.identifier, confidence: Float(classification.confidence))
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        statusMessage = "Analysis error: \(error.localizedDescription)"
    }
}
