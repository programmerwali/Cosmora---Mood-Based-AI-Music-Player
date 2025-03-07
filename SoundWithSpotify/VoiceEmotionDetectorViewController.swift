import UIKit
import AVFoundation
import SoundAnalysis
import CoreMedia

class VoiceEmotionDetectorViewController: UIViewController, AVAudioRecorderDelegate {
    
    // UI elements
    private let recordButton = UIButton()
    private let statusLabel = UILabel()
    private let emotionLabel = UILabel()
    private let confidenceLabel = UILabel()
    private let emotionIconView = UIImageView()
    private let historyTableView = UITableView()
    
    // Audio recording properties
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false
    private var recordingURL: URL?
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    // Sound classification properties
    private var analyzer: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    
    // History of detected emotions
    private var emotionHistory: [(emotion: String, confidence: Float, timestamp: Date)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        setupClassifier()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Emotion Test Recognizer"
        
        // Record button setup
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.setTitle("Stop Recording", for: .selected)
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.backgroundColor = .systemBlue
        recordButton.layer.cornerRadius = 25
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        // Status label setup
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = "Ready to record"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(statusLabel)
        
        // Emotion label setup
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        emotionLabel.text = "No emotion detected yet"
        emotionLabel.textAlignment = .center
        emotionLabel.font = UIFont.boldSystemFont(ofSize: 24)
        view.addSubview(emotionLabel)
        
        // Confidence label setup
        confidenceLabel.translatesAutoresizingMaskIntoConstraints = false
        confidenceLabel.text = ""
        confidenceLabel.textAlignment = .center
        confidenceLabel.font = UIFont.systemFont(ofSize: 14)
        confidenceLabel.textColor = .systemGray
        view.addSubview(confidenceLabel)
        
        // Emotion icon view
        emotionIconView.translatesAutoresizingMaskIntoConstraints = false
        emotionIconView.contentMode = .scaleAspectFit
        emotionIconView.image = UIImage(systemName: "waveform")
        emotionIconView.tintColor = .systemGray
        view.addSubview(emotionIconView)
        
        // History table view
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmotionCell")
        historyTableView.dataSource = self
        historyTableView.delegate = self
        view.addSubview(historyTableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Emotion icon
            emotionIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emotionIconView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            emotionIconView.widthAnchor.constraint(equalToConstant: 100),
            emotionIconView.heightAnchor.constraint(equalToConstant: 100),
            
            // Emotion label
            emotionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emotionLabel.topAnchor.constraint(equalTo: emotionIconView.bottomAnchor, constant: 20),
            emotionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emotionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Confidence label
            confidenceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confidenceLabel.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 8),
            confidenceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confidenceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Status label
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: confidenceLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Record button
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            recordButton.widthAnchor.constraint(equalToConstant: 200),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            
            // History table view
            historyTableView.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 30),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            historyTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        // Correct way to use the Core ML model generated from Create ML
        do {
            // Use the generated model class directly instead of generic MLModel
            // When you add the .mlmodel file to Xcode, it generates a Swift class
            // with the same name as your model
            let soundClassifier = try emotionTestRecognizer()
            
            // Create a sound classification request using the model's prediction interface
            classificationRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            
            // Configure the request to match your training parameters
            // These values should match what you set in Create ML
            classificationRequest?.windowDuration = CMTime(seconds: 0.975 , preferredTimescale: .max) // From your screenshot
            classificationRequest?.overlapFactor = 0.5     // 50% overlap from your screenshot
            
            statusLabel.text = "Emotion classifier loaded successfully"
        } catch {
            statusLabel.text = "Failed to load sound classification model: \(error.localizedDescription)"
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
        // Initialize audio engine for real-time analysis
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else {
            statusLabel.text = "Failed to initialize audio engine"
            return
        }
        
        inputNode = audioEngine.inputNode
        
        // Set up the audio format - make sure it matches what your model expects
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        
        guard let recordingFormat = recordingFormat else {
            statusLabel.text = "Failed to get recording format"
            return
        }
        
        // Create the analyzer with the correct format
        analyzer = SNAudioStreamAnalyzer(format: recordingFormat)
        
        guard let analyzer = analyzer, let request = classificationRequest else {
            statusLabel.text = "Failed to set up audio analyzer"
            return
        }
        
        do {
            // Add the request to the analyzer with this view controller as the observer
            try analyzer.add(request, withObserver: self)
            
            // Install a tap on the input node to get audio buffers
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
                // Fixed: Properly use CMTime for audio frame position
                self?.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
            
            // Start the audio engine
            try audioEngine.start()
            
            isRecording = true
            recordButton.isSelected = true
            statusLabel.text = "Listening for emotions..."
            
            // Add pulse animation to record button
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.recordButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.recordButton.backgroundColor = .systemRed
            })
            
        } catch {
            statusLabel.text = "Failed to start audio analysis: \(error.localizedDescription)"
            print("Failed to start audio analysis: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
//    private func stopRecording() {
//        // Stop the audio engine and remove the tap
//        if let inputNode = inputNode {
//            inputNode.removeTap(onBus: 0)
//        }
//        
//        audioEngine?.stop()
//        audioEngine = nil
//        
//        // Stop the analysis
//        if let analyzer = analyzer, let request = classificationRequest {
//            analyzer.remove(request)
//        }
//        analyzer = nil
//        
//        isRecording = false
//        recordButton.isSelected = false
//        statusLabel.text = "Recording stopped"
//        
//        // Stop animation
//        UIView.animate(withDuration: 0.2, animations: {
//            self.recordButton.transform = .identity
//            self.recordButton.backgroundColor = .systemBlue
//        })
//    }
    
    
    private func stopRecording() {
        guard isRecording else { return } // Prevent multiple stops

        // Remove the tap on the input node
        inputNode?.removeTap(onBus: 0)
        
        // Stop the audio engine safely
        audioEngine?.stop()
        audioEngine = nil
        
        // Remove requests from the analyzer
        if let analyzer = analyzer, let request = classificationRequest {
            analyzer.remove(request)
        }
        analyzer = nil

        isRecording = false
        recordButton.isSelected = false
        statusLabel.text = "Recording stopped"

        // Stop button animation
        UIView.animate(withDuration: 0.2) {
            self.recordButton.transform = .identity
            self.recordButton.backgroundColor = .systemBlue
        }
    }

    // MARK: - UI Updates
    
    private func updateEmotionDisplay(emotion: String, confidence: Float) {
        // Update UI on main thread
        DispatchQueue.main.async {
            self.emotionLabel.text = emotion
            self.confidenceLabel.text = "Confidence: \(Int(confidence * 100))%"
            
            // Add to history
            let newEntry = (emotion: emotion, confidence: confidence, timestamp: Date())
            self.emotionHistory.insert(newEntry, at: 0)
            self.historyTableView.reloadData()
            
            // Update icon based on emotion
            switch emotion.lowercased() {
            case "happy", "joy":
                self.emotionIconView.image = UIImage(systemName: "face.smiling.fill")
                self.emotionIconView.tintColor = .systemYellow
            case "sad", "sadness":
                self.emotionIconView.image = UIImage(systemName: "face.sad.fill")
                self.emotionIconView.tintColor = .systemBlue
            case "angry", "anger":
                self.emotionIconView.image = UIImage(systemName: "face.grimace.fill")
                self.emotionIconView.tintColor = .systemRed
            case "fear", "scared":
                self.emotionIconView.image = UIImage(systemName: "face.concerned.fill")
                self.emotionIconView.tintColor = .systemPurple
            case "surprise", "surprised":
                self.emotionIconView.image = UIImage(systemName: "face.dashed.fill")
                self.emotionIconView.tintColor = .systemOrange
            case "neutral":
                self.emotionIconView.image = UIImage(systemName: "face.neutral.fill")
                self.emotionIconView.tintColor = .systemGray
            case "disgust", "disgusted":
                self.emotionIconView.image = UIImage(systemName: "face.scrunched.fill")
                self.emotionIconView.tintColor = .systemGreen
            case "contempt":
                self.emotionIconView.image = UIImage(systemName: "face.smirk.fill")
                self.emotionIconView.tintColor = .systemIndigo
            default:
                self.emotionIconView.image = UIImage(systemName: "waveform")
                self.emotionIconView.tintColor = .systemGray
            }
        }
    }
}

// MARK: - SNResultsObserving

extension VoiceEmotionDetectorViewController: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // Handle the results from the sound classification
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmotionCell", for: indexPath)
        
        let entry = emotionHistory[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        let timeString = dateFormatter.string(from: entry.timestamp)
        let confidencePercent = Int(entry.confidence * 100)
        
        cell.textLabel?.text = "\(timeString): \(entry.emotion) (\(confidencePercent)%)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Emotion History"
    }
}





