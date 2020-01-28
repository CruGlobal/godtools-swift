//
//  ButtonWithIcon.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class ButtonWithIcon: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 25 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? = nil {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var iconLeft: Bool = false {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var iconRight: Bool = false {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var iconTitlePadding: Bool = false {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var iconEdgePadding: Bool = false {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var iconPadding: CGFloat = 0 {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var iconColor: UIColor = .white {
        didSet {
            if let imageView = imageView {
                if let image = imageView.image?.withRenderingMode(.alwaysTemplate) {
                    setImage(image, for: .normal)
                    imageView.tintColor = iconColor
                }
            }
        }
    }
    
    private var didPrepareForInterfaceBuilder: Bool = false
    private var didLayout: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layer.cornerRadius = cornerRadius
        invalidateLayout()
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        invalidateLayout()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: .normal)
        invalidateLayout()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        didPrepareForInterfaceBuilder = true
        invalidateLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        didLayout = true
        invalidateLayout()
    }
    
    private var viewReady: Bool {
        return didLayout || didPrepareForInterfaceBuilder
    }
    
    private func invalidateLayout() {
        
        if viewReady {
            if let titleLabel = titleLabel, let icon = image(for: .normal) {
                
                var titleSize: CGSize = titleLabel.frame.size
                if let titleText = titleLabel.text {
                    titleSize = (titleText as NSString).size(withAttributes: [NSAttributedString.Key.font: titleLabel.font as Any])
                }
                
                var iconSize: CGSize = icon.size
                if let imageView = imageView {
                    iconSize = imageView.frame.size
                }
                
                if iconLeft || iconRight {
                    
                    contentHorizontalAlignment = .left
                    
                    let titleOriginX: CGFloat = (bounds.size.width / 2) - (titleSize.width / 2) - iconSize.width
                    var iconOriginX: CGFloat = 0
                    
                    if iconLeft {
                        if iconTitlePadding {
                            iconOriginX = titleOriginX + (iconPadding * -1)
                        } else if iconEdgePadding {
                            iconOriginX = iconPadding
                        }
                    } else if iconRight {
                        if iconTitlePadding {
                            iconOriginX = titleOriginX + titleSize.width + iconSize.width + iconPadding
                        } else if iconEdgePadding {
                            iconOriginX = bounds.size.width - iconSize.width - iconPadding
                        }
                    }
                    
                    titleEdgeInsets = UIEdgeInsets(
                        top: 0,
                        left: titleOriginX,
                        bottom: 0,
                        right: 0
                    )
                    
                    imageEdgeInsets = UIEdgeInsets(
                        top: 0,
                        left: iconOriginX,
                        bottom: 0,
                        right: 0
                    )
                }
                else {
                    contentHorizontalAlignment = .center
                }
            }
        }
    }
}
