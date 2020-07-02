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


class TractPage: BaseTractElement {
    
    var pageContainer: TractPageContainer?
    
    private(set) var renderedView: UIView!
    
    // MARK: - Setup
    
    static var navbarHeight: CGFloat = 50.0
    static var statusbarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    
    //  * The only designated initializer for this class should be this one
    override init(startWithData data: XMLIndexer, height: CGFloat, manifestProperties: ManifestProperties, configurations: TractConfigurations, parallelElement: BaseTractElement?, dependencyContainer: BaseTractElementDiContainer, isPrimaryRightToLeft: Bool) {
        super.init(startWithData: data, height: height, manifestProperties: manifestProperties, configurations: configurations, parallelElement: parallelElement, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
        
        renderedView = render()
    }
    
    override init(data: XMLIndexer, startOnY yPosition: CGFloat, dependencyContainer: BaseTractElementDiContainer, isPrimaryRightToLeft: Bool) { fatalError("init(coder:) has not been implemented") }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    required init(data: XMLIndexer, parent: BaseTractElement, dependencyContainer: BaseTractElementDiContainer, isPrimaryRightToLeft: Bool) { fatalError("init(data:parent:) has not been implemented") }
    required init(data: XMLIndexer, startOnY yPosition: CGFloat, parent: BaseTractElement, elementNumber: Int, dependencyContainer: BaseTractElementDiContainer, isPrimaryRightToLeft: Bool) { fatalError("init(data:startOnY:parent:elementNumber:) has not been implemented") }
    override init(children: [XMLIndexer], startOnY yPosition: CGFloat, parent: BaseTractElement, dependencyContainer: BaseTractElementDiContainer, isPrimaryRightToLeft: Bool) { fatalError("init(children:yPosition:parent:) has not been implemented") }
    
    override func reset() {
        super.reset()
        
        if let elements = elements {
            for element in elements {
                element.reset()
            }
        }
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
        let element = TractPageContainer(children: data, startOnY: startingYPos(), parent: self, dependencyContainer: dependencyContainer, isPrimaryRightToLeft: isPrimaryRightToLeft)
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

        addBackgroundColorSubview(backgroundColor: elementProperties.backgroundColor, parentView: parent)
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
        
        guard let image = manifestProperties.getResourceForFile(filename: imageFilename) else {
            return
        }
    
        let scaleType = scaleType
        let imageView = buildScaledImageView(parentView: parentView, image: image, aligns: aligns, scaleType: scaleType)

        parentView.addSubview(imageView)
    }
    
    func showHeader() {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! TractHeader
                header.showHeader(animated: true)
                break
            }
        }
    }
    
    func hideHeader() {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isHeaderElement(element) {
                let header = element as! TractHeader
                header.hideHeader(animated: true)
                break
            }
        }
    }
    
    func showCallToAction(animated: Bool = true) {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! TractCallToAction
                callToAction.showCallToAction(animated: animated)
                break
            }
        }
    }
    
    func hideCallToAction() {
        for element in self.pageContainer!.elements! {
            if BaseTractElement.isCallToActionElement(element) {
                let callToAction = element as! TractCallToAction
                callToAction.hideCallToAction(animated: true)
                break
            }
        }
    }
}
