//
//  MobileContentTextView.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentTextView: UIView {
    
    private let viewModel: MobileContentTextViewModelType
    
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
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
    
    private func setupLayout() {
        
        // textLabel
        textLabel.backgroundColor = UIColor.clear
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
    }
    
    private func setupBinding() {
        
        let hidesStartImage: Bool
        let hidesEndImage: Bool
        
        if let startImage = viewModel.startImage {
            startImageView.image = startImage
            hidesStartImage = false
        }
        else {
            startImageView.image = nil
            hidesStartImage = true
        }
        
        if let endImage = viewModel.endImage {
            endImageView.image = endImage
            hidesEndImage = false
        }
        else {
            endImageView.image = nil
            hidesEndImage = true
        }
        
        textLabel.font = viewModel.font
        textLabel.text = viewModel.text
        textLabel.textColor = viewModel.textColor
        textLabel.textAlignment = viewModel.textAlignment
        
        textLabel.setLineSpacing(lineSpacing: 2)
        
        updateLayoutConstraints(
            hidesStartImage: hidesStartImage,
            hidesEndImage: hidesEndImage,
            startImageSize: viewModel.startImageSize,
            endImageSize: viewModel.endImageSize
        )
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
}

