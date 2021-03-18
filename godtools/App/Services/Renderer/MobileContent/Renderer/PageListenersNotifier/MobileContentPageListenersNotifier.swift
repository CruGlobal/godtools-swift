//
//  MobileContentPageListenersNotifier.swift
//  godtools
//
//  Created by Levi Eggert on 3/18/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentPageListenersNotifierDelegate: class {
    
    func mobileContentPageListenersNotifierDidReceivePageListener(pageListenersNotifier: MobileContentPageListenersNotifier, listener: String, page: Int)
}

class MobileContentPageListenersNotifier: NSObject {
    
    typealias Listener = String
    typealias PageNumber = Int
    
    private let mobileContentEvents: MobileContentEvents
    
    private var pageListenersDictionary: [Listener: PageNumber] = Dictionary()
    private var observersAdded: Bool = false
    
    private weak var delegate: MobileContentPageListenersNotifierDelegate?
    
    required init(mobileContentEvents: MobileContentEvents) {
                
        self.mobileContentEvents = mobileContentEvents
        
        super.init()
                
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func removeObservers() {
        
        observersAdded = false
        
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    private func addObservers() {
        
        guard !observersAdded else {
            return
        }
        
        observersAdded = true
        
        mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            
            let listener: String = buttonEvent.event
            
            guard let notifier = self else {
                return
            }
            
            guard let page = notifier.pageListenersDictionary[listener] else{
                return
            }
            
            notifier.delegate?.mobileContentPageListenersNotifierDidReceivePageListener(
                pageListenersNotifier: notifier,
                listener: listener,
                page: page
            )
        }
    }
    
    func setListenersNotifierDelegate(delegate: MobileContentPageListenersNotifierDelegate) {
        self.delegate = delegate
    }
    
    func addPagesListeners(pageNodes: [PageNode]) {
        
        for pageIndex in 0 ..< pageNodes.count {
            
            let pageNode: PageNode = pageNodes[pageIndex]
            
            addPageListeners(pageNode: pageNode, page: pageIndex)
        }
    }
    
    func addPageListeners(pageNode: PageNode, page: Int) {
        for listener in pageNode.listeners {
            pageListenersDictionary[listener] = page
        }
    }
}
