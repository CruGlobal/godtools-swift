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
import PromiseKit
import Spine

class LanguagesManager: NSObject {
    static let shared = LanguagesManager()
    
    let path = "/languages"
    let serializer = Serializer()
    
    override init() {
        super.init()
        serializer.registerResource(LanguageResource.self)
    }
    
    func loadFromRemote() {
        Alamofire.request(URL(string: "\(GodToolsConstants.kApiBase)/\(path)")!).responseData().then { data -> Promise<Data> in
            let jsonDocument = try! self.serializer.deserializeData(data)
            
            return Promise(value:data)
        }.catch { error in
            print(error)
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
