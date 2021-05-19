//
//  MobileContentPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentPageViewDelegate: class {
    
    func pageViewDidReceiveEvents(pageView: MobileContentPageView, events: [String])
    func pageViewDidReceiveUrl(pageView: MobileContentPageView, url: String)
    func pageViewDidReceiveTrainingTipTap(pageView: MobileContentPageView, event: TrainingTipEvent)
    func pageViewDidReceiveError(pageView: MobileContentPageView, error: MobileContentErrorViewModel)
}

class MobileContentPageView: MobileContentView {
    
    private let viewModel: MobileContentPageViewModelType
    private let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
    
    private weak var delegate: MobileContentPageViewDelegate?
    
    required init(viewModel: MobileContentPageViewModelType, nibName: String?) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        if let nibName = nibName {
            initializeNib(nibName: nibName)
        }
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib(nibName: String) {
        
        let nib: UINib = UINib(nibName: nibName, bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    func setupLayout() {
        
    }
    
    func setupBinding() {
        
        // backgroundColor
        backgroundColor = viewModel.backgroundColor
        
        // backgroundImageView
        if let backgroundImageViewModel = viewModel.backgroundImageWillAppear() {
            backgroundImageView.configure(viewModel: backgroundImageViewModel, parentView: self)
        }
    }
    
    func setDelegate(delegate: MobileContentPageViewDelegate?) {
        self.delegate = delegate
    }
    
    func getPagePositions() -> MobileContentPagePositionsType {
        
        return MobileContentPagePositions()
    }
    
    func setPagePositions(pagePositions: MobileContentPagePositionsType, animated: Bool) {
        
    }
    
    // MARK: - MobileContentView
    
    override func didReceiveEvents(events: [String]) {
        delegate?.pageViewDidReceiveEvents(pageView: self, events: events)
    }
    
    override func didReceiveButtonWithUrlEvent(url: String) {
        delegate?.pageViewDidReceiveUrl(pageView: self, url: url)
    }
    
    override func didReceiveTrainingTipTap(event: TrainingTipEvent) {
        delegate?.pageViewDidReceiveTrainingTipTap(pageView: self, event: event)
    }
    
    override func didReceiveError(error: MobileContentErrorViewModel) {
        delegate?.pageViewDidReceiveError(pageView: self, error: error)
    }
}
