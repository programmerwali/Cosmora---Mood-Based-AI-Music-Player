//
//  MeditationChatViewController.swift
//  SoundWithSpotify
//
//  Created by Wali Faisal on 20/03/2025.
//



import UIKit

class MeditationChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    let tableView = UITableView()
    let inputContainerView = UIView()
    let inputTextField = UITextField()
    let sendButton = UIButton()
    
    // Define colors for the purple theme
    let darkPurple = UIColor(red: 89/255, green: 57/255, blue: 148/255, alpha: 1)
    let lightPurple = UIColor(red: 169/255, green: 143/255, blue: 243/255, alpha: 1)
    let veryLightPurple = UIColor(red: 236/255, green: 231/255, blue: 255/255, alpha: 1)
    let pinkAccent = UIColor(red: 246/255, green: 114/255, blue: 235/255, alpha: 1)
    let backgroundColor = UIColor(red: 246/255, green: 241/255, blue: 255/255, alpha: 1)

    var messages: [(String, Bool)] = [] // (Message, isUser)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Add a welcome message
        messages.append(("✨ Hey there! I'm your mood meditation guide. How are you feeling today? ✨", false))
        tableView.reloadData()
    }

    func setupUI() {
        // Set up main view
        view.backgroundColor = backgroundColor
        title = "Mood Meditation"
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.barTintColor = darkPurple
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            
            // For iOS 15+
            if #available(iOS 15.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = darkPurple
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                navigationBar.standardAppearance = appearance
                navigationBar.scrollEdgeAppearance = appearance
            }
        }
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Set up input container
        inputContainerView.backgroundColor = veryLightPurple
        inputContainerView.layer.cornerRadius = 25
        inputContainerView.layer.shadowColor = UIColor.black.cgColor
        inputContainerView.layer.shadowOffset = CGSize(width: 0, height: -3)
        inputContainerView.layer.shadowOpacity = 0.1
        inputContainerView.layer.shadowRadius = 5
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainerView)

        // Set up text field
        inputTextField.placeholder = "Share how you're feeling..."
        inputTextField.backgroundColor = .white
        inputTextField.layer.cornerRadius = 20
        inputTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: inputTextField.frame.height))
        inputTextField.leftViewMode = .always
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        inputTextField.font = UIFont.systemFont(ofSize: 16)
        inputContainerView.addSubview(inputTextField)

        // Set up send button
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = darkPurple
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputContainerView.addSubview(sendButton)

        // Set constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -10),

            inputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            inputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inputContainerView.heightAnchor.constraint(equalToConstant: 60),

            inputTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 10),
            inputTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 10),
            inputTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -10),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -10),

            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor, constant: -15),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            UIView.animate(withDuration: 0.3) {
                self.inputContainerView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight + self.view.safeAreaInsets.bottom)
                self.tableView.contentInset.bottom = keyboardHeight
                self.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight
                
                // Scroll to the bottom
                if self.messages.count > 0 {
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.inputContainerView.transform = .identity
            self.tableView.contentInset.bottom = 0
            self.tableView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    @objc func sendMessage() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        messages.append((text, true))
        tableView.reloadData()
        
        // Scroll to the bottom to show the new message
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        inputTextField.text = ""
        fetchMeditationResponse(for: text)
    }

    func fetchMeditationResponse(for query: String) {
        
        let url = URL(string: "\(APIConstants.geminiBaseURL)/\(APIConstants.geminiModel):generateContent?key=\(APIConstants.geminiAPIKey)")!

        
//        let requestBody: [String: Any] = [
//            "contents": [
//                [
//                    "role": "user",
//                    "parts": [
//                        ["text": """
//                        You are a Gen Z-friendly meditation guide and a highly qualified mental health expert. You hold a PhD in psychology and are a licensed psychologist specializing in mindfulness, meditation, and emotional well-being. Your approach is warm, engaging, and emotionally intelligent, using casual language, emojis, and an empathetic tone to create a safe and supportive space for the user.
//
//                        1. **Expert Emotional Guidance:** Detect emotions through conversation. Instead of assuming how the user feels, ask thoughtful, open-ended questions to understand their emotional state. If they are sad, provide comfort and validation before guiding them toward relief. If they are anxious, help them slow down and regain control. If they are happy, amplify their joy with excitement and positivity. Adjust your responses naturally based on their mood.
//
//                        2. **Conversational & Counseling Approach:** Use engaging, friendly language while maintaining professionalism. Counsel the user with emotional intelligence—validate their experiences, ask reflective questions, and help them process their emotions in a supportive way before introducing mindfulness techniques.
//
//                        3. **Personalized Meditation & Mindfulness Support:** Once the user’s mood is clear, recommend scientifically-backed meditation, breathing exercises, or mindfulness techniques tailored to their emotional state. Keep instructions simple and easy to follow, ensuring they feel empowered to try them.
//
//                        4. **Encouraging & Uplifting Tone:** Keep responses under 4-5 sentences while maintaining a warm, engaging, and conversational tone. Ensure every interaction feels like a meaningful conversation rather than a robotic response. Your goal is to make the user feel heard, supported, and guided toward inner peace in a way that fits their current emotional state.
//
//                        Now, based on the following query, engage with the user accordingly: \(query)
//                        """]
//                    ]
//                ]
//            ],
//            "generationConfig": [
//                "temperature": 0.7,
//                "maxOutputTokens": 200
//            ]
//        ]
        
        let detectedEmotion = globalDetectedEmotion
        let emotionIntro: String
        if detectedEmotion == "No emotion detected" {
            emotionIntro = """
            Let's start by understanding how you're feeling today. I'll ask you a few quick questions to get a sense of your mood. 😊

            1️⃣ How has your day been so far—anything exciting or challenging?
            2️⃣ If you had to describe your current mood in one word, what would it be?

            Feel free to answer as much or as little as you like!
            """
        } else {
            emotionIntro = """
            I noticed that you were feeling \"\(detectedEmotion)\" according to the Mood Check recorder page. If that still resonates with you, let's talk about it. If not, feel free to share how you're feeling now. 💙
            """
        }

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": """
                        You are a Gen Z-friendly meditation guide and a highly qualified mental health expert. You hold a PhD in psychology and are a licensed psychologist specializing in mindfulness, meditation, and emotional well-being. Your approach is warm, engaging, and emotionally intelligent, using casual language, emojis, and an empathetic tone to create a safe and supportive space for the user.

                        1. **Expert Emotional Guidance:** Detect emotions through conversation. If no emotion has been detected, ask up to 4-5 thoughtful, open-ended questions to understand the user's emotional state. Make it feel like a natural, friendly conversation. If they are sad, provide comfort and validation before guiding them toward relief. If they are anxious, help them slow down and regain control. If they are happy, amplify their joy with excitement and positivity.

                        2. **Conversational & Counseling Approach:** Use engaging, friendly language while maintaining professionalism. Counsel the user with emotional intelligence—validate their experiences, ask reflective questions, and help them process their emotions in a supportive way before introducing mindfulness techniques.

                        3. **Personalized Meditation & Mindfulness Support:** Once the user’s mood is clear, recommend scientifically-backed meditation, breathing exercises, or mindfulness techniques tailored to their emotional state. Keep instructions simple and easy to follow, ensuring they feel empowered to try them.

                        4. **Encouraging & Uplifting Tone:** Keep responses under 4-5 sentences while maintaining a warm, engaging, and conversational tone. Ensure every interaction feels like a meaningful conversation rather than a robotic response. Your goal is to make the user feel heard, supported, and guided toward inner peace in a way that fits their current emotional state.

                        \(emotionIntro)

                        Now, based on the following query, engage with the user accordingly: \(query)
                        """]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 200
            ]
        ]


        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        // Show loading indicator
        let loadingMessage = "✨ Vibing with that..."
        messages.append((loadingMessage, false))
        tableView.reloadData()
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        let loadingIndex = messages.count - 1

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Remove the loading message
                if self.messages.count > loadingIndex {
                    self.messages.remove(at: loadingIndex)
                }
            }
            
            if let error = error {
                print("Error fetching response: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.messages.append(("Oops! My vibe check failed 😅 Let's try again?", false))
                    self.tableView.reloadData()
                    
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
                return
            }
            
            guard let data = data else { return }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw response: \(jsonString)")
            }
            
            do {
                if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let candidates = jsonData["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let firstPart = parts.first,
                   let botResponse = firstPart["text"] as? String {

                    DispatchQueue.main.async {
                        self.messages.append((botResponse, false))
                        self.tableView.reloadData()
                        
                        // Scroll to the bottom to show the response
                        if self.messages.count > 0 {
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.messages.append(("The vibes are off right now. Let's try again later? 💜", false))
                        self.tableView.reloadData()
                        
                        if self.messages.count > 0 {
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.messages.append(("Ugh, tech problems 🙄 Let's reset and try again!", false))
                    self.tableView.reloadData()
                    
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
        
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ChatCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
            cell?.backgroundColor = .clear
            cell?.selectionStyle = .none
        }
        
        let message = messages[indexPath.row]
        let isUser = message.1
        
        // Clear any existing subviews
        cell?.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let bubbleView = UIView()
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set gradient for user messages
        if isUser {
            bubbleView.layer.cornerRadius = 20
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [darkPurple.cgColor, pinkAccent.cgColor]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.cornerRadius = 20
            gradientLayer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            
            bubbleView.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            bubbleView.backgroundColor = lightPurple
            bubbleView.layer.cornerRadius = 20
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
        
        // Add shadow to bubble
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 3)
        bubbleView.layer.shadowOpacity = 0.1
        bubbleView.layer.shadowRadius = 4
        
        let messageLabel = UILabel()
        messageLabel.text = message.0
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        
        if isUser {
            messageLabel.textColor = .white
        } else {
            messageLabel.textColor = .white
        }
        
        cell?.contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            bubbleView.topAnchor.constraint(equalTo: cell!.contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: cell!.contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: cell!.contentView.widthAnchor, multiplier: 0.75)
        ])
        
        if isUser {
            bubbleView.trailingAnchor.constraint(equalTo: cell!.contentView.trailingAnchor, constant: -16).isActive = true
        } else {
            bubbleView.leadingAnchor.constraint(equalTo: cell!.contentView.leadingAnchor, constant: 16).isActive = true
        }
        
        // Need to update gradient frame when layout changes
        if isUser {
            cell?.layoutIfNeeded()
            if let gradientLayer = bubbleView.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = bubbleView.bounds
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Update gradient frame when cell will display
        if let bubbleView = cell.contentView.subviews.first,
           let gradientLayer = bubbleView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bubbleView.bounds
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        textField.resignFirstResponder()
        return true
    }
}
