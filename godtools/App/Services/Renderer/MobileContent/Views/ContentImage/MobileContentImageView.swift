//
//  MobileContentImageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentImageView: MobileContentView {
    
    private let viewModel: MobileContentImageViewModelType
    private let imageView: UIImageView = UIImageView()
    
    required init(viewModel: MobileContentImageViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        // add image tap gesture
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(handleImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        imageView.backgroundColor = .clear
    }
    
    private func setupBinding() {
        
        imageView.semanticContentAttribute = viewModel.imageSemanticContentAttribute
        if let image = viewModel.image {
            addImage(image: image)
        }
        else {
            addEmptySpace()
        }
    }
    
    private func addImage(image: UIImage) {
        
        imageView.image = image
        
        addSubview(imageView)
        
        imageView.constrainEdgesToSuperview()
        
        let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .width,
            multiplier: image.size.height / image.size.width,
            constant: 0
        )
        
        imageView.addConstraint(aspectRatio)
    }
    
    private func addEmptySpace() {
        
        let emptyView = UIView()
        emptyView.backgroundColor = .clear
        addSubview(emptyView)
        emptyView.constrainEdgesToSuperview()
        
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
    }
    
    @objc func handleImageTapped() {
        
        let events: [String] = viewModel.imageEvents
        
        var nextParent: MobileContentView? = parent
        
        while nextParent != nil {
            nextParent?.imageTapped(events: events)
            nextParent = nextParent?.parent
        }
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
    }

    override func finishedRenderingChildren() {
        super.finishedRenderingChildren()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
