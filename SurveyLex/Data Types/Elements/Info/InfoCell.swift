//
//  InfoCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/30.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that displays an info screen. Info screens are designed to occupy an *entire* fragment.
class InfoCell: SurveyElementCell {

    /// The `Info` object which the current cell is presenting.
    var infoData: Info!
    
    private var title: UITextView!
    private var separator: UIView!
    private var content: UITextView!
    private var continueButton: UIButton!
    
    
    // MARK: UI setup
    
    init(info: Info) {
        super.init()
        
        infoData = info
        title = makeTitle()
        separator = makeSeparator()
        content = makeContentText()
        continueButton = makeContinueButton()
    }
    
    private func makeTitle() -> UITextView {
        let titleText = UITextView()
        titleText.text = infoData.title
        if titleText.text.isEmpty {
            titleText.text = "Note"
        }
        titleText.format(as: .title, theme: infoData.theme)
        titleText.textAlignment = .center
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)
        
        titleText.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                       constant: 40).isActive = true
        titleText.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                        constant: SIDE_PADDING).isActive = true
        titleText.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                         constant: -SIDE_PADDING).isActive = true
        
        return titleText
    }
    
    private func makeSeparator() -> UIView {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor(white: 0.9, alpha: 1)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLine)
        
        separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorLine.widthAnchor.constraint(equalToConstant: SEPARATOR_WIDTH).isActive = true
        separatorLine.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        separatorLine.topAnchor.constraint(equalTo: title.bottomAnchor,
                                           constant: 20).isActive = true
        return separatorLine
    }
    
    private func makeContentText() -> UITextView {
        let content = UITextView()
        content.text = infoData.content
        content.format(as: .consentText, theme: infoData.theme)
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        
        content.topAnchor.constraint(equalTo: separator.bottomAnchor,
                                     constant: 20).isActive = true
        content.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                      constant: 30).isActive = true
        content.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                       constant: -30).isActive = true
        
        return content
    }
    
    private func makeContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 4
        button.backgroundColor = infoData.theme.medium
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.heightAnchor.constraint(equalToConstant: 49).isActive = true
        button.widthAnchor.constraint(equalToConstant: 220).isActive = true
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self,
                         action: #selector(buttonLifted(_:)),
                         for: [.touchCancel, .touchUpInside, .touchUpOutside, .touchDragExit])
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        addSubview(button)
        
        button.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: content.bottomAnchor,
                                    constant: 32).isActive = true
        button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                       constant: -40).isActive = true
        
        return button
    }
    
    // MARK: Control handlers
    
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.backgroundColor = infoData.theme.dark
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        UIView.transition(with: sender,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: { sender.backgroundColor = self.infoData.theme.medium
                          },
                          completion: nil)
    }
    
    @objc private func nextPage() {
        let _ = infoData.parentView?.flipPageIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
