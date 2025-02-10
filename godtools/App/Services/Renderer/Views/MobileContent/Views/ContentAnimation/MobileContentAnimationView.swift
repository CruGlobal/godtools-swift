//
//  MobileContentAnimationView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser
import Combine

class MobileContentAnimationView: MobileContentView {
    
    private let viewModel: MobileContentAnimationViewModel
    private let animatedView: AnimatedView = AnimatedView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewModel: MobileContentAnimationViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // animatedView
        addSubview(animatedView)
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.constrainEdgesToView(view: self)
    }
    
    private func setupBinding() {
        
        if let animatedViewModel = viewModel.animatedViewModel {
            animatedView.configure(viewModel: animatedViewModel)
            animatedView.setAnimationContentMode(contentMode: .scaleAspectFill)
        }
        
        viewModel.$playbackState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (state: MobileContentAnimationViewModel.PlaybackState) in
                
                switch state {
                case .pause:
                    self?.animatedView.pause()
                    
                case .play:
                    self?.animatedView.play()
                    
                case .stop:
                    self?.animatedView.stop()
                }
            }
            .store(in: &cancellables)
    }
    
    override func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
                
        _ = super.didReceiveEvent(eventId: eventId, eventIdsGroup: eventIdsGroup)
        
        return viewModel.didReceiveEvent(eventId: eventId, eventIdsGroup: eventIdsGroup)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        
        let animationSize: CGSize
        
        if let animatedViewModel = viewModel.animatedViewModel, let assetSize = animatedViewModel.getAssetSize() {
            animationSize = assetSize
        }
        else {
            animationSize = CGSize(width: bounds.size.width, height: 40)
        }
                
        return .setToAspectRatioOfProvidedSize(size: CGSize(width: animationSize.width, height: animationSize.height))
    }
}
