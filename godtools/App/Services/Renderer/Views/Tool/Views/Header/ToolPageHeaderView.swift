//
//  ToolPageHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderView: MobileContentView, NibBased {
    
    private let numberLabelWidthForHiddenState: CGFloat = 50
    private let trainingTipLeadingToTitleForNumberHiddenState: CGFloat = 5
    
    private var numberTextView: MobileContentTextView?
    private var titleTextView: MobileContentTextView?
    private var trainingTipView: TrainingTipView?
    private var numberLabelStartingLeadingToHeaderView: CGFloat = 0
    private var trainingTipStartingLeadingToTitle: CGFloat = 0
    private var trainingTipStartingTopToTextBackground: CGFloat = 0
    
    @IBOutlet weak private var backgroundView: UIView!
    @IBOutlet weak private var numberLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var trainingTipContainerView: UIView!
    
    @IBOutlet weak private var numberLabelLeadingToHeaderView: NSLayoutConstraint!
    @IBOutlet weak private var trainingTipTopToTextBackground: NSLayoutConstraint!
    @IBOutlet weak private var trainingTipLeadingToTitle: NSLayoutConstraint!
    @IBOutlet weak private var trainingTipBottomToView: NSLayoutConstraint!
    @IBOutlet weak private var trainingTipHeight: NSLayoutConstraint!
    
    private var numberLabelWidthConstraint: NSLayoutConstraint?
    
    let viewModel: ToolPageHeaderViewModelType
                
    required init(viewModel: ToolPageHeaderViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        loadNib()
        
        numberLabelStartingLeadingToHeaderView = numberLabelLeadingToHeaderView.constant
        trainingTipStartingLeadingToTitle = trainingTipLeadingToTitle.constant
        trainingTipStartingTopToTextBackground = trainingTipTopToTextBackground.constant
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
                    
        trainingTipContainerView.backgroundColor = .clear
        setTrainingTipHidden(hidden: true)
    }
    
    private func setupBinding() {
        
        semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        
        // backgroundView
        backgroundColor = .clear
        backgroundView.backgroundColor = viewModel.backgroundColor
        backgroundView.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        
        // number
        if let numberTextView = viewModel.getNumber(numberLabel: numberLabel) {
            self.numberTextView = numberTextView
            setNumberHidden(hidden: false)
        }
        else {
            setNumberHidden(hidden: true)
        }
        
        self.titleTextView = viewModel.getTitle(titleLabel: titleLabel)
    }
    
    private func setNumberHidden(hidden: Bool) {
        
        numberLabel.isHidden = hidden
        
        if hidden {
            addWidthConstraintToNumberLabelForHiddenState()
            numberLabelLeadingToHeaderView.constant = numberLabelWidthForHiddenState * -1
            trainingTipLeadingToTitle.constant = trainingTipLeadingToTitleForNumberHiddenState
        }
        else {
            removeWidthConstraintFromNumberLabelForVisibleState()
            numberLabelLeadingToHeaderView.constant = numberLabelStartingLeadingToHeaderView
            trainingTipLeadingToTitle.constant = trainingTipStartingLeadingToTitle
        }
        
        layoutIfNeeded()
    }
    
    private func setTrainingTipHidden(hidden: Bool) {
        
        trainingTipContainerView.isHidden = hidden
        
        let trainingTipTopConstant: CGFloat
        
        if hidden {
            
            trainingTipTopConstant = (trainingTipHeight.constant + trainingTipBottomToView.constant) * -1
        }
        else {
            
            trainingTipTopConstant = trainingTipStartingTopToTextBackground
        }
        
        trainingTipTopToTextBackground.constant = trainingTipTopConstant
        
        layoutIfNeeded()
    }
    
    private func addWidthConstraintToNumberLabelForHiddenState() {
        
        guard numberLabelWidthConstraint == nil else {
            return
        }
        
        numberLabelWidthConstraint = numberLabel.addWidthConstraint(constant: numberLabelWidthForHiddenState)
    }
    
    private func removeWidthConstraintFromNumberLabelForVisibleState() {
        
        guard let widthConstraint = numberLabelWidthConstraint else {
            return
        }
        
        numberLabel.removeConstraint(widthConstraint)
        numberLabelWidthConstraint = nil
    }

    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let trainingTipView = childView as? TrainingTipView {
            self.trainingTipView = trainingTipView
            trainingTipContainerView.addSubview(trainingTipView)
            trainingTipView.translatesAutoresizingMaskIntoConstraints = false
            trainingTipView.constrainEdgesToView(view: trainingTipContainerView)
            setTrainingTipHidden(hidden: false)
        }
    }
}
