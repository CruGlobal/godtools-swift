//
//  MobileContentImageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentImageView: MobileContentView {
    
    private let viewModel: MobileContentImageViewModel
    
    private var imageView: UIImageView?
    private var emptyView: UIView?
    
    init(viewModel: MobileContentImageViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        if let image = viewModel.image {
            addImage(image: image, contentViewWidth: viewModel.imageWidth)
        }
        else {
            addEmptySpace()
        }
    }
    
    @objc func handleImageTapped() {
        
        super.viewTapped()
    }
    
    // MARK: - MobileContentView

    override var heightConstraintType: MobileContentViewHeightConstraintType {
        
        guard emptyView == nil else {
            return .constrainedToChildren
        }
        
        guard let imageSize = viewModel.image?.size else {
            return .constrainedToChildren
        }
        
        switch viewModel.imageWidth {
        
        case .percentageOfContainer(let value):
            return .lessThanOrEqualToWidthPercentageSizeOfContainer(widthPercentageSizeOfContainer: value, maintainsAspectRatioSize: imageSize)
        
        case .points(let value):
            return .lessThanOrEqualToWidthPointSize(widthPointSize: value, maintainsAspectRatioSize: imageSize)
        }
    }
}

// MARK: - Add Image

extension MobileContentImageView {
    
    private func addImage(image: UIImage, contentViewWidth: MobileContentViewWidth) {
        
        guard imageView == nil else {
            return
        }
        
        let imageView: UIImageView = UIImageView()
        
        self.imageView = imageView
        
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.constrainEdgesToView(view: self)
                
        // add image tap gesture
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
}

// MARK: - Add Empty Space

extension MobileContentImageView {
    
    private func addEmptySpace() {
        
        guard emptyView == nil else {
            return
        }
        
        let parentView: UIView = self
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        parentView.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.constrainEdgesToView(view: parentView)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: emptyView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 30
        )
        heightConstraint.priority = UILayoutPriority(1000)
        emptyView.addConstraint(heightConstraint)
        
        self.emptyView = emptyView
    }
}
