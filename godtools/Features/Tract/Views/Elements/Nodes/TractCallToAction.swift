//
//  TractCallToAction.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCallToAction: BaseTractElement {
    
    enum CallToActionAnimationState {
        case none, show
    }
    
    // MARK: Positions constants
    
    static let yMarginConstant: CGFloat = 8.0
    static let paddingConstant: CGFloat = 10.0
    static let minHeight: CGFloat = 80.0
    
    // MARK: - Positions and Sizes
    
    let buttonSizeConstant: CGFloat = 44.0      // was 22.0 - enlarged as recommended by HIG
    let buttonSizeXMargin: CGFloat = 0.0        // was 8.0
    var buttonXPosition: CGFloat {
        return !isPrimaryRightToLeft ? self.elementFrame.finalWidth() - self.buttonSizeConstant - self.buttonSizeXMargin : buttonSizeXMargin
    }
    
    override var height: CGFloat {
        get {
            return super.height > TractCallToAction.minHeight ? super.height : TractCallToAction.minHeight
        }
        set {
            super.height = newValue
        }
    }
    
    var currentAnimation: TractCallToAction.CallToActionAnimationState = .none
    
    // MARK: - Setup
    
    override func reset() {
        super.reset()
        hideCallToAction(animated: false)
    }
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCallToActionProperties.self
    }
    
    override func loadFrameProperties() {
        guard let parent = self.parent else { return }
        let bottomConstant = TractPageContainer.marginBottom
        let minPosition = parent.getMaxHeight() - self.height - bottomConstant
        var position = self.elementFrame.y + TractCallToAction.yMarginConstant - bottomConstant
        if position < minPosition {
            position = minPosition
        }
        
        guard let previousElement = self.getPreviousElement() else { return }
        
        self.elementFrame.x = 0
        if (previousElement.isKind(of: TractHero.self)) {
            self.elementFrame.y = (UIDevice.current.iPhoneWithNotch()) ? BaseTractElement.screenHeight - (TractCallToAction.minHeight * 2) : BaseTractElement.screenHeight - TractCallToAction.minHeight
        } else {
            self.elementFrame.y = position
        }
        self.elementFrame.width = parentWidth()
        self.elementFrame.yMarginBottom = TractCallToAction.yMarginConstant
        self.elementFrame.xMargin = TractCallToAction.paddingConstant
    }
    
    override func loadStyles() {
        addArrowButton()
    }
    
    override func textStyle() -> TractTextContentProperties {
        let properties = super.textStyle()
        properties.width = self.elementFrame.finalWidth() - self.buttonSizeConstant - (self.buttonSizeXMargin * CGFloat(2))
        properties.xMargin = TractCallToAction.paddingConstant
        properties.yMargin = TractCallToAction.paddingConstant
        return properties
    }
    
    override func loadParallelElementState() {
        guard let element = self.parallelElement else {
            return
        }
        
        let callToActionElement = element as! TractCallToAction
        switch callToActionElement.currentAnimation {
        case .show:
            showCallToAction(animated: false)
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    func callToActionProperties() -> TractCallToActionProperties {
        return self.properties as! TractCallToActionProperties
    }
}

// MARK: - Actions

@objc extension TractCallToAction {
    
    func moveToNextView() {
        NotificationCenter.default.post(name: .moveToNextPageNotification, object: nil)
    }
}

// MARK: - Animations

extension TractCallToAction {
    
    func showCallToAction(animated: Bool) {
        
        currentAnimation = .show
        let bottomConstant: CGFloat = TractPage.statusbarHeight + TractPageContainer.marginBottom
        let translationY = parent!.getMaxHeight() - elementFrame.finalY() - height - bottomConstant
        let newTransform = CGAffineTransform(translationX: 0, y: translationY)
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                //animations
                self?.transform = newTransform
            }, completion: nil)
        }
        else {
            transform = newTransform
        }
    }
    
    func hideCallToAction(animated: Bool) {
        
        currentAnimation = .none
        let newTransform = CGAffineTransform(translationX: 0, y: 0.0)
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                //animations
                self?.transform = newTransform
            }, completion: nil)
        }
        else {
            transform = newTransform
        }
    }
}

// MARK: - UI

extension TractCallToAction {
    
    func addArrowButton() {
        let xPosition = self.buttonXPosition
        let yPosition = (self.height - self.buttonSizeConstant) / 2
        let origin = CGPoint(x: xPosition, y: yPosition)
        let size = CGSize(width: self.buttonSizeConstant, height: self.buttonSizeConstant)
        let buttonFrame = CGRect(origin: origin, size: size)
        
        let button = createButton(with: buttonFrame)
        
        if isPrimaryRightToLeft {
            button.transform = CGAffineTransform(rotationAngle: .pi)
        }
        self.addSubview(button)
    }
    
    private func createButton(with frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.frame = frame
        
        let image = UIImage(named: "right_arrow_blue")
        
        let controlColor = callToActionProperties().controlColor;
        let pagePrimaryColor = page?.pageProperties().primaryColor;
        
        button.setImage(image, for: UIControl.State.normal)
        button.tintColor = controlColor != nil ? controlColor : pagePrimaryColor
        button.addTarget(self, action: #selector(moveToNextView), for: UIControl.Event.touchUpInside)
        
        return button
    }
}
