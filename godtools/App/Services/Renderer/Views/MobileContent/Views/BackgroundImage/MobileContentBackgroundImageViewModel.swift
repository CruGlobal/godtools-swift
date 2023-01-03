//
//  MobileContentBackgroundImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentBackgroundImageViewModel {
    
    private let backgroundImageModel: BackgroundImageModel
    private let manifestResourcesCache: ManifestResourcesCache
    private let languageDirection: LanguageDirectionDomainModel
    private let backgroundImageRenderer: MobileContentBackgroundImageRenderer = MobileContentBackgroundImageRenderer()
        
    let backgroundImage: UIImage?
    
    init(backgroundImageModel: BackgroundImageModel, manifestResourcesCache: ManifestResourcesCache, languageDirection: LanguageDirectionDomainModel) {
        
        self.backgroundImageModel = backgroundImageModel
        self.manifestResourcesCache = manifestResourcesCache
        self.languageDirection = languageDirection
        
        if let backgroundImage = manifestResourcesCache.getUIImage(resource: backgroundImageModel.backgroundImageResource) {
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
        
        return backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: imageSizePixels,
            scale: backgroundImageModel.backgroundImageScale,
            horizontal: backgroundImageModel.backgroundImageAlignment.horizontal,
            vertical: backgroundImageModel.backgroundImageAlignment.vertical,
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
