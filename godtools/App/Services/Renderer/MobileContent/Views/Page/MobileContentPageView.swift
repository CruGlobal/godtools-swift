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
    func pageViewDidReceiveError(pageView: MobileContentPageView, error: MobileContentErrorViewModel)
}

class MobileContentPageView: MobileContentView {
    
    private weak var delegate: MobileContentPageViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDelegate(delegate: MobileContentPageViewDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - MobileContentView
    
    override func didReceiveEvents(events: [String]) {
        delegate?.pageViewDidReceiveEvents(pageView: self, events: events)
    }
    
    override func didReceiveUrl(url: String) {
        delegate?.pageViewDidReceiveUrl(pageView: self, url: url)
    }
    
    override func didReceiveError(error: MobileContentErrorViewModel) {
        delegate?.pageViewDidReceiveError(pageView: self, error: error)
    }
}
