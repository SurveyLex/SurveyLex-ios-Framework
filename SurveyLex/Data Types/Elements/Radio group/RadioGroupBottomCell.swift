//
//  RadioGroupBottomCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/12.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RadioGroupBottomCell: SurveyElementCell {

    var radioGroup: RadioGroup!
    var radioTable: MultipleChoiceView!
    var topCell: RadioGroupCell!
    
    init(radioGroup: RadioGroup, topCell: RadioGroupCell) {
        super.init()
        
        self.radioGroup = radioGroup
        self.topCell = topCell
        
        self.radioTable = makeChoiceTable()
        self.expanded = false
        
        let line = UIView()
        line.backgroundColor = .init(white: 0.84, alpha: 1)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        addSubview(line)

        line.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        line.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: radioTable.topAnchor).isActive = true
        
        /* Debugging only
         layer.borderColor = UIColor.orange.cgColor
         layer.borderWidth = 1
         */
    }

    private func makeChoiceTable() -> MultipleChoiceView {
        let choiceTable = MultipleChoiceView(radioGroup: radioGroup, parentCell: self)
        choiceTable.translatesAutoresizingMaskIntoConstraints = false
        choiceTable.isScrollEnabled = false
        addSubview(choiceTable)
        
        choiceTable.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        choiceTable.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        choiceTable.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        let bottomConstraint = choiceTable.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        bottomConstraint.priority = .init(999)
        bottomConstraint.isActive = true
        
        return choiceTable
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
