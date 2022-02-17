//
//  MobileContentTextView.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTextView: MobileContentView {
    
    enum ViewType {
        case labelOnly
        case loadFromNib
    }
    
    private let viewType: ViewType
    
    private var textLabelRef: UILabel?
    
    let viewModel: MobileContentTextViewModelType
        
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
        
    required init(viewModel: MobileContentTextViewModelType) {
        
        self.viewModel = viewModel
       
        if viewModel.hidesStartImage && viewModel.hidesEndImage {
            self.viewType = .labelOnly
        }
        else {
            self.viewType = .loadFromNib
        }
        
        super.init(frame: UIScreen.main.bounds)
        
        // If content text doesn't have any images we will just instaniate a label rather than the entire nib.
        // Might help with performance since content:text is frequently used. ~Levi
        if viewType == .labelOnly {
            
            let textLabel: UILabel = UILabel()
            addSubview(textLabel)
            textLabel.constrainEdgesToSuperview()
            
            self.textLabelRef = textLabel
            self.textLabel = textLabel
            
            setupBinding(viewType: .labelOnly)
        }
        else if viewType == .loadFromNib {
            initializeNib()
            self.textLabelRef = textLabel
            setupBinding(viewType: .loadFromNib)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentTextView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
            rootNibView.backgroundColor = .clear
        }
    }
    
    private func setupBinding(viewType: ViewType) {
        
        let lineSpacing = CGFloat(2)
        
        textLabel.backgroundColor = UIColor.clear
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.font = viewModel.font
        textLabel.text = viewModel.text
        textLabel.textColor = viewModel.textColor
        textLabel.textAlignment = viewModel.textAlignment
        textLabel.setLineSpacing(lineSpacing: lineSpacing)
        
        let lineHeight = viewModel.font.lineHeight
        let minimumLines = viewModel.minimumLines
        
        let minimumHeight = minimumLines > 0 ? (lineHeight * minimumLines) + (lineSpacing * (minimumLines - 1)) : lineHeight
        
        textLabel.addHeightConstraint(constant: minimumHeight, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, priority: 1000)
        
        if viewType == .loadFromNib {
            
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
    
    func removeTextLabel() -> UILabel? {
        textLabelRef?.removeFromSuperview()
        return textLabelRef
    }
    
    // MARK: - MobileContentView

    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
