//
//  TractPage.swift
//  godtools
//
//  Created by Devserker on 4/27/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

//  NOTES ABOUT THE COMPONENT
//  * This component must always be initialized with: init(data: XMLIndexer, withMaxHeight height: CGFloat)

class TractPage: BaseTractElement {
    
    // MARK: - Setup
    static var navbarHeight: CGFloat = 0.0
    
    static var statusbarHeight: CGFloat {
        return UIDevice.current.iPhoneX() ? CGFloat(44) : CGFloat(0)
    }
    
    override func propertiesKind() -> TractProperties.Type {
        return TractPageProperties.self
    }
    
    override func setupElement(data: XMLIndexer, startOnY yPosition: CGFloat) {
        self.elementFrame.y = yPosition
        
        let contentElements = self.xmlManager.getContentElements(data)
        
        loadElementProperties(contentElements.properties)
        loadFrameProperties()
        buildFrame()
        setupBackgroundPage()
        buildChildrenForData(contentElements.children)
        setupView(properties: contentElements.properties)
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0.0
        self.elementFrame.width = self.width
        self.elementFrame.height = self.height
    }
    
    override func elementListeners() -> [String]? {
        let properties = pageProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: ",")
    }
    
    override func startingYPos() -> CGFloat {
        return TractPage.navbarHeight + TractPage.statusbarHeight
    }
    
    // MARK: - Helpers
    
    func pageProperties() -> TractPageProperties {
        return self.properties as! TractPageProperties
    }
    
    final func setupBackgroundPage() {
        let width = BaseTractElement.screenWidth
        let height = BaseTractElement.screenHeight
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let elementProperties = pageProperties()
        
        let backgroundView = UIView(frame: frame)
        backgroundView.backgroundColor = elementProperties.backgroundColor
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        if elementProperties.backgroundImage == "" {
            return
        }
        
        let imagePath = self.manifestProperties.getResourceForFile(filename: elementProperties.backgroundImage)
        
        guard let data = NSData(contentsOfFile: imagePath) else {
            return
        }
        
        guard let image = UIImage(data: data as Data) else {
            return
        }
        
        //TODO: remove the .fill attribute and get the scale type assigned for the page
        let scaleType: TractImageConfig.ImageScaleType = UIDevice.current.iPhoneX() ? .fill : elementProperties.backgroundImageScaleType
        let imageView = buildScaledImageView(parentView: backgroundView,
                                             image: image,
                                             aligns: elementProperties.backgroundImageAlign,
                                             scaleType: scaleType)
        backgroundView.addSubview(imageView)
    }
    
    deinit {
        #if DEBUG
            print("deinit for TractPage")
        #endif
    }
    
}
