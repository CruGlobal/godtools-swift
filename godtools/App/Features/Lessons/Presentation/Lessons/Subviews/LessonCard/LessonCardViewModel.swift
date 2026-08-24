//
//  LessonCardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

@MainActor
class LessonCardViewModel: ObservableObject {
        
    private let lessonListItem: LessonListItemDomainModelInterface
        
    @Published private(set) var banner: OptionalImageData?
    @Published private(set) var title: String = ""
    @Published private(set) var titleLayoutDirection: LayoutDirection = .rightToLeft
    @Published private(set) var appLanguageAvailability: String = ""
    @Published private(set) var shouldShowLessonProgress: Bool = false
    @Published private(set) var lessonProgress: Double = 0
    @Published private(set) var completionString: String = ""
    @Published private(set) var attachmentsDownloadProgressValue: Double = 0
    @Published private(set) var translationDownloadProgressValue: Double = 0
    
    init(
        lessonListItem: LessonListItemDomainModelInterface,
        getToolBannerUseCase: GetToolBannerUseCase,
        dataCache: DataCacheInterface
    ) {
        
        self.lessonListItem = lessonListItem
        self.title = lessonListItem.name
        self.titleLayoutDirection = lessonListItem.nameLanguageDirection == .leftToRight ? .leftToRight : .rightToLeft
        self.appLanguageAvailability = lessonListItem.availabilityInAppLanguage.availabilityString
        
        let lessonProgress = lessonListItem.lessonProgress
        switch lessonProgress {
        case .hidden:
            shouldShowLessonProgress = false
            completionString = ""
            
        case .inProgress(let progress, let progressString):
            shouldShowLessonProgress = true
            self.lessonProgress = progress
            completionString = progressString
            
        case .complete(let completeString):
            shouldShowLessonProgress = false
            completionString = completeString
        }
        
        let attachmentId: String = lessonListItem.bannerImageId
        
        loadBanner(
            getToolBannerUseCase: getToolBannerUseCase,
            dataCache: dataCache,
            attachmentId: attachmentId
        )
    }
    
    private func loadBanner(
        getToolBannerUseCase: GetToolBannerUseCase,
        dataCache: DataCacheInterface,
        attachmentId: String
    ) {
        
        Task { [weak self] in
            
            if let imageData = await dataCache.getData(id: attachmentId), let image = imageData.toImage() {
                
                self?.banner = self?.getBanner(image: image, attachmentId: attachmentId)
            }
            else {
                
                let imageData = try await getToolBannerUseCase
                    .execute(
                        attachmentId: attachmentId
                    )
                
                if let imageData = imageData {
                    await dataCache.cacheData(id: attachmentId, data: imageData)
                }
                
                self?.banner = self?.getBanner(image: imageData?.toImage(), attachmentId: attachmentId)
            }
        }
    }
    
    private func getBanner(image: Image?, attachmentId: String) -> OptionalImageData {
        return OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
    }
}
