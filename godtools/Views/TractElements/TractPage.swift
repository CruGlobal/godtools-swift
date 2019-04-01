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
    
    var pageContainer: TractPageContainer?
    
    // MARK: - Setup
    static var navbarHeight: CGFloat = 0.0
    
    static var statusbarHeight: CGFloat {
        return UIDevice.current.iPhoneWithNotch() ? TractViewController.iPhoneXStatusBarHeight : CGFloat(0)
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
        buildPageContainer(data: contentElements.children)
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
        return TractPage.statusbarHeight
    }
    
    func buildPageContainer(data: [XMLIndexer]) {
        self.elements = [BaseTractElement]()
        let element = TractPageContainer(children: data, startOnY: startingYPos(), parent: self)
        self.elements!.append(element)
        self.height = element.elementFrame.yEndPosition()
        self.pageContainer = element
    }
    
    // MARK: - Helpers
    
    func pageProperties() -> TractPageProperties {
        return self.properties as! TractPageProperties
    }
    
    final func setupBackgroundPage() {

        let elementProperties = pageProperties()
        let parent = addBackgroundColorSubview(backgroundColor: manifestProperties.backgroundColor, parentView: self)
        addBackgroundImageSubview(imageFilename: manifestProperties.backgroundImage, scaleType: manifestProperties.backgroundImageScaleType, aligns: manifestProperties.backgroundImageAlign, parentView: parent)

        addBackgroundColorSubview(backgroundColor: UIColor.clear, parentView: parent)
        addBackgroundImageSubview(imageFilename: elementProperties.backgroundImage, scaleType: elementProperties.backgroundImageScaleType, aligns: elementProperties.backgroundImageAlign, parentView: parent)
    }

    @discardableResult final func addBackgroundColorSubview(backgroundColor: UIColor, parentView: UIView) -> UIView {
        let width = BaseTractElement.screenWidth
        let height = BaseTractElement.screenHeight
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)

        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor
        view.clipsToBounds = true
        parentView.addSubview(view)
        
        return view
    }

    final func addBackgroundImageSubview(imageFilename: String, scaleType: TractImageConfig.ImageScaleType, aligns: [TractImageConfig.ImageAlign], parentView: UIView) {
        if imageFilename == "" {
            return
        }
        let imagePath = self.manifestProperties.getResourceForFile(filename: imageFilename)
        guard let data = NSData(contentsOfFile: imagePath),
            let image = UIImage(data: data as Data) else {
                return
        }

        let scaleType = scaleType
        let imageView = buildScaledImageView(parentView: parentView, image: image, aligns: aligns, scaleType: scaleType)

        parentView.addSubview(imageView)
    }

    
}
