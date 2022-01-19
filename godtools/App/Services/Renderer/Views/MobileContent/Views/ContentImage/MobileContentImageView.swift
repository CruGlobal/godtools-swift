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
        imageView.drawBorder(color: .red)
    }
    
    private func setupBinding() {
        
        viewModel.image.addObserver(self) { [weak self] (image: UIImage?) in
            
            if let image = image {
                self?.addImage(image: image)
            }
        }
        
        // TODO: What is empty space for? ~Levi
        /*
        if let image = viewModel.image {
            addImage(image: image)
        }
        else {
            addEmptySpace()
        }*/
    }
    
    private func addImage(image: UIImage) {
        
        imageView.image = image
        
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.constrainEdgesToView(view: self)
        
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
        
        super.sendEventsToAllViews(eventIds: viewModel.imageEvents, rendererState: viewModel.rendererState)
    }
    
    // MARK: - MobileContentView

    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
