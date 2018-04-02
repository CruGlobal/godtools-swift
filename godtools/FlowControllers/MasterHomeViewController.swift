//
//  MasterHomeViewController.swift
//  godtools
//
//  Created by Greg Weiss on 4/2/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class MasterHomeViewController: UIViewController, AddToolsViewControllerDelegate, HomeViewControllerDelegate, LanguageSettingsViewControllerDelegate, LanguagesTableViewControllerDelegate {
    
    var segmentedControl = UISegmentedControl()
    
    private lazy var homeViewController: HomeViewController = {
        
        let viewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var addToolsViewController: AddToolsViewController = {
        
        let viewController = AddToolsViewController(nibName: "AddToolsViewController", bundle: nil)
        viewController.delegate = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.displayNavigationButtons()
        
        navigationController?.navigationBar.barStyle = .black
        setupView()
    }
    
    func addMyToolsFindToolsControl() {
        
        let myTools = determineMyToolsSegment()
        let findTools = determineFindToolsSegment()
        let fontSize = determineSegmentFontSize(myTools: myTools, findTools: findTools)
        let font = UIFont.systemFont(ofSize: fontSize)

        segmentedControl = UISegmentedControl(items: [myTools, findTools])
        segmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        segmentedControl.sizeToFit()
        //segmentedControl.tintColor = .white
    }
    
    // MARK: - View Methods
    
    private func setupView() {
        setupSegmentedControl()
        
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: addToolsViewController)
            add(asChildViewController: homeViewController)
        } else {
            remove(asChildViewController: homeViewController)
            add(asChildViewController: addToolsViewController)
        }
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        
        segmentedControl.removeAllSegments()
        addMyToolsFindToolsControl()
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
        
        self.navigationItem.titleView = segmentedControl
    }
    
    // MARK: - Actions
    
    func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }

    // MARK: - Helper Methods
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    // MARK: - Delegate Methods
    
    func moveToAddNewTool() {
        //
    }
    
    func moveToLanguagesList(primaryLanguage: Bool) {
            let viewController = LanguagesTableViewController(nibName: String(describing:LanguagesTableViewController.self), bundle: nil)
            viewController.delegate = self
            viewController.selectingForPrimary = primaryLanguage
           // self.pushViewController(viewController: viewController)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func moveToUpdateLanguageSettings() {
            let viewController = LanguageSettingsViewController(nibName: String(describing:LanguageSettingsViewController.self), bundle: nil)
            viewController.delegate = self
            //self.pushViewController(viewController: viewController)
        self.navigationController?.pushViewController(viewController, animated: true)

    }
    
    func moveToToolDetail(resource: DownloadedResource) {
        let viewController = ToolDetailViewController(nibName: String(describing:ToolDetailViewController.self), bundle: nil)
        viewController.resource = resource
        //navigationController?.pushViewController(viewController: viewController)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func moveToTract(resource: DownloadedResource) {
        let viewController = TractViewController(nibName: String(describing: TractViewController.self), bundle: nil)
        viewController.resource = resource
        //pushViewController(viewController: viewController)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: - Helper Methods
    
    func determineMyToolsSegment() -> String {
        let myTools = "my_tools".localized
        return myTools
    }
    
    func determineFindToolsSegment() -> String {
        let findTools = "find_tools".localized
        return findTools
    }
    
    func determineSegmentFontSize(myTools: String, findTools: String) -> CGFloat {
        let count = (myTools.count > findTools.count) ? myTools.count : findTools.count
        var fontSize: CGFloat = 15.0
        if count > 14 {
            switch count {
            case 15:
                fontSize = 14.0
            case 16:
                fontSize = 13.5
            case 17:
                fontSize = 13.0
            case 18:
                fontSize = 12.5
            default:
                fontSize = 12.0
            }
        }
        
        return fontSize
    }

}
