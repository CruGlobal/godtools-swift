//
//  Cards.swift
//  godtools
//
//  Created by Devserker on 5/2/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class Cards: BaseTractElement {
    
    var xPosition: CGFloat {
        return 0.0
    }
    var yPosition: CGFloat {
        return self.yStartPosition + BaseTractElement.Standards.yMargin
    }
    
    override var height: CGFloat {
        get {
            return self.getMaxHeight() - self.yStartPosition
        }
        set {
            // Unused
        }
    }
    
    init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement) {
        super.init()
        self.parent = parent
        self.yStartPosition = yPosition
        buildChildrenForData(children)
        setupView(properties: Dictionary<String, Any>())
    }
    
    override func buildChildrenForData(_ data: [XMLIndexer]) {
        var yPosition: CGFloat = 0.0
        var elements:Array = [BaseTractElement]()
        var currentCard = 0
        
        for dictionary in data {
            yPosition = self.height - (CGFloat(data.count - currentCard) * 80)
            let element = Card(data: dictionary, startOnY: yPosition, parent: self)
            elements.append(element)
            currentCard += 1
        }
        
        self.elements = elements
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.darkGray
        self.view = view
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yPosition + self.height
    }

}
