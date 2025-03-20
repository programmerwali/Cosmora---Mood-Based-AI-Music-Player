
//
//  VoiceEmotionDetectorViewController.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 3/03/2025.
//

import UIKit
import Combine

class VoiceEmotionDetectorViewController: UIViewController {
    
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
    
    // MARK: - View Model
    private let viewModel = VoiceEmotionDetectorViewModel()
    
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Colors
    private let primaryPurple = UIColor(red: 0.5, green: 0.3, blue: 0.9, alpha: 1.0)
    private let secondaryPurple = UIColor(red: 0.4, green: 0.2, blue: 0.7, alpha: 1.0)
    private let lightPurple = UIColor(red: 0.85, green: 0.8, blue: 0.95, alpha: 1.0)
    private let darkPurple = UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        

        let backButton = UIBarButtonItem(
              image: UIImage(systemName: "chevron.left"),
              style: .plain,
              target: self,
              action: #selector(goBack)
          )
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame
        gradientLayer.frame = view.bounds
        
        // Apply rounded corners to record button
        recordButton.layer.cornerRadius = recordButton.frame.height / 2
        recordButton.clipsToBounds = true
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        // Status message binding
        viewModel.$statusMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.statusLabel.text = message
            }
            .store(in: &cancellables)
        
        // Recording state binding
        viewModel.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                guard let self = self else { return }
                self.recordButton.isSelected = isRecording
                
                if isRecording {
                    self.applyPulseAnimation()
                } else {
                    self.stopPulseAnimation()
                }
            }
            .store(in: &cancellables)
        
        // Emotion binding
        viewModel.$currentEmotion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotion in
                self?.emotionLabel.text = emotion
                
                // Update the icon for the emotion
                if emotion != EmotionConstants.noEmotionDetected {
                    let iconInfo = self?.viewModel.getEmotionIcon(for: emotion)
                    if let iconName = iconInfo?.systemName {
                        let largeConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .regular)
                        self?.emotionIconView.image = UIImage(systemName: iconName, withConfiguration: largeConfig)
                        
                        if let color = iconInfo?.color {
                            self?.emotionIconView.tintColor = UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        // Confidence binding
        viewModel.$confidenceLevel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] confidence in
                self?.confidenceLabel.text = confidence
            }
            .store(in: &cancellables)
        
        // History binding
        viewModel.$emotionHistory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.historyTableView.reloadData()
            }
            .store(in: &cancellables)
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
        statusLabel.text = viewModel.statusMessage
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
        emotionLabel.text = viewModel.currentEmotion
        emotionLabel.textAlignment = .center
        emotionLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        emotionLabel.textColor = darkPurple
        contentView.addSubview(emotionLabel)
        
        // Confidence Label setup
        confidenceLabel.text = viewModel.confidenceLevel
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
    
    // MARK: - Actions
    @objc private func recordButtonTapped() {
        viewModel.toggleRecording()
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
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension VoiceEmotionDetectorViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.emotionHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmotionCell", for: indexPath) as! EmotionHistoryCell
        
        let entry = viewModel.emotionHistory[indexPath.row]
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
