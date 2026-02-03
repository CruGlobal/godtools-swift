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

@MainActor class ToolSettingsShareableItemViewModel: ObservableObject {
    
    private let shareable: ShareableDomainModel
    private let getShareableImageUseCase: GetShareableImageUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    @Published var imageData: OptionalImageData?
    @Published var title: String = ""
    
    init(shareable: ShareableDomainModel, getShareableImageUseCase: GetShareableImageUseCase) {
        
        self.shareable = shareable
        self.getShareableImageUseCase = getShareableImageUseCase
        self.title = shareable.title
        
        getShareableImageUseCase
            .execute(shareable: shareable)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] (imageDomainModel: ShareableImageDomainModel?) in
                
                if let imageData = imageDomainModel?.imageData, let uiImage = UIImage(data: imageData) {
                     
                    self?.imageData = OptionalImageData(
                        image: Image(uiImage: uiImage),
                        imageIdForAnimationChange: imageDomainModel?.dataModelId
                    )
                }
            })
            .store(in: &cancellables)
    }
}
