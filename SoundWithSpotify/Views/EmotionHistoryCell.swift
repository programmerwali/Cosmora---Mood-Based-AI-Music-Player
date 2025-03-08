//
//  EmotionHistoryCell.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 08/03/2025.
//

import UIKit

// MARK: - Custom Cell for Emotion History
class EmotionHistoryCell: UITableViewCell {
    private let containerView = UIView()
    private let emotionLabel = UILabel()
    private let timeLabel = UILabel()
    private let confidenceBar = UIProgressView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container view
        containerView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        containerView.layer.cornerRadius = 10
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 2
        contentView.addSubview(containerView)
        
        // Emotion label
        emotionLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        emotionLabel.textColor = .darkGray
        containerView.addSubview(emotionLabel)
        
        // Time label
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        containerView.addSubview(timeLabel)
        
        // Confidence bar
        confidenceBar.progressTintColor = UIColor(red: 0.5, green: 0.3, blue: 0.9, alpha: 1.0)
        confidenceBar.trackTintColor = UIColor(white: 0.9, alpha: 1.0)
        confidenceBar.layer.cornerRadius = 2
        confidenceBar.clipsToBounds = true
        containerView.addSubview(confidenceBar)
        
        // Set up constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        confidenceBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            emotionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            emotionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            emotionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            
            timeLabel.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            
            confidenceBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            confidenceBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            confidenceBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3),
            confidenceBar.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func configure(emotion: String, confidence: Float, time: String, primaryColor: UIColor) {
        emotionLabel.text = emotion.prefix(1).uppercased() + emotion.dropFirst().lowercased()
        timeLabel.text = time
        confidenceBar.progress = confidence
        confidenceBar.progressTintColor = primaryColor
    }
}

