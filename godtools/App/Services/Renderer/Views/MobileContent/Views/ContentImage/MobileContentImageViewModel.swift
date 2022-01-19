//
//  MobileContentImageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import RequestOperation

class MobileContentImageViewModel: MobileContentImageViewModelType {
    
    private let imageModel: ContentImageModelType
    private let rendererPageModel: MobileContentRendererPageModel
    
    private var downloadImageOperation: OperationQueue?
    
    let image: ObservableValue<UIImage?> = ObservableValue(value: nil)
    
    required init(imageModel: ContentImageModelType, rendererPageModel: MobileContentRendererPageModel) {
        
        self.imageModel = imageModel
        self.rendererPageModel = rendererPageModel
        
        downloadImage { [weak self] (image: UIImage?) in
            self?.image.accept(value: image)
        }
    }
    
    deinit {
        downloadImageOperation?.cancelAllOperations()
    }
    
    private func downloadImage(completion: @escaping ((_ image: UIImage?) -> Void)) {
        
        guard let resource = imageModel.resource else {
            completion(nil)
            return
        }
        
//        if let cachedImage = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: resource) {
//            completion(cachedImage)
//            return
//        }
        
        if let attachmentModel = rendererPageModel.attachmentsRepository.getAttachment(fileFilename: resource) {
            
            downloadImageOperation = rendererPageModel.imageDownloader.download(url: attachmentModel.file) { [weak self] (result: Result<UIImage?, RequestResponseError<NoHttpClientErrorResponse>>) in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success(let image):
                        completion(image)
                    case .failure( _):
                        completion(nil)
                    }
                }

            }
            
            return
        }
        
        completion(nil)
    }
    
    /*
    var image: UIImage? {
        
        guard let resource = imageModel.resource else {
            return nil
        }
        
        print("image resource: \(resource)")
        
        let cachedImage: UIImage? = rendererPageModel.resourcesCache.getImageFromManifestResources(fileName: resource)
        
        
        let attachmentModel: AttachmentModel? = rendererPageModel.attachmentsRepository.getAttachment(fileFilename: resource)
        
        return cachedImage
    }*/
    
    var imageEvents: [MultiplatformEventId] {
        return imageModel.events
    }
    
    var rendererState: MobileContentMultiplatformState {
        return rendererPageModel.rendererState
    }
}
