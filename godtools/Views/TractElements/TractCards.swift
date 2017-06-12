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
//  TractPage container. Also, the Cards container will always be at the same level of a
//  Header component.
//  * The height size of this component will always be the same of TractPage.height

import Foundation
import UIKit
import SWXMLHash

class TractCards: BaseTractElement {
        
    // MARK: - Positions and Sizes
    
    var xPosition: CGFloat = 0.0
    
    let minYPosition: CGFloat = 110.0
    
    var constantYMarginTop: CGFloat = 60
    
    var constantYMarginBottom: CGFloat = 30
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight()
        }
        set { } // Unused
    }
    
    var initialCardPosition: CGFloat {
        return self.height - self.elementFrame.yOrigin
    }
    
    // MARK: - Object properties
    
    var properties = TractCardsProperties()
    
    // MARK: - Setup
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        var elements:Array = [BaseTractElement]()
        var cardNumber = 0
        
        var normalCards = [XMLIndexer]()
        var hiddenCards = [XMLIndexer]()
        
        for dictionary in data {
            if (dictionary.element?.attribute(by: "hidden")) != nil && dictionary.element?.attribute(by: "hidden")?.text == "true" {
                hiddenCards.append(dictionary)
            } else {
                normalCards.append(dictionary)
            }
        }
        
        for dictionary in normalCards {
            let deltaChange = CGFloat(normalCards.count - cardNumber)
            let yPosition = self.initialCardPosition - (deltaChange * self.constantYMarginTop)
            let yDownPosition = self.elementFrame.yOrigin + (deltaChange * self.constantYMarginTop) - (deltaChange * self.constantYMarginBottom)
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            element.yDownPosition = yDownPosition
            element.properties.cardNumber = cardNumber
            elements.append(element)
            cardNumber += 1
        }
        
        for dictionary in hiddenCards {
            let yPosition = self.initialCardPosition
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            elements.append(element)
        }
        
        self.elements = elements
    }
    
    override func loadStyles() {
        setupBackground()
    }
    
    override func loadFrameProperties() {
        let yExternalPosition = self.elementFrame.yOrigin > self.minYPosition ? self.elementFrame.yOrigin : self.minYPosition
        
        self.elementFrame.x = self.xPosition
        self.elementFrame.y = self.elementFrame.yOrigin
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
        self.elementFrame.yMarginBottom = self.yExternalPosition
    }
    
    // MARK: - UI
    
    func setupBackground() {
        self.backgroundColor = .clear

        guard let image = self.page?.properties.styleProperties.backgroundImage else {
            return
        }
        let imageView = UIImageView(image: image)
        
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        var width = image.size.width
        var height = image.size.height
        let ratio = width / height
        
        if height > viewHeight || width > viewWidth {
            width = viewWidth
            height = width / ratio
        }
        
        let xPosition = (viewWidth - width) / CGFloat(2.0)
        let yPosition: CGFloat = 0.0
        
        imageView.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        imageView.contentMode = .scaleAspectFit
        
        self.addSubview(imageView)
        self.sendSubview(toBack: imageView)
    }

}
