//
//  ToolPagesListenersNotifier.swift
//  godtools
//
//  Created by Levi Eggert on 3/11/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

protocol ToolPagesListenersNotifierDelegate: class {
    
    func toolPagesListenersNotifierDidReceivePageListener(toolPagesListenersNotifier: ToolPagesListenersNotifier, listener: String, page: Int)
}

class ToolPagesListenersNotifier: NSObject {
    
    typealias Listener = String
    typealias PageNumber = Int
    
    private let mobileContentEvents: MobileContentEvents
    
    private var pageListenersDictionary: [Listener: PageNumber] = Dictionary()
    private var observersAdded: Bool = false
    
    private weak var delegate: ToolPagesListenersNotifierDelegate?
    
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
            
            notifier.delegate?.toolPagesListenersNotifierDidReceivePageListener(
                toolPagesListenersNotifier: notifier,
                listener: listener,
                page: page
            )
        }
    }
    
    func setListenersNotifierDelegate(delegate: ToolPagesListenersNotifierDelegate) {
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
