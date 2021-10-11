//
//  ToolPageHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderView: MobileContentView {
    
    private let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    private let backgroundMinimumHeight: CGFloat = 65
    private let trainingTipSize: CGSize = CGSize(width: 46, height: 54)
    
    private var backgroundView: UIView = UIView(frame: .zero)
    private var numberView: MobileContentNumberView?
    private var titleView: MobileContentTitleView?
    private var trainingTipView: TrainingTipView?
    
    let viewModel: ToolPageHeaderViewModelType
                
    required init(viewModel: ToolPageHeaderViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        
        backgroundColor = .clear
        backgroundView.backgroundColor = viewModel.backgroundColor
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let numberView = childView as? MobileContentNumberView {
            self.numberView = numberView
        }
        else if let titleView = childView as? MobileContentTitleView {
            self.titleView = titleView
        }
        else if let trainingTipView = childView as? TrainingTipView {
            self.trainingTipView = trainingTipView
        }
    }
    
    override func finishedRenderingChildren() {
        renderChildren()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Add Child Views

extension ToolPageHeaderView {
    
    private func renderChildren() {
        
        let numberLabel: UILabel? = numberView?.removeTextViewTextLabel()
        let titleLabel: UILabel? = titleView?.removeTextViewTextLabel()
                
        let backgroundViewParent: UIView = self
        let numberLabelParent: UIView = backgroundView
        let titleLabelParent: UIView = numberLabelParent
        let trainingTipParent: UIView = self
        
        backgroundViewParent.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        if let numberLabel = numberLabel {
            
            numberLabelParent.addSubview(numberLabel)
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            numberLabel.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)
        }
        
        if let titleLabel = titleLabel {
            
            titleLabelParent.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        }
        
        if let trainingTipView = trainingTipView {
            
            trainingTipParent.addSubview(trainingTipView)
            trainingTipView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // background constraints
        let top = NSLayoutConstraint(
            item: backgroundView,
            attribute: .top,
            relatedBy: .equal,
            toItem: backgroundViewParent,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        let leading = NSLayoutConstraint(
            item: backgroundView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: backgroundViewParent,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing = NSLayoutConstraint(
            item: backgroundView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: backgroundViewParent,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        if trainingTipView == nil {
            
            let bottom = NSLayoutConstraint(
                item: backgroundView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: backgroundViewParent,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
            
            backgroundViewParent.addConstraint(bottom)
        }
        
        backgroundViewParent.addConstraint(top)
        backgroundViewParent.addConstraint(leading)
        backgroundViewParent.addConstraint(trailing)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: backgroundView,
            attribute: .height,
            relatedBy: .greaterThanOrEqual,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: backgroundMinimumHeight
        )
        
        heightConstraint.priority = UILayoutPriority(500)
        
        backgroundView.addConstraint(heightConstraint)
        
        // end background
        
        // number constraints
        if let numberLabel = numberLabel {
            
            let top = NSLayoutConstraint(
                item: numberLabel,
                attribute: .top,
                relatedBy: .equal,
                toItem: numberLabelParent,
                attribute: .top,
                multiplier: 1,
                constant: contentInsets.top - 9
            )
            
            let leading = NSLayoutConstraint(
                item: numberLabel,
                attribute: .leading,
                relatedBy: .equal,
                toItem: numberLabelParent,
                attribute: .leading,
                multiplier: 1,
                constant: contentInsets.left
            )
            
            numberLabelParent.addConstraint(top)
            numberLabelParent.addConstraint(leading)
        }
        
        // title constraints
        if let titleLabel = titleLabel {
            
            let top = NSLayoutConstraint(
                item: titleLabel,
                attribute: .top,
                relatedBy: .equal,
                toItem: titleLabelParent,
                attribute: .top,
                multiplier: 1,
                constant: contentInsets.top
            )
            
            let trailing = NSLayoutConstraint(
                item: titleLabel,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: titleLabelParent,
                attribute: .trailing,
                multiplier: 1,
                constant: contentInsets.right * -1
            )
            
            let bottom = NSLayoutConstraint(
                item: titleLabel,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: titleLabelParent,
                attribute: .bottom,
                multiplier: 1,
                constant: contentInsets.bottom * -1
            )
            
            titleLabelParent.addConstraint(top)
            titleLabelParent.addConstraint(trailing)
            titleLabelParent.addConstraint(bottom)
        }
        
        // connect number leading and title trailing
        if let titleLabel = titleLabel, let numberLabel = numberLabel {
            
            let leading = NSLayoutConstraint(
                item: titleLabel,
                attribute: .leading,
                relatedBy: .equal,
                toItem: numberLabel,
                attribute: .trailing,
                multiplier: 1,
                constant: contentInsets.left
            )
            
            titleLabelParent.addConstraint(leading)
        }
        else if let titleLabel = titleLabel {
            
            let leading = NSLayoutConstraint(
                item: titleLabel,
                attribute: .leading,
                relatedBy: .equal,
                toItem: titleLabelParent,
                attribute: .leading,
                multiplier: 1,
                constant: contentInsets.left
            )
            
            titleLabelParent.addConstraint(leading)
        }
        else if let numberLabel = numberLabel {
            
            let trailing = NSLayoutConstraint(
                item: numberLabel,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: numberLabelParent,
                attribute: .trailing,
                multiplier: 1,
                constant: contentInsets.right * -1
            )
            
            numberLabelParent.addConstraint(trailing)
        }
        
        // training tip constraints
        if let trainingTipView = trainingTipView {
            
            let trainingTipLeadingToTitle: CGFloat = (floor(trainingTipSize.width / 2) * -1) + 4
            
            let top = NSLayoutConstraint(
                item: trainingTipView,
                attribute: .top,
                relatedBy: .equal,
                toItem: backgroundView,
                attribute: .bottom,
                multiplier: 1,
                constant: -14
            )
            
            let bottom = NSLayoutConstraint(
                item: trainingTipView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: trainingTipParent,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
            
            trainingTipParent.addConstraint(top)
            trainingTipParent.addConstraint(bottom)
            
            if numberLabel == nil {
                
                let leading = NSLayoutConstraint(
                    item: trainingTipView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: trainingTipParent,
                    attribute: .leading,
                    multiplier: 1,
                    constant: contentInsets.left
                )
                
                trainingTipParent.addConstraint(leading)
            }
            else if let titleLabel = titleLabel {
                
                let leading = NSLayoutConstraint(
                    item: trainingTipView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: titleLabel,
                    attribute: .leading,
                    multiplier: 1,
                    constant: trainingTipLeadingToTitle
                )
                
                trainingTipParent.addConstraint(leading)
            }
            else {
                
                let leading = NSLayoutConstraint(
                    item: trainingTipView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: trainingTipParent,
                    attribute: .leading,
                    multiplier: 1,
                    constant: contentInsets.left
                )
                
                trainingTipParent.addConstraint(leading)
            }
            
            let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: trainingTipView,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: trainingTipSize.width
            )
                    
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: trainingTipView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: trainingTipSize.height
            )
                  
            trainingTipView.addConstraint(widthConstraint)
            trainingTipView.addConstraint(heightConstraint)
        }
    }
}
