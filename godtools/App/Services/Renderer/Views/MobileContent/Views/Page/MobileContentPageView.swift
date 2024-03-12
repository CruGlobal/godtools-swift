//
//  MobileContentPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol MobileContentPageViewDelegate: AnyObject {
    
    func pageViewDidReceiveEvent(pageView: MobileContentPageView, eventId: EventId) -> ProcessedEventResult?
}

class MobileContentPageView: MobileContentView, NibBased {
    
    private let viewModel: MobileContentPageViewModel
    
    private var backgroundImageView: MobileContentBackgroundImageView?
    
    private weak var delegate: MobileContentPageViewDelegate?
    
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
    
    private func addBackgroundImageBoundsChangeObserving() {
        
        backgroundImageView?.addParentBoundsChangeObserver(parentView: backgroundImageParent)
    }
    
    private func removeBackgroubdImageBoundsChangeObserving() {
        
        backgroundImageView?.removeParentBoundsChangeObserver(parentView: backgroundImageParent)
    }
    
    func setupLayout() {
        
    }
    
    func setupBinding() {
        
        // backgroundColor
        backgroundColor = viewModel.backgroundColor
        
        // backgroundImageView
        if let backgroundImageViewModel = viewModel.backgroundImageWillAppear() {
            
            let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
            
            self.backgroundImageView = backgroundImageView
            
            backgroundImageView.configure(viewModel: backgroundImageViewModel, parentView: backgroundImageParent)
            addBackgroundImageBoundsChangeObserving()
        }
    }
    
    func setDelegate(delegate: MobileContentPageViewDelegate?) {
        self.delegate = delegate
    }
        
    // MARK: - MobileContentView
    
    override func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
        
        return delegate?.pageViewDidReceiveEvent(pageView: self, eventId: eventId)
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
