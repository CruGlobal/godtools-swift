//
//  ArticleViewControllerDataManagement.swift
//  godtools
//
//  Created by Igor Ostriz on 14/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation

extension ArticleViewController: UITableViewDataSource {
    
    
    func bindings() {
        tableView.dataSource = self
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
}
