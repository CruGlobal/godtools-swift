//
//  TractViewControllerContent.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

extension TractViewController {
    
    static let snapshotViewTag = 3210123
    static let distanceToCurrentView = 1
    
    func buildPages(width: CGFloat, height: CGFloat) {
        let range = getRangeOfViews()
        if range.end < range.start {
            baseDelegate?.goHome()
            showErrorMessage()
            return
        }
        
        var currentElement: BaseTractElement?
        if self.pagesViews.count > self.currentPage {
            currentElement = self.pagesViews[self.currentPage]?.contentView
        }
        cleanContainerView()
    
        for pageNumber in range.start...range.end {
            var parallelElement: BaseTractElement?
            if pageNumber == self.currentPage {
                parallelElement = currentElement
            }
            
            let view = buildPage(pageNumber, width: width, height: height, parallelElement: parallelElement)
            self.pagesViews[pageNumber] = view
            self.containerView.addSubview(view)
        }
        
        removeSnapshotView()
    }
    
    func buildPage(_ pageNumber: Int, width: CGFloat, height: CGFloat, parallelElement: BaseTractElement?) -> TractView {
        let xPosition = (width * CGFloat(pageNumber))
        let frame = CGRect(x: xPosition,
                           y: 0.0,
                           width: width,
                           height: height)
        
        let page = getPage(pageNumber)
        let configurations = TractConfigurations()
        configurations.defaultTextAlignment = getLanguageTextAlignment()
        configurations.pagination = page.pagination
        configurations.language = self.selectedLanguage
        configurations.resource = self.resource
        let view = TractView(frame: frame,
                             data: page.pageContent(),
                             manifestProperties: self.manifestProperties,
                             configurations: configurations,
                             parallelElement: parallelElement,
                             delegate: self)
        
        view.transform = CGAffineTransform(translationX: self.currentMovement, y: 0.0)
        view.tag = self.viewTagOrigin + pageNumber
        
        return view
    }
    
    func reloadPagesViews() -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            let range = getRangeOfViews()
            let lastPosition = self.totalPages() - 1
            let width = self.containerView.frame.size.width
            let height = self.containerView.frame.size.height
            
            for position in range.start...range.end {
                _ = addPageViewAtPosition(position: position, width: width, height: height)
            }
            
            if range.start > 0 {
                for position in 0...(range.start - 1) {
                    _ = removePageViewAtPosition(position: position)
                }
            }
            
            if range.end < lastPosition {
                for position in (range.end + 1)...lastPosition {
                    _ = removePageViewAtPosition(position: position)
                }
            }
            
            fulfill(true)
        }
    }
    
    func addPageViewAtPosition(position: Int, width: CGFloat, height: CGFloat) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            
            if self.pagesViews[position] == nil {
                guard let firstView = self.containerView.subviews.first else {
                    fulfill(false)
                    return
                }
                
                let view = buildPage(position, width: width, height: height, parallelElement: nil)
                self.pagesViews[position] = view
                if firstView.tag > view.tag {
                    self.containerView.insertSubview(view, at: 0)
                } else {
                    self.containerView.addSubview(view)
                }
            }
            
            fulfill(true)
        }
    }
    
    func removePageViewAtPosition(position: Int) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            let pageView = self.pagesViews[position]
            if pageView != nil {
                pageView!.removeFromSuperview()
                self.pagesViews[position] = nil
            }
            fulfill(true)
        }
    }
    
    func getRangeOfViews() -> (start: Int, end: Int) {
        var start = self.currentPage - TractViewController.distanceToCurrentView
        if start < 0 {
            start = 0
        }
        
        var end = self.currentPage + TractViewController.distanceToCurrentView
        if end >= self.totalPages() {
            end = totalPages() - 1
        }
        
        return (start, end)
    }
    
    func cleanContainerView() {
        addSnapshotView()
        
        for view in self.containerView.subviews {
            if view.tag != TractViewController.snapshotViewTag {
                view.removeFromSuperview()
            }
        }
        
        self.pagesViews.removeAll()
        resetPagesView()
    }
    
    func resetPagesView() {
        self.pagesViews = [TractView?](repeating: nil, count: totalPages())
    }
    
    private func addSnapshotView() {
        let imageView = UIImageView(frame: self.containerView.frame)
        imageView.image = UIImage.init(view: self.containerView)
        imageView.tag = TractViewController.snapshotViewTag
        self.containerView.addSubview(imageView)
    }
    
    private func removeSnapshotView() {
        let snapshotView = self.containerView.viewWithTag(TractViewController.snapshotViewTag)
        snapshotView?.removeFromSuperview()
    }
    
    private func showErrorMessage() {
        let alert = UIAlertController(title: "error".localized,
                                      message: "tract_loading_error_message".localized,
                                      preferredStyle: .alert)
        
        let actionYes = UIAlertAction(title: "yes".localized,
                                      style: .default,
                                      handler: { action in
                                        self.redownloadResources()
        })
        
        let actionNo = UIAlertAction(title: "no".localized,
                                      style: .cancel,
                                      handler: { action in
                                        self.disableResource()
        })
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
    private func redownloadResources() {
        DownloadedResourceManager().delete(resource!)
        DownloadedResourceManager().download(resource!)
        postReloadHomeScreenNotification()
    }
    
    private func disableResource() {
        DownloadedResourceManager().delete(resource!)
        postReloadHomeScreenNotification()
    }
    
    private func postReloadHomeScreenNotification() {
        NotificationCenter.default.post(name: .reloadHomeListNotification, object: nil)
    }
}
