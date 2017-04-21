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
import MagicalRecord

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
        
        for language in languages {
            language.localizedName = NSLocale.current.localizedString(forLanguageCode: language.code!)
        }
        
        languages = languages.sorted { (language1, language2) -> Bool in
            return language1.localizedName!.compare(language2.localizedName!).rawValue < 0
        }
        
        return Promise(value:languages)
    }
    
    func loadFromRemote() -> Promise<[Language]> {
        showNetworkingIndicator()
        
        return Alamofire.request(URL(string: "\(GTConstants.kApiBase)/\(path)")!).responseData().then { data -> Promise<[Language]> in
            let jsonDocument = try! self.serializer.deserializeData(data)
            
            if jsonDocument.data != nil {
                MagicalRecord.save(blockAndWait: { (context) in
                    for element in jsonDocument.data! {
                        let languageResource = element as! LanguageResource;
                        let language = Language.mr_findFirstOrCreate(byAttribute: "remoteId", withValue: languageResource.id!, in: context)
                        language.code = languageResource.code
                    }
                })
            }
            
            return self.loadFromDisk()
        }
    }
    
    fileprivate func showNetworkingIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

extension LanguagesManager: UITableViewDelegate {
    
}

extension LanguagesManager: UITableViewDataSource {
    
    static let languageCellIdentifier = "languageCell"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.textLabel?.text = languages[indexPath.row].localizedName
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
}
