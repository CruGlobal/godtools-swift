//
//  LessonsListViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class LessonsListViewModel: NSObject, LessonsListViewModelType {
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    
    private var lessons: [ResourceModel] = Array()
    
    private weak var flowDelegate: FlowDelegate?
    
    let numberOfLessons: ObservableValue<Int> = ObservableValue(value: 0)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let didEndRefreshing: Signal = Signal()
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        
        super.init()
        
        let cachedLessons: [ResourceModel] = getLessonsFromCache()
        
        if cachedLessons.isEmpty {
            isLoading.accept(value: true)
        }
        else {
            reloadLessons(lessons: cachedLessons)
        }
        
        setupBinding()
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                if cachedResourcesAvailable {
                    self?.reloadLessonsFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                self?.didEndRefreshing.accept()
                self?.isLoading.accept(value: false)
                if error == nil {
                    self?.reloadLessonsFromCache()
                }
            }
        }
    }
    
    private func getLessonsFromCache() -> [ResourceModel] {
        
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        
        let resources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return resourceType == .lesson
        })
        
        return resources
    }
    
    private func reloadLessonsFromCache() {
        let cachedLessons: [ResourceModel] = getLessonsFromCache()
        reloadLessons(lessons: cachedLessons)
    }
    
    private func reloadLessons(lessons: [ResourceModel]) {
        
        if lessons.count > 0 {
            isLoading.accept(value: false)
        }
        
        self.lessons = lessons
        
        numberOfLessons.accept(value: lessons.count)
    }
    
    func lessonWillAppear(index: Int) -> LessonListItemViewModelType {
        
        let resource: ResourceModel = lessons[index]
        
        return LessonListItemViewModel(
            resource: resource,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService
        )
    }
    
    func lessonTapped(index: Int) {
        
        let resource: ResourceModel = lessons[index]
        
        flowDelegate?.navigate(step: .lessonTappedFromLessonsList(resource: resource))
    }
    
    func refreshLessons() {
        dataDownloader.downloadInitialData()
    }
}
