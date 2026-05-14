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
    
    private var getBannerImageTask: Task<Void, Error>?
    
    @Published private(set) var banner: OptionalImageData?
    @Published private(set) var title: String = ""
    @Published private(set) var titleLayoutDirection: LayoutDirection = .rightToLeft
    @Published private(set) var appLanguageAvailability: String = ""
    @Published private(set) var shouldShowLessonProgress: Bool = false
    @Published private(set) var lessonProgress: Double = 0
    @Published private(set) var completionString: String = ""
    @Published private(set) var attachmentsDownloadProgressValue: Double = 0
    @Published private(set) var translationDownloadProgressValue: Double = 0
    
    init(lessonListItem: LessonListItemDomainModelInterface, getToolBannerUseCase: GetToolBannerUseCase, inMemoryDataCache: InMemoryDataCache) {
        
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
        
        if let imageData = inMemoryDataCache.getData(id: attachmentId), let image = imageData.toImage() {
            
            banner = getBanner(image: image, attachmentId: attachmentId)
        }
        else {
            
            getBannerImageTask = Task {
                
                let imageData = try await getToolBannerUseCase
                    .execute(
                        attachmentId: attachmentId
                    )
                
                if let imageData = imageData {
                    inMemoryDataCache.cacheData(id: attachmentId, data: imageData)
                }
                
                banner = getBanner(image: imageData?.toImage(), attachmentId: attachmentId)
            }
        }
    }
    
    deinit {
        getBannerImageTask?.cancel()
    }
    
    private func getBanner(image: Image?, attachmentId: String) -> OptionalImageData {
        return OptionalImageData(image: image, imageIdForAnimationChange: attachmentId)
    }
}
