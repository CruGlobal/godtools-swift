//
//  MobileContentPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

protocol MobileContentPageViewDelegate: AnyObject {
    
    func pageViewDidReceiveEvent(pageView: MobileContentPageView, eventId: EventId) -> ProcessedEventResult?
}

class MobileContentPageView: MobileContentView, NibBased {
    
    private let viewModel: MobileContentPageViewModel
    
    private var layeredBackgroundImages: [MobileContentBackgroundImageView] = Array()
    
    private weak var pageViewDelegate: MobileContentPageViewDelegate?
    
    init(viewModel: MobileContentPageViewModel, nibName: String?) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        if let nibName = nibName {
            loadNib(nibName: nibName)
        }
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        removeBackgroubdImageBoundsChangeObserving()
    }
    
    var backgroundImageParent: UIView {
        return self
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        if newSuperview == nil {
            removeBackgroubdImageBoundsChangeObserving()
        }
        else {
            addBackgroundImageBoundsChangeObserving()
        }
    }
    
    override func viewDidAppear(navigationEvent: MobileContentPagesNavigationEvent?) {
        super.viewDidAppear(navigationEvent: navigationEvent)
        
        viewModel.pageDidAppear()
    }
    
    private func addBackgroundImageBoundsChangeObserving() {
        
        for backgroundImageView in layeredBackgroundImages {
            backgroundImageView.addParentBoundsChangeObserver(parentView: backgroundImageParent)
        }
    }
    
    private func removeBackgroubdImageBoundsChangeObserving() {
        
        for backgroundImageView in layeredBackgroundImages {
            backgroundImageView.removeParentBoundsChangeObserver(parentView: backgroundImageParent)
        }
    }
    
    private func addLayeredBackgroundImages() {
        
        if let backgroundImageViewModel = viewModel.getBackgroundImage(type: .background) {
            
            let backgroundImageView = addBackgroundImageView(viewModel: backgroundImageViewModel, insertAtIndex: layeredBackgroundImages.count)
            
            layeredBackgroundImages.append(backgroundImageView)
        }
        
        if let foregroundBackgroundImageViewModel = viewModel.getBackgroundImage(type: .foreground) {
            
            let foregroundBackgroundImageView = addBackgroundImageView(viewModel: foregroundBackgroundImageViewModel, insertAtIndex: layeredBackgroundImages.count)
            
            layeredBackgroundImages.append(foregroundBackgroundImageView)
        }
        
        addBackgroundImageBoundsChangeObserving()
    }
    
    private func addBackgroundImageView(viewModel: MobileContentBackgroundImageViewModel, insertAtIndex: Int) -> MobileContentBackgroundImageView {
        
        let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
                        
        backgroundImageView.configure(viewModel: viewModel, parentView: backgroundImageParent, insertBackgroundAtIndex: insertAtIndex)
        
        return backgroundImageView
    }
    
    func setupLayout() {
        
        backgroundColor = viewModel.backgroundColor
        
        addLayeredBackgroundImages()
    }
    
    func setupBinding() {

    }
    
    func setPageViewDelegate(pageViewDelegate: MobileContentPageViewDelegate?) {
        self.pageViewDelegate = pageViewDelegate
    }
    
    func getPageViewDelegate() -> MobileContentPageViewDelegate? {
        return pageViewDelegate
    }
    
    func setSemanticContentAttribute(semanticContentAttribute: UISemanticContentAttribute) {
        
        // Intended for subclasses to override. ~Levi
    }
        
    // MARK: - MobileContentView
    
    override func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
        
        return pageViewDelegate?.pageViewDidReceiveEvent(pageView: self, eventId: eventId)
    }
    
    override func didReceiveButtonWithUrlEvent(url: URL) {
        super.didReceiveButtonWithUrlEvent(url: url)
        
        viewModel.buttonWithUrlTapped(url: url)
    }
    
    override func didReceiveTrainingTipTap(event: TrainingTipEvent) {
        super.didReceiveTrainingTipTap(event: event)
        
        viewModel.trainingTipTapped(event: event)
    }
    
    override func didReceiveError(error: MobileContentErrorViewModel) {
        super.didReceiveError(error: error)
        
        viewModel.errorOccurred(error: error)
    }
}
