//
//  ToolSettingsShareableItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

@MainActor
final class ToolSettingsShareableItemViewModel: ObservableObject {
    
    private let shareable: ShareableDomainModel
    private let getShareableImageUseCase: GetShareableImageUseCase
                
    @Published private(set) var imageData: OptionalImageData?
    @Published private(set) var title: String = ""
    
    init(shareable: ShareableDomainModel, getShareableImageUseCase: GetShareableImageUseCase) {
        
        self.shareable = shareable
        self.getShareableImageUseCase = getShareableImageUseCase
        self.title = shareable.title
        
        loadShareableImage(shareable: shareable)
    }
    
    private func loadShareableImage(shareable: ShareableDomainModel) {
                
        Task { [weak self] in
            
            do {
                
                let shareableImage = try await self?.getShareableImageUseCase.execute(shareable: shareable)
                
                self?.didRefreshShareableImage(shareableImage: shareableImage)
            }
            catch _ {
                
            }
        }
    }
    
    private func didRefreshShareableImage(shareableImage: ShareableImageDomainModel?) {
        
        guard let data = shareableImage?.imageData, let uiImage = UIImage(data: data) else {
            return
        }
        
        imageData = OptionalImageData(
            image: Image(uiImage: uiImage),
            imageIdForAnimationChange: shareableImage?.dataModelId
        )
    }
}
