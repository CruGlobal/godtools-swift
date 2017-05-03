//
//  TractLabel.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractLabel: BaseTractElement {
    
    static let xMarginConstant = CGFloat(0.0)
    static let yMarginConstant = CGFloat(0.0)
    
    var tapView: UIView?
    var xPosition: CGFloat {
        return TractLabel.xMarginConstant
    }
    var yPosition: CGFloat {
        return self.yStartPosition + TractLabel.yMarginConstant
    }
    override var width: CGFloat {
        return (self.parent?.width)! - self.xPosition - TractLabel.xMarginConstant
    }
    
    override func setupView(properties: Dictionary<String, Any>) {
        let frame = buildFrame()
        let view = UIView(frame: frame)
        view.backgroundColor = .gtGreen
        self.view = view
        setupPressGestures()
    }
    
    override func textStyle() -> (style: String, width: CGFloat, height: CGFloat) {
        return ("tabTitle", self.width, CGFloat(0.0))
    }
    
    override func textYPadding() -> CGFloat {
        return 15.0
    }
    
    override func yEndPosition() -> CGFloat {
        return self.yStartPosition + self.height
    }
    
    fileprivate func buildFrame() -> CGRect {
        return CGRect(x: self.xPosition,
                      y: self.yPosition,
                      width: self.width,
                      height: self.height)
    }
    
    func setupPressGestures() {
        if (self.parent?.isKind(of: Card.self))! {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            
            let frame = CGRect(x: 0.0,
                               y: 0.0,
                               width: self.width,
                               height: 60.0)
            self.tapView = UIView(frame: frame)
            self.tapView?.backgroundColor = .red
            self.tapView?.addGestureRecognizer(tapGesture)
            self.tapView?.isUserInteractionEnabled = true
            
            self.view?.addSubview(self.tapView!)
        }
    }
    
    func handleGesture(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let cardView = self.parent as! Card
            cardView.changeCardState()
        }
    }

}
