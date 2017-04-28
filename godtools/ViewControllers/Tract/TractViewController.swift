//
//  TractViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit

class TractViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTitle()
        initializeView()
    }
    
    override func configureNavigationButtons() {
        addHomeButton()
        addShareButton()
    }

    fileprivate func displayTitle() {
        if parallelLanguageIsAvailable() {
            navigationItem.titleView = languageSegmentedControl()
        } else {
            navigationItem.title = currentTractTitle()
        }
    }
    
    fileprivate func initializeView() {
        let navigationBarFrame = navigationController!.navigationBar.frame
        let startingPoint = navigationBarFrame.origin.y + navigationBarFrame.size.height
        
        let baseView = Bundle.main.loadNibNamed("BaseTractView", owner: self, options: nil)!.first as! BaseTractView
        baseView.data = getData()
        baseView.frame = CGRect(x: 0.0,
                                y: startingPoint,
                                width: self.view.frame.size.width,
                                height: self.view.frame.size.height - startingPoint)
                
        view.addSubview(baseView)
    }
    
    override func homeButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func shareButtonAction() {
        let activityController = UIActivityViewController(activityItems: [String.localizedStringWithFormat("tract_share_message".localized, "www.knowgod.com")], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    func getData() -> Dictionary<String, Any> {
        let paragraphContent = [
            "kind": "text",
            "properties": ["message": "These four points explain how to enter into a personal relationship with God and experience the life for which you were created."],
            "children": []
            ] as [String : Any]
        
        let paragraph = [
            "kind": "paragraph",
            "properties": [],
            "children": [paragraphContent]
            ] as [String : Any]
        
        let headingContent = [
            "kind": "text",
            "properties": ["message": "Knowing God Personally"],
            "children": []
            ] as [String : Any]
        
        let heading = [
            "kind": "heading",
            "properties": [],
            "children": [headingContent]
            ] as [String : Any]
        
        let hero = [
            "kind": "hero",
            "properties": [],
            "children": [heading, paragraph]
            ] as [String : Any]
        
        let page = [
            "kind": "root",
            "properties": [],
            "children": [hero]
            ] as [String : Any]
        
        return page
    }
}

// Mark - stub methods to be filled in with real logic later

extension TractViewController {
    fileprivate func parallelLanguageIsAvailable() -> Bool {
        return arc4random_uniform(2) % 2 == 0
    }
    
    fileprivate func currentTractTitle() -> String {
        return "Knowing God Personally"
    }
    
    fileprivate func languageSegmentedControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["English", "French"])
        control.selectedSegmentIndex = 0
        return control
    }
}
