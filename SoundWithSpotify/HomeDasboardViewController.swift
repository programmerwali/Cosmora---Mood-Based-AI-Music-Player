//
//  ViewController.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 27/02/2025.
//

import UIKit

class HomeDashboardViewController: UIViewController {
    
    // UI Components
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let menuButton = UIButton()
    private let profileImageView = UIImageView()
    private let greetingLabel = UILabel()
    private let nameLabel = UILabel()
   // private let searchBar = UISearchBar()
    private let searchBar = FilterSearchBar()
    private let collectionView: UICollectionView
    private let tabBar = UITabBar()
    let addButton = UIButton()
    
    // MARK: - Initialization
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(coder: coder)
    }
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAddButton()
        
        // Register for auth notification
           NotificationCenter.default.addObserver(self,
                                                 selector: #selector(authCompleted(_:)),
                                                 name: .spotifyAuthCompleted,
                                                 object: nil)
    }
    
    @objc private func authCompleted(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool, success else {
            // Authentication failed
            let alert = UIAlertController(title: "Authentication Failed",
                                         message: "Failed to sign in with Spotify.",
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Auth succeeded, now present the player
        let playerVC = SpotifyPlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        
        setupHeaderView()
        setupSearchBar()
        setupCollectionView()
        setupTabBar()
        setupConstraints()
    }
    
    
    
    private func setupHeaderView() {
        // Header Container
        headerView.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
        headerView.layer.cornerRadius = 0
        view.addSubview(headerView)
        
        // Title Label
        titleLabel.text = "Home Dashboard"
        titleLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.addSubview(titleLabel)
        
        // Menu Button
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .purple
        menuButton.backgroundColor = .white
        menuButton.layer.cornerRadius = 25
        headerView.addSubview(menuButton)
        
        // Profile Image
        profileImageView.image = UIImage(named: "walipfp")
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.contentMode = .scaleAspectFill
        headerView.addSubview(profileImageView)
        
        // Greeting Label
        greetingLabel.text = "Good morning!"
        greetingLabel.textColor = .white
        greetingLabel.font = UIFont.systemFont(ofSize: 16)
        headerView.addSubview(greetingLabel)
        
        // Name Label
        nameLabel.text = "Wali K" //hardcoded for now
        nameLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
        nameLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        headerView.addSubview(nameLabel)
    }
    
    private func setupSearchBar() {
        searchBar.textField.placeholder = "Want to search something..."
       // searchBar.searchBarStyle = .minimal
            //searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 5
        searchBar.clipsToBounds = true
        
//        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
//            textField.backgroundColor = .white
//            textField.textColor = .gray
//        }
        
        headerView.addSubview(searchBar)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 20
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.register(ActivityCell.self, forCellWithReuseIdentifier: "ActivityCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .white
        
        let homeItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)
        let calendarItem = UITabBarItem(title: nil, image: UIImage(systemName: "calendar"), tag: 1)
        let plusItem = UITabBarItem(title: nil, image: nil, tag: 2)
        let clockItem = UITabBarItem(title: nil, image: UIImage(systemName: "clock"), tag: 3)
        let personItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), tag: 4)
        
        tabBar.items = [homeItem, calendarItem, plusItem, clockItem, personItem]
        view.addSubview(tabBar)
        
        // Add button
        addButton.setImage(UIImage(systemName: "waveform"), for: .normal)
        addButton.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.95, alpha: 1.0)
        addButton.tintColor = .white
        addButton.layer.cornerRadius = 25
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Header View
            headerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 260),
            
            // Menu Button
            menuButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            menuButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            menuButton.widthAnchor.constraint(equalToConstant: 50),
            menuButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            profileImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Greeting Label
            greetingLabel.topAnchor.constraint(equalTo: menuButton.bottomAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            
            // Tab Bar
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 60),
            
            // Add Button
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension HomeDashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        
        switch indexPath.item {
        case 0:
            cell.configure(with: "Mood Capture", imageName: "mooddetect")
        case 1:
            cell.configure(with: "Emotional Compass", imageName: "moodcompass")
        case 2:
            cell.configure(with: "Meditation", imageName: "moodchange")
        case 3:
            cell.configure(with: "Sentiment Beats", imageName: "sentimentbeats")
        default:
            break
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell tapped at index: \(indexPath.item)")
        if indexPath.item == 0 {
            print("Attempting to navigate to voice emotion controller")
            let voiceVC = VoiceEmotionDetectorViewController()
            voiceVC.modalPresentationStyle = .fullScreen // or .pageSheet
            present(voiceVC, animated: true)
        }
    }
    


}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeDashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 60) / 2
        return CGSize(width: width, height: width)
    }
}