//
//
////
////  VoiceEmotionDetectorViewController.swift
////  SoundWithSpotify
////
////  Created by Wali Faisal on 03/03/2025.
////
//
//import UIKit
//import AVFoundation
//import CoreML
//
//
//class VoiceEmotionDetectorViewController: UIViewController {
//    
//    // MARK: - Properties
//    
//    private let headerView = UIView()
//    private let titleLabel = UILabel()
//    private let backButton = UIButton()
//    private let instructionLabel = UILabel()
//    private let recordButton = UIButton()
//    private let statusLabel = UILabel()
//    private let emotionContainerView = UIView()
//    private let emotionImageView = UIImageView()
//    private let emotionLabel = UILabel()
//    private let playbackButton = UIButton()
//    private let progressView = UIProgressView()
//    
//    private var audioRecorder: AVAudioRecorder?
//    private var audioPlayer: AVAudioPlayer?
//    private var recordingURL: URL?
//    private var timer: Timer?
//    private var recordingDuration: TimeInterval = 10.0 // Default recording time in seconds
//    private var currentTime: TimeInterval = 0.0
//    
//    // MARK: - Emotion Detection Model
//    
//    private let emotionClassifier = try? emotionTestRecognizer() // CoreML model
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupAudioSession()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        stopRecording()
//        stopPlayback()
//    }
//    
//    // MARK: - UI Setup
//    
//    private func setupUI() {
//        view.backgroundColor = .white
//        
//        setupHeaderView()
//        setupInstructionLabel()
//        setupRecordButton()
//        setupStatusLabel()
//        setupProgressView()
//        setupEmotionContainer()
//        setupPlaybackButton()
//        setupConstraints()
//    }
//    
//    private func setupHeaderView() {
//        headerView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
//        view.addSubview(headerView)
//        
//        // Title Label
//        titleLabel.text = "Voice Emotion Detection"
//        titleLabel.textColor = .white
//        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        headerView.addSubview(titleLabel)
//        
//        // Back Button
//        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backButton.tintColor = .white
//        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//        headerView.addSubview(backButton)
//    }
//    
//    private func setupInstructionLabel() {
//        instructionLabel.text = "Speak naturally for 10 seconds to detect your emotion"
//        instructionLabel.textColor = .darkGray
//        instructionLabel.font = UIFont.systemFont(ofSize: 16)
//        instructionLabel.textAlignment = .center
//        instructionLabel.numberOfLines = 0
//        view.addSubview(instructionLabel)
//    }
//    
//    private func setupRecordButton() {
//        recordButton.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
//        recordButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
//        recordButton.contentHorizontalAlignment = .fill
//        recordButton.contentVerticalAlignment = .fill
//        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
//        view.addSubview(recordButton)
//    }
//    
//    private func setupStatusLabel() {
//        statusLabel.text = "Tap microphone to start recording"
//        statusLabel.textColor = .darkGray
//        statusLabel.font = UIFont.systemFont(ofSize: 14)
//        statusLabel.textAlignment = .center
//        view.addSubview(statusLabel)
//    }
//    
//    private func setupProgressView() {
//        progressView.progressTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
//        progressView.trackTintColor = .lightGray
//        progressView.progress = 0.0
//        view.addSubview(progressView)
//    }
//    
//    private func setupEmotionContainer() {
//        emotionContainerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
//        emotionContainerView.layer.cornerRadius = 20
//        emotionContainerView.isHidden = true
//        view.addSubview(emotionContainerView)
//        
//        emotionImageView.contentMode = .scaleAspectFit
//        emotionImageView.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
//        emotionContainerView.addSubview(emotionImageView)
//        
//        emotionLabel.textAlignment = .center
//        emotionLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        emotionLabel.textColor = .darkGray
//        emotionContainerView.addSubview(emotionLabel)
//    }
//    
//    private func setupPlaybackButton() {
//        playbackButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
//        playbackButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
//        playbackButton.isHidden = true
//        playbackButton.addTarget(self, action: #selector(playbackButtonTapped), for: .touchUpInside)
//        view.addSubview(playbackButton)
//    }
//    
//    private func setupConstraints() {
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
//        recordButton.translatesAutoresizingMaskIntoConstraints = false
//        statusLabel.translatesAutoresizingMaskIntoConstraints = false
//        progressView.translatesAutoresizingMaskIntoConstraints = false
//        emotionContainerView.translatesAutoresizingMaskIntoConstraints = false
//        emotionImageView.translatesAutoresizingMaskIntoConstraints = false
//        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
//        playbackButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            // Header View
//            headerView.topAnchor.constraint(equalTo: view.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            headerView.heightAnchor.constraint(equalToConstant: 120),
//            
//            // Back Button
//            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
//            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
//            backButton.widthAnchor.constraint(equalToConstant: 30),
//            backButton.heightAnchor.constraint(equalToConstant: 30),
//            
//            // Title Label
//            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
//            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
//            
//            // Instruction Label
//            instructionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 40),
//            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            // Record Button
//            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            recordButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 50),
//            recordButton.widthAnchor.constraint(equalToConstant: 100),
//            recordButton.heightAnchor.constraint(equalToConstant: 100),
//            
//            // Status Label
//            statusLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
//            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            // Progress View
//            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
//            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
//            progressView.heightAnchor.constraint(equalToConstant: 4),
//            
//            // Emotion Container
//            emotionContainerView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 40),
//            emotionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            emotionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
//            emotionContainerView.heightAnchor.constraint(equalToConstant: 150),
//            
//            // Emotion Image
//            emotionImageView.topAnchor.constraint(equalTo: emotionContainerView.topAnchor, constant: 20),
//            emotionImageView.centerXAnchor.constraint(equalTo: emotionContainerView.centerXAnchor),
//            emotionImageView.widthAnchor.constraint(equalToConstant: 60),
//            emotionImageView.heightAnchor.constraint(equalToConstant: 60),
//            
//            // Emotion Label
//            emotionLabel.topAnchor.constraint(equalTo: emotionImageView.bottomAnchor, constant: 10),
//            emotionLabel.leadingAnchor.constraint(equalTo: emotionContainerView.leadingAnchor, constant: 20),
//            emotionLabel.trailingAnchor.constraint(equalTo: emotionContainerView.trailingAnchor, constant: -20),
//            
//            // Playback Button
//            playbackButton.topAnchor.constraint(equalTo: emotionContainerView.bottomAnchor, constant: 20),
//            playbackButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            playbackButton.widthAnchor.constraint(equalToConstant: 50),
//            playbackButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//    
//    // MARK: - Audio Setup
//    
//    private func setupAudioSession() {
//        do {
//            let session = AVAudioSession.sharedInstance()
//            try session.setCategory(.playAndRecord, mode: .default)
//            try session.setActive(true)
//            session.requestRecordPermission { [weak self] allowed in
//                DispatchQueue.main.async {
//                    if !allowed {
//                        self?.showPermissionAlert()
//                    }
//                }
//            }
//        } catch {
//            print("Failed to set up audio session: \(error)")
//            showErrorAlert(message: "Failed to set up audio recording")
//        }
//    }
//    
//    private func setupRecorder() -> Bool {
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        recordingURL = documentsPath.appendingPathComponent("voiceRecording.m4a")
//        
//        let settings: [String: Any] = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 44100.0,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//        
//        do {
//            guard let url = recordingURL else { return false }
//            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//            audioRecorder?.prepareToRecord()
//            return true
//        } catch {
//            print("Error setting up recorder: \(error)")
//            showErrorAlert(message: "Failed to set up audio recording")
//            return false
//        }
//    }
//    
//    // MARK: - Recording and Playback
//    
//    private func startRecording() {
//        if setupRecorder() {
//            audioRecorder?.record()
//            startTimer()
//            
//            // Update UI
//            recordButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
//            recordButton.tintColor = .red
//            statusLabel.text = "Recording... \(Int(recordingDuration)) seconds left"
//            emotionContainerView.isHidden = true
//            playbackButton.isHidden = true
//        }
//    }
//    
//    private func stopRecording() {
//        audioRecorder?.stop()
//        timer?.invalidate()
//        progressView.progress = 0
//        
//        // Update UI
//        recordButton.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
//        recordButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
//    }
//    
//    private func startTimer() {
//        currentTime = 0
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//    }
//    
//    @objc private func updateTimer() {
//        currentTime += 0.1
//        progressView.progress = Float(currentTime / recordingDuration)
//        statusLabel.text = "Recording... \(Int(recordingDuration - currentTime)) seconds left"
//        
//        if currentTime >= recordingDuration {
//            stopRecording()
//            analyzeRecording()
//        }
//    }
//    
//    private func analyzeRecording() {
//        statusLabel.text = "Analyzing your emotional state..."
//        
//        // process the audio with CoreML
//       
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self, let url = self.recordingURL else { return }
//            
//            // Simulate processing time
//            Thread.sleep(forTimeInterval: 2)
//            
//            // Process with CoreML
//            let emotion = self.processAudioWithCoreML(audioURL: url)
//            
//            DispatchQueue.main.async {
//                self.displayEmotion(emotion: emotion)
//                self.playbackButton.isHidden = false
//            }
//        }
//    }
//    
//    private func processAudioWithCoreML(audioURL: URL) -> String {
//        // This is where you would use your CoreML model to analyze the audio
//        // For now, we'll return a random emotion as a placeholder
//        
//        // In a real implementation, you would:
//        // 1. Extract audio features using AVAudioEngine
//        // 2. Create an MLFeatureProvider with those features
//        // 3. Use your EmotionClassifier model to predict the emotion
//        
//        let emotions = ["Happy", "Sad", "Angry", "Neutral", "Surprised", "Fearful"]
//        return emotions.randomElement() ?? "Neutral"
//        
//        // Note: Real implementation would look something like:
//        /*
//        do {
//            // Create audio buffer
//            let audioFile = try AVAudioFile(forReading: audioURL)
//            let format = audioFile.processingFormat
//            
//            // Create feature value from audio
//            let featureValue = try MLFeatureValue(audioFileURL: audioURL,
//                                         channelHint: 0,
//                                         sampleRate: format.sampleRate,
//                                         seconds: 10)
//            
//            // Create input for model
//            let audioFeature = try MLDictionaryFeatureProvider(dictionary: [
//                "audioFeaturePrint": featureValue
//            ])
//            
//            // Get prediction
//            let prediction = try emotionClassifier?.prediction(from: audioFeature)
//            let emotion = prediction?.featureValue(for: "classLabel")?.stringValue ?? "Unknown"
//            
//            return emotion
//        } catch {
//            print("Error processing audio: \(error)")
//            return "Error"
//        }
//        */
//    }
//    
//    private func displayEmotion(emotion: String) {
//        // Show the detected emotion
//        emotionContainerView.isHidden = false
//        emotionLabel.text = emotion
//        
//        // Set appropriate image based on emotion
//        var imageName = "questionmark"
//        
//        switch emotion.lowercased() {
//        case "happy":
//            imageName = "face.smiling"
//        case "sad":
//            imageName = "face.sad"
//        case "angry":
//            imageName = "face.angry"
//        case "fearful":
//            imageName = "face.concerned"
//        case "surprised":
//            imageName = "face.surprise"
//        case "neutral":
//            imageName = "face.normal"
//        default:
//            imageName = "questionmark"
//        }
//        
//        emotionImageView.image = UIImage(systemName: imageName)
//        statusLabel.text = "Analysis complete"
//    }
//    
//    private func playRecording() {
//        guard let url = recordingURL else { return }
//        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.delegate = self
//            audioPlayer?.play()
//            playbackButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
//        } catch {
//            print("Playback error: \(error)")
//            showErrorAlert(message: "Failed to play recording")
//        }
//    }
//    
//    private func stopPlayback() {
//        audioPlayer?.stop()
//        playbackButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
//    }
//    
//    // MARK: - Button Actions
//    
//    @objc private func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    @objc private func recordButtonTapped() {
//        if audioRecorder?.isRecording == true {
//            stopRecording()
//            analyzeRecording()
//        } else {
//            startRecording()
//        }
//    }
//    
//    @objc private func playbackButtonTapped() {
//        if audioPlayer?.isPlaying == true {
//            stopPlayback()
//        } else {
//            playRecording()
//        }
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func showPermissionAlert() {
//        let alert = UIAlertController(
//            title: "Microphone Access Required",
//            message: "Please allow microphone access in Settings to use voice emotion detection",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }
//        })
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alert, animated: true)
//    }
//    
//    private func showErrorAlert(message: String) {
//        let alert = UIAlertController(
//            title: "Error",
//            message: message,
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - AVAudioPlayerDelegate
//extension VoiceEmotionDetectorViewController: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        playbackButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
//    }
//}
//
//// MARK: - EmotionClassifier
//// This is a placeholder
//class EmotionClassifier {
//    func prediction(from features: MLFeatureProvider) throws -> MLFeatureProvider? {
//       
//        return nil
//    }
//}
