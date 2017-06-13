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
    
    static let minYPosition: CGFloat = 110.0
    static let constantYPaddingTop: CGFloat = 60
    static let constantYPaddingBottom: CGFloat = 30
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight()
        }
        set { } // Unused
    }
    
    var initialCardPosition: CGFloat {
        return self.height - self.elementFrame.y
    }
    
    // MARK: - Object properties
    
    var properties = TractCardsProperties()
    
    // MARK: - Setup
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        var normalCards = [XMLIndexer]()
        var hiddenCards = [XMLIndexer]()
        
        for dictionary in data {
            let contentElements = self.xmlManager.getContentElements(dictionary)
            let card = TractCardProperties()
            card.load(contentElements.properties)
            
            if card.hidden == true {
                hiddenCards.append(dictionary)
            } else {
                normalCards.append(dictionary)
            }
        }
        
        self.elements = [BaseTractElement]()
        buildCards(normalCards)
        buildHiddenCards(hiddenCards)
    }
    
    override func loadStyles() {
        setupBackground()
    }
    
    override func loadFrameProperties() {
        let yExternalPosition = self.elementFrame.y > TractCards.minYPosition ? self.elementFrame.y : TractCards.minYPosition
        
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
        self.elementFrame.yMarginTop = BaseTractElement.yMargin
        self.elementFrame.yMarginBottom = yExternalPosition
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

extension TractCards {
    
    func buildCards(_ cards: [XMLIndexer]) {
        var cardNumber = 0
        
        for dictionary in cards {
            let deltaChange = CGFloat(cards.count - cardNumber)
            let yPosition = self.initialCardPosition - (deltaChange * TractCards.constantYPaddingTop)
            let yDownPosition = self.elementFrame.y + (deltaChange * TractCards.constantYPaddingTop)
                - (deltaChange * TractCards.constantYPaddingBottom)
            
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            element.yDownPosition = yDownPosition
            element.properties.cardNumber = cardNumber
            self.elements?.append(element)
            
            cardNumber += 1
        }
    }
    
    func buildHiddenCards(_ cards: [XMLIndexer]) {
        for dictionary in cards {
            let yPosition = self.initialCardPosition
            let element = TractCard(data: dictionary, startOnY: yPosition, parent: self)
            self.elements?.append(element)
        }
    }
    
}
