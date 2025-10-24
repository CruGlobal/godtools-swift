//
//  MobileContentAnimationView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared
import Combine

class MobileContentAnimationView: MobileContentView {
    
    private let viewModel: MobileContentAnimationViewModel
    private let animatedView: AnimatedView?
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewModel: MobileContentAnimationViewModel) {
        
        self.viewModel = viewModel
        
        let animatedView: AnimatedView?
        
        if let animatedViewModel = viewModel.animatedViewModel {
            
            animatedView = AnimatedView(
                viewModel: animatedViewModel,
                frame: CGRect(x: 0, y: 0, width: 50, height: 50)
            )
        }
        else {
            animatedView = nil
        }
        
        self.animatedView = animatedView
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        if let animatedView = animatedView {
            setupLayout(animatedView: animatedView)
            setupBinding(animatedView: animatedView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(animatedView: AnimatedView) {
        
        // animatedView
        addSubview(animatedView)
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        animatedView.constrainEdgesToView(view: self)
        animatedView.setAnimationContentMode(contentMode: .scaleAspectFill)
    }
    
    private func setupBinding(animatedView: AnimatedView) {
        
        viewModel.$playbackState
            .receive(on: DispatchQueue.main)
            .sink { (state: MobileContentAnimationPlaybackState) in
                
                switch state {
                case .pause:
                    animatedView.pause()
                    
                case .play:
                    animatedView.play { [weak self] (completed: Bool) in
                        self?.viewModel.animationPlaybackDidComplete(animationIsPlaying: animatedView.isPlaying)
                    }
                    
                case .stop:
                    animatedView.stop()
                }
            }
            .store(in: &cancellables)
    }
    
    override func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
                
        _ = super.didReceiveEvent(eventId: eventId, eventIdsGroup: eventIdsGroup)
        
        return viewModel.didReceiveEvent(
            eventId: eventId,
            eventIdsGroup: eventIdsGroup
        )
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
