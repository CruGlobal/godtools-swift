//
//  MobileContentBackgroundImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@MainActor
final class MobileContentBackgroundImageViewModel {
    
    private let backgroundImageModel: BackgroundImageModel
    private let resourcesFileCache: ResourcesFileCache
    private let languageDirection: LanguageDirectionDomainModel
    private let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
            
    init(
        backgroundImageModel: BackgroundImageModel,
        resourcesFileCache: ResourcesFileCache,
        languageDirection: LanguageDirectionDomainModel
    ) {
        
        self.backgroundImageModel = backgroundImageModel
        self.resourcesFileCache = resourcesFileCache
        self.languageDirection = languageDirection
    }
    
    var backgroundImage: UIImage? {
        get async {
            
            if let fileLocation = backgroundImageModel.backgroundImageResource.toSHA256FileLocation(),
                let backgroundImage = await resourcesFileCache.cache.getUIImageNonThrowing(location: fileLocation) {
                
                return backgroundImage
            }
            else {
                
                return nil
            }
        }
    }
    
    func getRenderPositionForBackgroundImage(container: CGRect, backgroundImage: UIImage) -> CGRect? {
        
        let imageSizePixels: CGSize = CGSize(
            width: backgroundImage.size.width * backgroundImage.scale,
            height: backgroundImage.size.height * backgroundImage.scale
        )
        
        return getRenderPositionForBackgroundImage(container: container, imageSizePixels: imageSizePixels)
    }
    
    private func getRenderPositionForBackgroundImage(container: CGRect, imageSizePixels: CGSize) -> CGRect? {
        
        return backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: imageSizePixels,
            scale: backgroundImageModel.backgroundImageScale,
            horizontal: backgroundImageModel.backgroundImageAlignment.horizontal,
            vertical: backgroundImageModel.backgroundImageAlignment.vertical,
            languageDirection: languageDirection
        )
    }
    
    func renderBackgroundImageFrame(container: CGRect) async -> CGRect? {
        
        guard let backgroundImage = await self.backgroundImage else {
            return nil
        }
        
        let backgroundImageFrame: CGRect? = getRenderPositionForBackgroundImage(
            container: container,
            backgroundImage: backgroundImage
        )
        
        return backgroundImageFrame
    }
}
