
//
//  TractViewControllerPageMovements.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

extension TractViewController {
    
    func moveToPage(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: String] else {
            return
        }
        
        let destinationViewPageId = dictionary["pageId"]
        for (pageId, pageIndex) in self.pagesIds {
            if pageId == destinationViewPageId {
                self.currentPage = pageIndex
                break
            }
        }
        
        reloadPagesViews()
        moveViews()
    }
    
    func moveToNextPage() {
        if self.currentPage >= totalPages() - 1 {
            return
        }
        
        self.currentPage += 1
        reloadPagesViews()
        moveViews()
    }
    
    func moveToPreviousPage() {
        if self.currentPage == 0 {
            return
        }
        
        self.currentPage -= 1
        reloadPagesViews()
        moveViews()
    }
    
    func removeViewsBeforeCurrentView() {
        if self.currentPage == 0 {
            return
        }
        
        let currentPageView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin)
        
        for pageView in self.pagesViews {
            if pageView == currentPageView {
                break
            }
            pageView.removeFromSuperview()
        }
    }
    
    fileprivate func moveViews() {
        let newCurrentProgressViewFrame = CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: currentProgressWidth(),
                                                 height: self.currentProgressView.frame.size.height)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        self.currentProgressView.frame = newCurrentProgressViewFrame
                        for view in self.pagesViews {
                            view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
                        } },
                       completion: nil )
    }
    
}
