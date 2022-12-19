//
//  MobileContentTextView.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTextView: MobileContentView, NibBased {
    
    enum ViewType {
        case labelOnly(label: UILabel, shouldAddLabelAsSubview: Bool)
        case loadFromNib
    }
    
    private static let defaultLineSpacing: CGFloat = 2
    private static let defaultNumberOfLines: Int = 0
    
    private let viewType: ViewType
    private let additionalLabelAttributes: MobileContentTextLabelAttributes?
    
    let viewModel: MobileContentTextViewModel
        
    @IBOutlet weak private var startImageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var endImageView: UIImageView!
    
    @IBOutlet weak private var startImageViewLeading: NSLayoutConstraint!
    @IBOutlet weak private var startImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var startImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var textLabelLeading: NSLayoutConstraint!
    @IBOutlet weak private var textLabelTrailing: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var endImageViewHeight: NSLayoutConstraint!
        
    init(viewModel: MobileContentTextViewModel, viewType: MobileContentTextView.ViewType?, additionalLabelAttributes: MobileContentTextLabelAttributes?) {
        
        self.viewModel = viewModel

        if let providedViewType = viewType {
            self.viewType = providedViewType
        }
        else if viewModel.hidesStartImage && viewModel.hidesEndImage {
            self.viewType = .labelOnly(label: UILabel(), shouldAddLabelAsSubview: true)
        }
        else {
            self.viewType = .loadFromNib
        }
        
        self.additionalLabelAttributes = additionalLabelAttributes
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        // If content text doesn't have any images we will just instaniate a label rather than the entire nib.
        // Might help with performance since content:text is frequently used. ~Levi
        
        switch self.viewType {
        case .labelOnly(let label, let shouldAddLabelAsSubview):
            if shouldAddLabelAsSubview {
                addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.constrainEdgesToView(view: self, edgeInsets: .zero)
            }
            self.textLabel = label
        case .loadFromNib:
            loadNib()
        }
        
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBinding() {
        
        let font: UIFont
        let lineSpacing: CGFloat = additionalLabelAttributes?.lineSpacing ?? MobileContentTextView.defaultLineSpacing
        let numberOfLines: Int = additionalLabelAttributes?.numberOfLines ?? MobileContentTextView.defaultNumberOfLines
        
        if let additionalLabelAttributes = self.additionalLabelAttributes {
            font = viewModel.getScaledFont(
                fontSizeToScale: additionalLabelAttributes.fontSize,
                fontWeightElseUseTextDefault: additionalLabelAttributes.fontWeight
            )
        }
        else {
            font = viewModel.font
        }
        
        textLabel.backgroundColor = UIColor.clear
        textLabel.numberOfLines = numberOfLines
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.font = font
        textLabel.text = viewModel.text
        textLabel.textColor = viewModel.textColor
        textLabel.textAlignment = viewModel.textAlignment
        textLabel.setLineSpacing(lineSpacing: lineSpacing)
        
        if viewModel.shouldUnderlineText, let labelText = viewModel.text {
            textLabel.underline(labelText: labelText)
        }
        
        let minimumLines = viewModel.minimumLines
        
        if minimumLines > 0 {
            
            let lineHeight = viewModel.font.lineHeight
            
            let minimumHeight = (lineHeight * minimumLines) + (lineSpacing * (minimumLines - 1))
            
            textLabel.addHeightConstraint(constant: minimumHeight, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, priority: 1000)
        }
        
        switch viewType {
        
        case .labelOnly( _):
            break
        
        case .loadFromNib:
            
            if let startImage = viewModel.startImage {
                startImageView.image = startImage
            }
            
            if let endImage = viewModel.endImage {
                endImageView.image = endImage
            }
            
            updateLayoutConstraints(
                hidesStartImage: viewModel.hidesStartImage,
                hidesEndImage: viewModel.hidesEndImage,
                startImageSize: viewModel.startImageSize,
                endImageSize: viewModel.endImageSize
            )
        }
    }
    
    private func updateLayoutConstraints(hidesStartImage: Bool, hidesEndImage: Bool, startImageSize: CGSize, endImageSize: CGSize) {
        
        let textLabelPaddingToImage: CGFloat = 10
        let hiddenImageSize: CGFloat = 5
        
        startImageView.isHidden = hidesStartImage
        endImageView.isHidden = hidesEndImage
        
        if hidesStartImage {
            
            startImageViewLeading.constant = hiddenImageSize * -1
            startImageViewWidth.constant = hiddenImageSize
            startImageViewHeight.constant = hiddenImageSize
            
            textLabelLeading.constant = 0
        }
        else {
            
            startImageViewLeading.constant = 0
            startImageViewWidth.constant = startImageSize.width
            startImageViewHeight.constant = startImageSize.height
            
            textLabelLeading.constant = textLabelPaddingToImage
        }
        
        if hidesEndImage {
            
            endImageViewTrailing.constant = hiddenImageSize * -1
            endImageViewWidth.constant = hiddenImageSize
            endImageViewHeight.constant = hiddenImageSize
            
            textLabelTrailing.constant = 0
        }
        else {
            
            endImageViewTrailing.constant = 0
            endImageViewWidth.constant = endImageSize.width
            endImageViewHeight.constant = endImageSize.height
            
            textLabelTrailing.constant = textLabelPaddingToImage
        }
    }
    
    func getTextLabel() -> UILabel {
        return textLabel
    }
    
    // MARK: - MobileContentView

    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
