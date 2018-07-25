//
//  LanguagesTableViewController+UISearchBarDelegate.swift
//  godtools
//
//  Created by Greg Weiss on 7/25/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

extension LanguagesTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filterContentForSearchText(searchText)
            isFiltering = true
            tableView.reloadData()
        } else {
            isFiltering = false
            tableView.reloadData()
        }
    }
    
    func setupSearchBarYValue() {
        if let navFrameHeight = self.navigationController?.navigationBar.frame.height {
            let statusHeight = UIApplication.shared.statusBarFrame.height
            navHeight = navFrameHeight + statusHeight
        }
    }
    
    func setUpSearchBar() {
        searchTool = UISearchBar(frame: CGRect(x: self.screenWidth, y: navHeight, width: screenWidth, height: searchBarHeight))
        searchTool.delegate = self
        searchTool.backgroundImage = UIImage(color: .gtGreyLight)
        searchTool.isTranslucent = true
        searchTool.returnKeyType = .done
        searchTool.inputAccessoryView = toolBarViewForKeyboard()
        view.addSubview(searchTool)
        
        // TODO: - This code will be determined when search button options are decided
        //        self.blankView = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.searchBarHeight))
        //        self.tableView.tableHeaderView = blankView
    }
    
    func addTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func toolBarViewForKeyboard() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissButton = UIBarButtonItem(title: "dismiss".localized, style: .plain, target: self, action: #selector(hideKeyboard))
        toolbar.setItems([flexSpace, dismissButton], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc func hideKeyboard() {
        searchButtonAction()
    }
    
    func animateSearchOnScreen() {
        UIView.animate(withDuration: 0.3) {
            self.blankView = UIView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.searchBarHeight))
            self.tableView.tableHeaderView = self.blankView
            self.searchTool.frame = CGRect(x: 0, y: self.navHeight, width: self.screenWidth, height: self.searchBarHeight)
            self.searchTool.becomeFirstResponder()
        }
    }
    
    func animateSearchOffScreen() {
        UIView.animate(withDuration: 0.25) {
            self.searchTool.frame = CGRect(x: self.screenWidth, y: self.navHeight, width: self.screenWidth, height: self.searchBarHeight)
            self.blankView = UIView(frame: CGRect(x: self.screenWidth, y: 0, width: self.screenWidth, height: self.searchBarHeight))
            self.tableView.tableHeaderView = UIView()
            self.searchTool.resignFirstResponder()
        }
    }
    
}
