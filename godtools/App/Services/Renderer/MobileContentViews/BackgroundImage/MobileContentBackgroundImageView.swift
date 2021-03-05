//
//  MobileContentBackgroundImageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageView: NSObject {
    
    private var viewModel: MobileContentBackgroundImageViewModel?
    private var imageView: UIImageView?
    
    private var parentViewBounds: CGRect = .zero
    
    private weak var parentView: UIView?
    
    override init() {
        
        super.init()
    }
    
    func configure(viewModel: MobileContentBackgroundImageViewModel, parentView: UIView) {
                
        if let currentImageView = self.imageView {
            currentImageView.removeFromSuperview()
            self.imageView = nil
        }
        
        if let currentParentView = self.parentView {
            removeParentBoundsChangeObserver(parentView: currentParentView)
            self.parentView = nil
        }
        
        parentView.layoutIfNeeded()
        
        parentViewBounds = parentView.bounds
        
        self.viewModel = viewModel
        self.imageView = viewModel.backgroundImageWillAppear(container: parentView.bounds)
        self.parentView = parentView
        
        if let imageView = imageView {
            parentView.addSubview(imageView)
        }
                
        addParentBoundsChangeObserver(parentView: parentView)
    }
    
    private func renderForBoundsChangeIfNeeded() {
                
        guard let parentView = self.parentView else {
            return
        }
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        if !parentView.bounds.equalTo(parentViewBounds) {
            configure(viewModel: viewModel, parentView: parentView)
        }
    }
    
    // MARK: - Parent View Bounds Change Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let parentView = self.parentView else {
            return
        }
        
        guard let objectValue = object as? NSObject else {
            return
        }
        
        if objectValue == parentView && keyPath == "bounds" {
            renderForBoundsChangeIfNeeded()
        }
    }
    
    private func removeParentBoundsChangeObserver(parentView: UIView) {
        parentView.removeObserver(self, forKeyPath: "bounds", context: nil)
    }
    
    private func addParentBoundsChangeObserver(parentView: UIView) {
        parentView.addObserver(self, forKeyPath: "bounds", options: [.new], context: nil)
    }
}
