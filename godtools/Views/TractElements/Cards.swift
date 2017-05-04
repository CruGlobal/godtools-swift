//
//  Cards.swift
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

class Cards: BaseTractElement {
    
    enum CardsState {
        case open, preview
    }
    
    var cardsState = CardsState.preview
    
    var xPosition: CGFloat {
        return 0.0
    }
    var yPosition: CGFloat {
        return self.yStartPosition + BaseTractElement.Standards.yMargin
    }
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
            let yPosition = self.initialCardPosition - (deltaChange * 60)
            let yDownPosition = self.yStartPosition + (deltaChange * 60) - (deltaChange * 30)
            let element = Card(data: dictionary, startOnY: yPosition, parent: self)
            element.yDownPosition = yDownPosition
            elements.append(element)
            cardNumber += 1
        }
        
        self.elements = elements
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        self.frame = buildFrame()
        self.backgroundColor = UIColor.darkGray
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
