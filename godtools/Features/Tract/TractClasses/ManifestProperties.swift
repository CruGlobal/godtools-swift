//
//  ManifestProperties.swift
//  godtools
//
//  Created by Pablo Marti on 6/9/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ManifestProperties: TractProperties {
    
    private let sha256FileCache: ResourcesSHA256FileCache
    
    @objc var backgroundColor = GTAppDefaultStyle.backgroundManifestColorString.getRGBAColor()
    @objc var backgroundImage: String = ""
    var backgroundImageAlign: [TractImageConfig.ImageAlign] = [.center]
    var backgroundImageScaleType: TractImageConfig.ImageScaleType = .fill
    @objc var navbarColor: UIColor?
    @objc var navbarControlColor: UIColor?
    var resources = [String: SHA256FileLocation]()
    @objc var cardBackgroundColor: UIColor?
    
    required init(sha256FileCache: ResourcesSHA256FileCache) {
        
        self.sha256FileCache = sha256FileCache
        
        super.init()
    }
    
    required init() {
        // TODO: Need to remove this initializer. ~Levi
        sha256FileCache = ResourcesSHA256FileCache()
        super.init()
    }
    
    override func defineProperties() {
        self.properties = ["backgroundColor", "backgroundImage", "navbarColor",
                           "navbarControlColor"]
    }
    
    override func customProperties() -> [String]? {
        // TODO: proper namespace handling. 'tract:' in theory may be 'page:' or something else. currently all properties that have namespace in manifest are ignored, which is not correct.
        return ["backgroundImageAlign", "backgroundImageScaleType", "tract:cardBackgroundColor"]
    }
    
    override func performCustomProperty(propertyName: String, value: String) {
        switch propertyName {
        case "backgroundImageAlign":
            setupImageAligns(kind: value)
        case "backgroundImageScaleType":
            setupImageScaleType(kind: value)
        case "resources":
            setupImageScaleType(kind: value)
        case "tract:cardBackgroundColor":
            cardBackgroundColor = value.getRGBAColor()
        default: break
        }
    }
    
    func setupImageAligns(kind: String) {
        var items: [TractImageConfig.ImageAlign] = []
        
        for value in kind.components(separatedBy: " ") {
            items.append(TractImageConfig.getImageAlignKind(string: value))
        }
        
        self.backgroundImageAlign = items
    }
    
    func setupImageScaleType(kind: String) {
        self.backgroundImageScaleType = TractImageConfig.getImageScaleType(string: kind)
    }
    
    func getResourceForFile(filename: String) -> UIImage? {
        
        if let location = resources[filename] {
           
            switch sha256FileCache.getImage(location: location) {
            case .success(let image):
                return image
            case .failure(let error):
                assertionFailure(error.localizedDescription)
                return nil
            }
        }
        
        return nil
    }
    
}
