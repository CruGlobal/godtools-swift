//
//  MobileContentBackgroundImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageViewModel {
    
    private let backgroundImageModel: BackgroundImageModelType
    private let manifestResourcesCache: ManifestResourcesCacheType
    private let languageDirection: LanguageDirection
    private let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
        
    let backgroundImage: UIImage?
    
    required init(backgroundImageModel: BackgroundImageModelType, manifestResourcesCache: ManifestResourcesCacheType, languageDirection: LanguageDirection) {
        
        self.backgroundImageModel = backgroundImageModel
        self.manifestResourcesCache = manifestResourcesCache
        self.languageDirection = languageDirection
        
        if let resource = backgroundImageModel.backgroundImage, let backgroundImage = manifestResourcesCache.getImageFromManifestResources(fileName: resource) {
            self.backgroundImage = backgroundImage
        }
        else {
            self.backgroundImage = nil
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
        
        guard let backgroundImageAlignment = backgroundImageModel.backgroundImageAlignment else {
            return nil
        }
        
        return backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: imageSizePixels,
            scale: backgroundImageModel.backgroundImageScale,
            alignment: backgroundImageAlignment,
            languageDirection: languageDirection
        )
    }
    
    func renderBackgroundImageFrame(container: CGRect) -> CGRect? {
        
        guard let backgroundImage = self.backgroundImage else {
            return nil
        }
        
        let backgroundImageFrame: CGRect? = getRenderPositionForBackgroundImage(container: container, backgroundImage: backgroundImage)
        
        return backgroundImageFrame
    }
}
