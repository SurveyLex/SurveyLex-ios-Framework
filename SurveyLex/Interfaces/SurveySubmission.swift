//
//  SurveySubmission.swift
//  SurveyLex Demo
//
//  Created by Jia Rui Shan on 2019/7/4.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class SurveySubmission: UIViewController {

    var surveyViewController: SurveyViewController!
    
    private var titleLabel: UILabel!
    private var finishIcon: UIImageView!
    private var spinner: UIActivityIndicatorView!
    private var progressBar: UIProgressView!
    private var shareButton: UIButton!
    private var reviewResponse: UIButton!
    private var buttonStack: UIStackView!
    
    private var timeoutTimer: Timer?
    private var isDisplayingAlert = false
    
    var percentageCompleted: Float = 0.0 {
        didSet {
            self.progressBar.setProgress(percentageCompleted, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        finishIcon = {
            let imageView = UIImageView()
            imageView.image = #imageLiteral(resourceName: "baseline-check")
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            return imageView
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.hidesWhenStopped = true
            spinner.color = .lightGray
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: finishIcon.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: finishIcon.centerYAnchor).isActive = true
            
            return spinner
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Release to Submit"
            label.font = .systemFont(ofSize: 26)
            label.textColor = .darkGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20).isActive = true
            label.topAnchor.constraint(equalTo: finishIcon.bottomAnchor, constant: 12).isActive = true
            
            return label
        }()
        
        progressBar = {
            let bar = UIProgressView()
            bar.progressTintColor = surveyViewController.theme.medium
            bar.trackTintColor = .init(white: 0.91, alpha: 1)
            bar.progress = 0
            bar.isHidden = true
            bar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bar)
            
            bar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            bar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            bar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
            
            return bar
        }()
        
        reviewResponse = {
            let button = UIButton(type: .system)
            
            button.addTarget(self, action: #selector(review), for: .touchUpInside)
            button.setTitle("Review", for: .normal)
            button.layer.borderColor = surveyViewController.theme.medium.cgColor
            button.tintColor = surveyViewController.theme.medium
            button.layer.borderWidth = 1
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }()
        
        shareButton = {
            let button = UIButton(type: .system)
            
            button.setTitle("Share", for: .normal)
            button.addTarget(self, action: #selector(shareSurvey), for: .touchUpInside)
            button.backgroundColor = surveyViewController.theme.medium
            button.tintColor = .white
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }()
        
        buttonStack = {
            
            // Format the buttons in the same way
            for button in [reviewResponse!, shareButton!] {
                button.layer.cornerRadius = 5
                button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            }
            
            let stack = UIStackView(arrangedSubviews: [reviewResponse, shareButton])
            stack.spacing = 20
            stack.distribution = .fillEqually
            stack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stack)
            
            stack.leftAnchor.constraint(equalTo: progressBar.leftAnchor).isActive = true
            stack.rightAnchor.constraint(equalTo: progressBar.rightAnchor).isActive = true
            stack.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
            
            stack.isHidden = true
            
            return stack
        }()
        
        // Add self as an observer for upload responses.
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name: FRAGMENT_UPLOAD_COMPLETE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uploadError), name: FRAGMENT_UPLOAD_FAIL, object: nil)
    }
    
    /// Scroll to the first page of the survey.
    @objc private func review() {
        surveyViewController.setViewControllers([surveyViewController.fragmentPages[0]],
                                                direction: .reverse,
                                                animated: true,
                                                completion: nil)
    }
    
    @objc private func shareSurvey() {
        let shareItem: [Any] = ["I've just taken the survey '\(self.surveyViewController.surveyData.title)'! Feel free to take it at", URL(string: SURVEY_URL_PREFIX + "/" + surveyViewController.survey.surveyID)!]
        let ac = UIActivityViewController(activityItems: shareItem, applicationActivities: nil)
        if let ppc = ac.popoverPresentationController {
            ppc.sourceView = shareButton
            ppc.sourceRect = shareButton.frame
        }
        present(ac, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        surveyViewController.fragmentIndex = surveyViewController.fragmentPages.count
        updateProgress()
        
        UIView.transition(with: surveyViewController.navigationMenu,
                          duration: 0.2,
                          options: .curveEaseInOut,
                          animations: {
                            self.surveyViewController.navigationMenu.alpha = 0.0
                            self.surveyViewController.navigationMenu.isUserInteractionEnabled = false
                          }, completion: nil)
    }

    @objc private func uploadError() {
        if isDisplayingAlert { return }
        
        let alert = UIAlertController(title: "Network Failure", message: "We are unable to upload your response. Please check your internet connection.", preferredStyle: .alert)
        alert.view.tintColor = surveyViewController.theme.dark
        
        // Button action
        let handler: (UIAlertAction) -> Void = { action in
            switch action.title {
            case "Retry":
                self.surveyViewController.fragmentPages.forEach { page in
                    if page.fragmentData.needsReupload { page.uploadResponse() }
                }
            case "Submit Later":
                self.review()
            default:
                break
            }
        }
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: "Submit Later", style: .cancel, handler: handler))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// Refreshes the upload progress and updates the front-end.
    @objc private func updateProgress() {
        
        guard surveyViewController.survey.mode == .submission else {
            self.titleLabel.text = "Not in Submission Mode!"
            return
        }
        
        let uploadedFragments = surveyViewController.fragmentPages.filter { page in
            
            if page.fragmentData.needsReupload {
                page.uploadResponse()
            }
            
            return page.fragmentData.uploaded
        }
        
        let uploaded = uploadedFragments.count
        
        debugMessage("Begin submission process, with \(uploaded) / \(surveyViewController.fragmentPages.count) fragments already uploaded, at indices \(uploadedFragments.map { $0.pageIndex })")
        
        DispatchQueue.main.async {
            self.percentageCompleted = Float(uploaded) / Float(self.surveyViewController.fragmentPages.count)
            if uploaded == self.surveyViewController.fragmentPages.count {
                self.spinner.stopAnimating()
                self.titleLabel.text = "Submitted"
                self.finishIcon.isHidden = false
                self.progressBar.isHidden = true
                self.buttonStack.isHidden = false
                self.surveyViewController.surveyData.submittedOnce = true
            } else {
                self.spinner.startAnimating()
                self.titleLabel.text = "Submitting response..."
                self.progressBar.isHidden = false
                self.finishIcon.isHidden = true
                self.buttonStack.isHidden = true
                self.surveyViewController.surveyData.submittedOnce = false
            }
        }
    }
}

