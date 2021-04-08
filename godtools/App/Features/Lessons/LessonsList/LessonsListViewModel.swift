//
//  LessonsListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonsListViewModel: LessonsListViewModelType {
    
    private let dataDownloader: InitialDataDownloader
    
    private var lessons: [ResourceModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfLessons: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        
        let cachedLessons: [ResourceModel] = getLessonsFromCache()
        reloadLessons(lessons: cachedLessons)
    }
    
    private func getLessonsFromCache() -> [ResourceModel] {
        
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        
        let resources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return resourceType == .lesson
        })
        
        return resources
    }
    
    private func reloadLessons(lessons: [ResourceModel]) {
        
        self.lessons = lessons
        
        numberOfLessons.accept(value: lessons.count)
    }
    
    func lessonWillAppear(index: Int) -> LessonListItemViewModelType {
        
        let resource: ResourceModel = lessons[index]
        
        return LessonListItemViewModel(
            resource: resource
        )
    }
    
    func lessonTapped(index: Int) {
        
        let resource: ResourceModel = lessons[index]
        
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(resource: resource))
    }
}
