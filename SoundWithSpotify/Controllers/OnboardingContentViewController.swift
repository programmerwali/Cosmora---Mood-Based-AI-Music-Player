//
//  OnboardingContentViewController.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 08/03/2025.
//

import UIKit

// MARK: - OnboardingContentViewController
class OnboardingContentViewController: UIViewController {
    var page: OnboardingPage!
    var pageIndex: Int = 0
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Setup gradient background
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0.6, green: 0.6, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.8, green: 0.7, blue: 0.9, alpha: 1.0).cgColor
        ]
        view.layer.insertSublayer(gradient, at: 0)
        
        // Configure image view
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: page.imageName)
        
        // Configure labels
        titleLabel.text = page.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        descriptionLabel.text = page.description
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
}
