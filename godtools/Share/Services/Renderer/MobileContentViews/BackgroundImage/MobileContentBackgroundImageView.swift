//
//  MobileContentBackgroundImageView.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageView {
    
    private var viewModel: MobileContentBackgroundImageViewModel?
    private var imageView: UIImageView?
    private weak var parentView: UIView?
    
    required init() {
        
    }
    
    func reset() {
        imageView?.removeFromSuperview()
    }
    
    func configure(viewModel: MobileContentBackgroundImageViewModel, parentView: UIView) {
        
        guard let backgroundImage = viewModel.backgroundImage else {
            return
        }
        
        self.viewModel = viewModel
        self.parentView = parentView
        
        let imageView: UIImageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.image = backgroundImage
        imageView.contentMode = .scaleAspectFit
        
        let imageSize: CGSize = backgroundImage.size
        
        parentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        switch viewModel.scale {
            
        case .fitAll:
            
            imageView.contentMode = .scaleAspectFit
            imageView.constrainEdgesToSuperview()
            
            return
            
        case .fillAll:
            
            imageView.contentMode = .scaleAspectFill
            imageView.constrainEdgesToSuperview()
            
            return
            
        case .fillHorizontally:
            
            imageView.contentMode = .scaleAspectFit
            addEdgeConstraintsToImageView(imageView: imageView, parentView: parentView, leading: true, trailing: true)
            addAspectRatioToImageView(imageView: imageView, imageSize: imageSize)
            
            switch viewModel.align {
                
            case .center:
                addCenterConstraintsToImageView(imageView: imageView, parentView: parentView)
            case .start:
                break
            case .end:
                break
            case .top:
                addEdgeConstraintsToImageView(imageView: imageView, parentView: parentView, top: true)
            case .bottom:
                addEdgeConstraintsToImageView(imageView: imageView, parentView: parentView, bottom: true)
            }
            
            return
            
        case .fillVertically:
            
            imageView.contentMode = .scaleAspectFit
            addEdgeConstraintsToImageView(imageView: imageView, parentView: parentView, top: true, bottom: true)
            addAspectRatioToImageView(imageView: imageView, imageSize: imageSize)
            
            switch viewModel.align {
                
            case .center:
                addCenterConstraintsToImageView(imageView: imageView, parentView: parentView)
            case .start:
                addEdgeConstraintsToImageView(imageView: imageView, parentView: parentView, leading: true)
            case .end:
                addEdgeConstraintsToImageView(imageView: imageView, parentView: parentView, trailing: true)
            case .top:
                break
            case .bottom:
                break
            }
            
            return
        }
    }
    
    // MARK: - Adding Constraints To Image
    
    private func addEdgeConstraintsToImageView(imageView: UIImageView, parentView: UIView, leading: Bool = false, trailing: Bool = false, top: Bool = false, bottom: Bool = false) {
        
        if leading {
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: imageView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
            
            parentView.addConstraint(leading)
        }
        
        if trailing {
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: imageView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
            
            parentView.addConstraint(trailing)
        }
        
        if top {
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: imageView,
                attribute: .top,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            )
            
            parentView.addConstraint(top)
        }
        
        if bottom {
            
            let bottom: NSLayoutConstraint = NSLayoutConstraint(
                item: imageView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
            
            parentView.addConstraint(bottom)
        }
    }
    
    private func addCenterConstraintsToImageView(imageView: UIImageView, parentView: UIView) {
        
        let centerX: NSLayoutConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        )
        
        parentView.addConstraint(centerX)
        
        let centerY: NSLayoutConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        
        parentView.addConstraint(centerY)
    }
    
    private func addAspectRatioToImageView(imageView: UIImageView, imageSize: CGSize) {
        
        let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
            item: imageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .width,
            multiplier: imageSize.height / imageSize.width,
            constant: 0
        )
        
        imageView.addConstraint(aspectRatio)
    }
}
