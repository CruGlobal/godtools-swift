//
//  LanguagesManager.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LanguagesManager: NSObject {
    static let shared = LanguagesManager()
    
    func loadFromRemote() {
        Alamofire.request(URL(string: "https://mobile-content-api-stage.cru.org/languages")!).responseJSON { (response) in
            print(response)
        }
    }
}

extension LanguagesManager: UITableViewDelegate {
    
}

extension LanguagesManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}
