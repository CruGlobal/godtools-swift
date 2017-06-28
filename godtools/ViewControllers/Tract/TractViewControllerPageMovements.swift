
//
//  TractViewControllerPageMovements.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

extension TractViewController {
    
    func moveToPage(notification: Notification) {
        guard let dictionary = notification.userInfo as? [String: String] else {
            return
        }
        
        guard let pageListener = dictionary["pageListener"] else { return }
        guard let page = TractBindings.pageBindings[pageListener] else { return }
        
        self.currentPage = page
        reloadPagesViews()
        _ = moveBackward()
    }
    
    func moveToNextPage() {
        if self.currentPage >= totalPages() - 1 {
            return
        }
        
        self.currentPage += 1
        _ = moveForeward()
        .then { (success) -> Promise<Bool> in
            if success == true {
                self.reloadPagesViews()
                return Promise(value: true)
            }
            return Promise(value: false)
        }
    }
    
    func moveToPreviousPage() {
        if self.currentPage == 0 {
            return
        }
        
        self.currentPage -= 1
        _ = moveBackward()
        reloadPagesViews()
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
            pageView?.removeFromSuperview()
        }
    }
    
    // MARK: - Promises
    
    fileprivate func moveBackward() -> Promise<Bool> {
        let newCurrentProgressViewFrame = buildProgressViewFrame()
        return UIView.promise(animateWithDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: { 
            self.currentProgressView.frame = newCurrentProgressViewFrame
            for view in self.pagesViews {
                view?.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
            }
        })
    }
    
    fileprivate func moveForeward() -> Promise<Bool> {
        let newCurrentProgressViewFrame = buildProgressViewFrame()
        guard let currentPageView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin) else {
            return Promise(value: false)
        }
        
        return UIView.promise(animateWithDuration: 0.35, delay: 0.0, options: .curveEaseInOut, animations: {
            self.currentProgressView.frame = newCurrentProgressViewFrame
            currentPageView.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        }).then { _ in
            return self.moveViewsExceptCurrentView(currentPageView: currentPageView)
        }
    }
    
    fileprivate func moveViewsExceptCurrentView(currentPageView: UIView) -> Promise<Bool> {
        return UIView.promise(animateWithDuration: 0.35, delay: 0.0, options: .curveEaseInOut) {
            for view in self.pagesViews {
                if view == currentPageView {
                    continue
                }
                view?.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
            }
        }.then { _ in
            self.notifyCurrentViewDidAppearOnTract()
            return Promise(value: true)
        }
    }
    
    fileprivate func notifyCurrentViewDidAppearOnTract() {
        let currentTractView = self.view.viewWithTag(self.currentPage + self.viewTagOrigin) as! TractView
        currentTractView.contentView?.notifyViewDidAppearOnTract()
    }
    
    // MARK: - Helpers
    
    fileprivate func buildProgressViewFrame() -> CGRect {
        return CGRect(x: 0.0,
                      y: 0.0,
                      width: currentProgressWidth(),
                      height: self.currentProgressView.frame.size.height)
    }
}
