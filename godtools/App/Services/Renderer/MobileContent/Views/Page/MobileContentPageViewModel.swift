//
//  MobileContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentPageViewModel: MobileContentPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    private let hidesBackgroundImage: Bool
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, hidesBackgroundImage: Bool) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.hidesBackgroundImage = hidesBackgroundImage
    }
    
    var backgroundColor: UIColor {
        return pageModel.pageColors.backgroundColor
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
               
        guard !hidesBackgroundImage else {
            return nil
        }
        
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        
        let backgroundImageNode: BackgroundImageNodeType?
        
        if pageNode.backgroundImageExists {
            backgroundImageNode = pageNode
        }
        else if manifestAttributes.backgroundImageExists {
            backgroundImageNode = manifestAttributes
        }
        else {
            backgroundImageNode = nil
        }
        
        if let backgroundImageNode = backgroundImageNode {
            return MobileContentBackgroundImageViewModel(
                backgroundImageNode: backgroundImageNode,
                manifestResourcesCache: pageModel.resourcesCache,
                languageDirection: pageModel.language.languageDirection
            )
        }
        
        return nil
    }
}
