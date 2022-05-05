//
//  OnboardPrimaryButton.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class OnboardPrimaryButton: UIButton {
    
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
        invalidateLayout()
        if let font = FontLibrary.sfProTextRegular.uiFont(size: 17) {
            titleLabel?.font = font
        }
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
            backgroundColor = UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1)
            layer.cornerRadius = 8
        }
    }
}
