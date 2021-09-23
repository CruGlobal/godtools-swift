//
//  MobileContentBackgroundImageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageView: UIImageView {
    
    private let boundsKeyPath: String = #keyPath(UIView.bounds)
    
    private var viewModel: MobileContentBackgroundImageViewModel?
    private var lastRenderedParentBounds: CGRect = .zero
    private var isObservingParentBoundsChanges: Bool = false
    
    required init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    func configure(viewModel: MobileContentBackgroundImageViewModel, parentView: UIView) {
        
        guard self.viewModel == nil else {
            return
        }
        
        self.viewModel = viewModel
        
        parentView.insertSubview(self, at: 0)
        backgroundColor = .clear
        contentMode = .scaleToFill
        image = viewModel.backgroundImage
        
        renderForBoundsChangeIfNeeded(parentView: parentView)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let parentView = superview {
            renderForBoundsChangeIfNeeded(parentView: parentView)
        }
    }
    
    override func didMoveToSuperview() {
        
        if let parentView = superview {
            renderForBoundsChangeIfNeeded(parentView: parentView)
        }
    }
    
    func renderForBoundsChangeIfNeeded(parentView: UIView) {
             
        let parentBounds: CGRect = parentView.bounds
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        guard !parentBounds.equalTo(lastRenderedParentBounds)  else{
            return
        }
        
        guard let backgroundImageFrame = viewModel.renderBackgroundImageFrame(container: parentBounds) else {
            return
        }
        
        frame = backgroundImageFrame
        
        lastRenderedParentBounds = parentBounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
        guard let parentView = self.superview else {
            return
        }
        
        guard let objectValue = object as? NSObject else {
            return
        }
        
        if objectValue == parentView && keyPath == boundsKeyPath {
            renderForBoundsChangeIfNeeded(parentView: parentView)
        }
    }
    
    func removeParentBoundsChangeObserver(parentView: UIView) {
        
        guard isObservingParentBoundsChanges else {
            return
        }
        
        isObservingParentBoundsChanges = false
        
        parentView.removeObserver(self, forKeyPath: boundsKeyPath, context: nil)
    }
    
    func addParentBoundsChangeObserver(parentView: UIView) {
        
        guard !isObservingParentBoundsChanges else {
            return
        }
        
        isObservingParentBoundsChanges = true
        
        parentView.addObserver(self, forKeyPath: boundsKeyPath, options: [.new], context: nil)
    }
}
