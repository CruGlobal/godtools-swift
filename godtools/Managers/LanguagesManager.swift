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
    
    var languages = [Language]()
    
    override init() {
        super.init()
        serializer.registerResource(LanguageResource.self)
    }
    
    func loadFromDisk() -> Promise<[Language]> {
        languages = Language.mr_findAll() as! [Language]
        languages = languages.sorted { (language1, language2) -> Bool in
            let locale = NSLocale.current
            let localizedName1 = locale.localizedString(forLanguageCode: language1.code!)!
            let localizedName2 = locale.localizedString(forLanguageCode: language2.code!)!
            
            return localizedName1.compare(localizedName2).rawValue < 0
        }
        return Promise(value:languages)
    }
    
    func loadFromRemote() -> Promise<[Language]> {
        return Alamofire.request(URL(string: "\(GodToolsConstants.kApiBase)/\(path)")!).responseData().then { data -> Promise<[Language]> in
            let jsonDocument = try! self.serializer.deserializeData(data)
            
            if jsonDocument.data != nil {
                for element in jsonDocument.data! {
                    let languageResource = element as! LanguageResource;
                    let language = Language.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: languageResource.id!)
                    language.code = languageResource.code
                }
            }
            
            return self.loadFromDisk()
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
        cell.backgroundColor = .clear
        cell.textLabel?.text = NSLocale.current.localizedString(forLanguageCode: languages[indexPath.row].code!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
}
