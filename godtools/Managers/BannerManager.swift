//
//  File.swift
//  godtools
//
//  Created by Ryan Carlson on 5/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import PromiseKit
import Crashlytics

class BannerManager: GTDataManager {
    static let shared = BannerManager()
    
    class func setup() {
        _ = BannerManager.shared
    }
    
    private override init() {
        super.init()
        
        createBannersDirectoryIfNecessary()
    }
    
    let defaultExtension = "png"
    var bannerId: String?
    
    func downloadFor(_ resource: DownloadedResource) -> Promise<UIImage?> {
        guard let remoteId = resource.bannerRemoteId else {
            return Promise<UIImage?>(value: nil)
        }
        
        bannerId = remoteId
        
        return issueGETRequest().then { image -> Promise<UIImage?> in
            self.saveImageToDisk(image)
            
            return Promise(value: UIImage(data: image))
        }.catch(execute: { error in
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error downloading banner w/ id \(self.bannerId)."])
        })
    }
    
    func loadFor(_ resource: DownloadedResource) -> UIImage? {
        guard let remoteId = resource.bannerRemoteId else {
            return nil
        }
        
        guard let attachment = findEntity(Attachment.self, byAttribute: "remoteId", withValue: remoteId) else {
            return nil
        }
        
        guard let diskPathString = attachment.diskPath else {
            return nil
        }
        
        return UIImage(contentsOfFile: diskPathString)
    }
    
    override func buildURLString() -> String {
        return GTConstants.kApiBase.appending("/attachments/").appending(bannerId!).appending("/download")
    }
    
    private func saveImageToDisk(_ image: Data) {
        guard let attachment = findEntity(Attachment.self, byAttribute: "remoteId", withValue: bannerId ?? "-1") else {
            return
        }
        
        let path = bannersPath.appendingPathComponent(attachment.sha!).appendingPathExtension(defaultExtension)
        
        do {
            try image.write(to: path)
            attachment.isBanner = true
            attachment.diskPath = path.path
            saveToDisk()
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error writing banner w/ id \(bannerId) to disk."])
        }
    }
    
    private func createBannersDirectoryIfNecessary() {
        if FileManager.default.fileExists(atPath: bannersPath.path, isDirectory: nil) {
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: bannersPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating Banners directory on device."])
        }
    }
}
