
//
//  OnboardingViewController.swift
//  Cosmora
//
//  Created by Wali Faisal on 27/02/2025.
//

import UIKit



// MARK: - OnboardingViewController
class OnboardingViewController: UIViewController {
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(imageName: "onboarding1", title: "Discover Cosmic Tunes", description: "Let the universe choose the perfect soundtrack for your mood."),
        OnboardingPage(imageName: "onboarding2", title: "AI-Powered Playlists", description: "Advanced AI maps your emotions to celestial soundscapes."),
        OnboardingPage(imageName: "onboarding3", title: "Explore the Sound Galaxy", description: "Venture into a universe of personalized music recommendations.")
    ]
    
    private var pageViewController: UIPageViewController!
    private var pageControl: UIPageControl!
    private var skipButton: UIButton!
    private var nextButton: UIButton!
    private var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        setupPageControl()
        setupButtons()
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let firstVC = createOnboardingContentViewController(at: 0) {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        // Add pageViewController as child
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
    }
    
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = .white
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
            //pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupButtons() {
        // Skip Button
        skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        
        // Next Button
        nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.backgroundColor = .white
        nextButton.layer.cornerRadius = 22
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        // Start Button
        startButton = UIButton(type: .system)
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.black, for: .normal)
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 22
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        startButton.isHidden = true
        
        // Add buttons to view
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        view.addSubview(startButton)
        
        // Configure constraints
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            skipButton.widthAnchor.constraint(equalToConstant: 80),
            skipButton.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createOnboardingContentViewController(at index: Int) -> OnboardingContentViewController? {
        guard index >= 0 && index < pages.count else { return nil }
        
        let contentVC = OnboardingContentViewController()
        contentVC.page = pages[index]
        contentVC.pageIndex = index
        return contentVC
    }
    
    @objc private func skipTapped() {
        // Go to the last page or finish onboarding
        finishOnboarding()
    }
    
    @objc private func nextTapped() {
        // Go to the next page
        guard let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController,
              let nextVC = createOnboardingContentViewController(at: currentVC.pageIndex + 1) else {
            return
        }
        
        pageViewController.setViewControllers([nextVC], direction: .forward, animated: true)
        updateUIForCurrentPage(nextVC.pageIndex)
    }
    
    @objc private func startTapped() {
        finishOnboarding()
    }
    
    private func finishOnboarding() {
        // Here you would dismiss the onboarding and show your main app
        // For example:
         let mainVC = HomeDashboardViewController()
         UIApplication.shared.windows.first?.rootViewController = mainVC
         UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        // For now, we'll just print a message
        print("Onboarding completed")
    }
    
    private func updateUIForCurrentPage(_ index: Int) {
        pageControl.currentPage = index
        
        // Show/hide buttons based on page index
        let isLastPage = index == pages.count - 1
        skipButton.isHidden = isLastPage
        nextButton.isHidden = isLastPage
        startButton.isHidden = !isLastPage
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? OnboardingContentViewController else { return nil }
        let previousIndex = contentVC.pageIndex - 1
        return createOnboardingContentViewController(at: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? OnboardingContentViewController else { return nil }
        let nextIndex = contentVC.pageIndex + 1
        return createOnboardingContentViewController(at: nextIndex)
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController {
            updateUIForCurrentPage(currentVC.pageIndex)
        }
    }
}
