//
//  AnimateDownloadProgress.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class AnimateDownloadProgress {
    
    static let defaultAnimationInterval: TimeInterval = 0.2
    static let defaultAnimateProgressIncrement: TimeInterval = 0.1
    static let initialProgressTarget: Double = 0.1
        
    private let timer: SwiftUITimer
    
    private var cancellable: AnyCancellable?
    
    init(animationInterval: TimeInterval = AnimateDownloadProgress.defaultAnimationInterval) {
        
        timer = SwiftUITimer(intervalSeconds: animationInterval)
    }
    
    func start(downloadProgressPublisher: AnyPublisher<Double, Error>) -> AnyPublisher<Double, Error> {
            
        let progressSubject: CurrentValueSubject<Double, Error> = CurrentValueSubject(0)
        
        var lastTimerDate: Date = Date()
        var progressTarget: Double = AnimateDownloadProgress.initialProgressTarget
        var animatedProgress: Double = 0
        
        cancellable = Publishers.CombineLatest(
            downloadProgressPublisher.prepend(0),
            timer.startPublisher().prepend(Date()).setFailureType(to: Error.self)
        )
        .catch { (error: Error) in
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        .map { (downloadProgress: Double, timerDate: Date) in
            
            let timerInvoked: Bool = lastTimerDate != timerDate
            
            progressTarget = downloadProgress > progressTarget ? downloadProgress : progressTarget
            
            if progressTarget > 1 {
                progressTarget = 1
            }
            
            if timerInvoked {
                animatedProgress += AnimateDownloadProgress.defaultAnimateProgressIncrement
            }
            
            if animatedProgress > progressTarget {
                animatedProgress = progressTarget
            }
            
            lastTimerDate = timerDate
            
            return animatedProgress
        }
        .sink { completion in
            
            progressSubject.send(completion: completion)
            
        } receiveValue: { (progress: Double) in
            
            if progress < 1 {
                progressSubject.send(progress)
            }
            else {
                progressSubject.send(completion: .finished)
            }
        }
        
        return progressSubject
            .eraseToAnyPublisher()
    }
    
    func stop() {
        timer.stop()
        cancellable?.cancel()
        cancellable = nil
    }
}
