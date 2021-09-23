//
//  MobileContentPageView.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentPageViewDelegate: AnyObject {
    
    func pageViewDidReceiveEvents(pageView: MobileContentPageView, events: [String])
}

class MobileContentPageView: MobileContentView {
    
    private let viewModel: MobileContentPageViewModelType
    
    private var backgroundImageParent: UIView?
    private var backgroundImageView: MobileContentBackgroundImageView?
    
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
    
    deinit {
        
        if let backgroundImageParent = self.backgroundImageParent {
            backgroundImageView?.removeParentBoundsChangeObserver(parentView: backgroundImageParent)
        }
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
            
            let backgroundImageParent: UIView = self
            let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
            
            self.backgroundImageParent = backgroundImageParent
            self.backgroundImageView = backgroundImageView
            
            backgroundImageView.configure(viewModel: backgroundImageViewModel, parentView: backgroundImageParent)
            backgroundImageView.addParentBoundsChangeObserver(parentView: backgroundImageParent)
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
        super.didReceiveEvents(events: events)
        
        delegate?.pageViewDidReceiveEvents(pageView: self, events: events)
    }
    
    override func didReceiveButtonWithUrlEvent(url: String) {
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
