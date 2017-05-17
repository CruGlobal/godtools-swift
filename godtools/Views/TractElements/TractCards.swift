//
//  TractCards.swift
//  godtools
//
//  Created by Devserker on 5/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

//  NOTES ABOUT THE COMPONENT
//  * Cards is a component that is not present on the XML. The component was generate
//  because of the need to have a container to store all the cards. The cards container
//  will only store elements of the kind Card.
//  * Following the XML structure, the Cards container will always be a children of
//  TractRoot container. Also, the Cards container will always be at the same level of a
//  Header component.
//  * The height size of this component will always be the same of TractRoot.height

import Foundation
import UIKit
import SWXMLHash

class TractCards: BaseTractElement {
    
    enum CardsState {
        case open, preview
    }
    
    var cardsState = CardsState.preview
    
    var xPosition: CGFloat = 0.0
    var yPosition: CGFloat {
        return self.yStartPosition + BaseTractElement.yMargin
    }
    var constantYMarginTop: CGFloat = 60
    var constantYMarginBottom: CGFloat = 30
    override var height: CGFloat {
        get {
            return self.getMaxHeight()
        }
        set {
            // Unused
        }
    }
    var initialCardPosition: CGFloat {
        return self.height - self.yStartPosition
    }
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        var elements:Array = [BaseTractElement]()
        var cardNumber = 0
        
        for dictionary in data {
            let deltaChange = CGFloat(data.count - cardNumber)
            let yPosition = self.initialCardPosition - (deltaChange * self.constantYMarginTop)
            let yDownPosition = self.yStartPosition + (deltaChange * self.constantYMarginTop) - (deltaChange * self.constantYMarginBottom)
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            element.yDownPosition = yDownPosition
            element.cardNumber = cardNumber
            elements.append(element)
            cardNumber += 1
        }
        
        self.elements = elements
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        setupBackground()
    }
    
    func setupBackground() {
        self.backgroundColor = .clear
        
        let image = UIImage(named: self.backgroundImagePath)
        let imageView = UIImageView(image: image)
        
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        var width = image?.size.width
        var height = image?.size.height
        let ratio = width! / height!
        
        if height! > viewHeight || width! > viewWidth {
            width = viewWidth
            height = width! / ratio
        }
        
        let xPosition = (viewWidth - width!) / CGFloat(2.0)
        let yPosition = CGFloat(0.0)
        
        imageView.frame = CGRect(x: xPosition, y: yPosition, width: width!, height: height!)
        imageView.contentMode = .scaleAspectFit
        
        self.addSubview(imageView)
        self.sendSubview(toBack: imageView)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }
    
    // MARK: - Helpers
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }

}
