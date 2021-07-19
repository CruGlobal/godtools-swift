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
        
    required init(backgroundImageModel: BackgroundImageModelType, manifestResourcesCache: ManifestResourcesCacheType, languageDirection: LanguageDirection) {
        
        self.backgroundImageModel = backgroundImageModel
        self.manifestResourcesCache = manifestResourcesCache
        self.languageDirection = languageDirection
    }
    
    var backgroundImage: UIImage? {
        guard let resource = backgroundImageModel.backgroundImage else {
            return nil
        }
        return manifestResourcesCache.getImageFromManifestResources(resource: resource)
    }
    
    var alignments: [MobileContentBackgroundImageAlignment] {
        return backgroundImageModel.backgroundImageAlignments
    }
    
    var scale: MobileContentBackgroundImageScale {
        return backgroundImageModel.backgroundImageScale
    }
    
    func getRenderPositionForBackgroundImage(container: CGRect, backgroundImage: UIImage) -> CGRect {
        
        let imageSizePixels: CGSize = CGSize(
            width: backgroundImage.size.width * backgroundImage.scale,
            height: backgroundImage.size.height * backgroundImage.scale
        )
        
        return getRenderPositionForBackgroundImage(container: container, imageSizePixels: imageSizePixels)
    }
    
    private func getRenderPositionForBackgroundImage(container: CGRect, imageSizePixels: CGSize) -> CGRect {
        
        return backgroundImageRenderer.getBackgroundImageRectForRenderingInContainer(
            container: container,
            backgroundImageSizePixels: imageSizePixels,
            scale: scale,
            align: alignments,
            languageDirection: languageDirection
        )
    }
    
    func backgroundImageWillAppear(container: CGRect) -> UIImageView? {
        
        guard let resource = backgroundImageModel.backgroundImage else {
            return nil
        }
        
        guard let backgroundImage = manifestResourcesCache.getImageFromManifestResources(resource: resource) else {
            return nil
        }
        
        let backgroundImageRect: CGRect = getRenderPositionForBackgroundImage(container: container, backgroundImage: backgroundImage)
        
        let imageView: UIImageView = UIImageView(frame: backgroundImageRect)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleToFill
        imageView.image = backgroundImage
        
        return imageView
    }
}
