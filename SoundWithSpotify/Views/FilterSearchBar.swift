
//
//  FilterSearchBar.swift
//  DKR_options_collectionview
//
//  Created by Wali Faisal on 21/02/2025.
//

import UIKit

class FilterSearchBar: UIView, UITextFieldDelegate {
    // MARK: - UI Elements
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let searchIcon = UIImage(systemName: "magnifyingglass")
        imageView.image = searchIcon
        imageView.tintColor = UIColor.systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search  status..."
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never // Removes default clear button
        textField.returnKeyType = .search
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Configure container view
        backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        addSubview(textField)
        addSubview(iconImageView)
        
        // Setup constraints with icon on the right
        NSLayoutConstraint.activate([
            // Text field
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Search icon
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Container height
            heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Setup delegates
        textField.delegate = self
    }

    
    // MARK: - Public Methods
    func setPlaceholder(_ placeholder: String) {
        textField.placeholder = placeholder
    }
    
    var textDidChangeHandler: ((String) -> Void)?
    var searchButtonClickedHandler: ((String) -> Void)?
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            textDidChangeHandler?(updatedText)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            searchButtonClickedHandler?(text)
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text {
            textDidChangeHandler?(text)
        }
    }
}
