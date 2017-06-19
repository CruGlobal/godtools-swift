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
    let path = "attachments"
    
    override init() {
        super.init()
        
        createBannersDirectoryIfNecessary()
    }
    
    let defaultExtension = "png"
    var bannerId: String?
    
    func downloadFor(_ resource: DownloadedResource) -> Promise<UIImage?> {
        guard let remoteId = resource.bannerRemoteId else {
            return Promise<UIImage?>(value: nil)
        }
        
        guard let attachment = loadAttachment(remoteId: remoteId) else {
            return Promise<UIImage?>(value: nil)
        }
        
        if !bannerHasChanged(attachment: attachment) {
            return Promise(value: loadFor(resource))
        }
        
        bannerId = remoteId
        
        return issueGETRequest().then { image -> Promise<UIImage?> in
            self.saveImageToDisk(image, attachment: attachment)
            
            self.postCompletedNotification(resource: resource)
            
            return Promise(value: UIImage(data: image))
        }.catch(execute: { error in
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error downloading banner w/ id \(self.bannerId)."])
        })
    }
    
    func loadFor(_ resource: DownloadedResource) -> UIImage? {
        guard let remoteId = resource.bannerRemoteId else {
            return nil
        }
        
        guard let attachment = loadAttachment(remoteId: remoteId) else {
            return nil
        }
        
        if attachment.sha == nil {
            return nil
        }
        
        let path = bannersPath.appendingPathComponent(attachment.sha!)
            .appendingPathExtension(defaultExtension)
            .path
        
        return UIImage(contentsOfFile: path)
    }

    override func buildURL() -> URL? {
        guard let bannerID = self.bannerId else {
            return nil
        }
        return Config.shared().baseUrl?
            .appendingPathComponent(self.path)
            .appendingPathComponent(bannerID)
            .appendingPathComponent("download")
    }

    private func postCompletedNotification(resource: DownloadedResource) {
        NotificationCenter.default.post(name: .downloadBannerCompleteNotifciation,
                                        object: nil,
                                        userInfo: [GTConstants.kDownloadBannerResourceIdKey: resource.remoteId])
    }
    
    private func bannerHasChanged(attachment: Attachment) -> Bool {
        if attachment.sha == nil {
            return true
        }
        
        return !FileManager.default.fileExists(atPath: bannersPath.appendingPathComponent(attachment.sha!)
                                                                  .appendingPathExtension(defaultExtension)
                                                                  .path
        )
    }
    
    private func saveImageToDisk(_ image: Data, attachment: Attachment) {
        let path = bannersPath.appendingPathComponent(attachment.sha!).appendingPathExtension(defaultExtension)
        
        safelyWriteToRealm {
            do {
                try image.write(to: path)
                
                //NOTE: This could require a realm.write block, but I'm not sure. It's operating in a thread that *should*
                //already be in a block, but given the nesting of promises, i'm not 100% sure. -RTC
                attachment.isBanner = true
                
            } catch {
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error writing banner w/ id \(bannerId) to disk."])
            }
        }
    }
    
    private func loadAttachment(remoteId: String) -> Attachment? {
        return findEntityByRemoteId(Attachment.self, remoteId: remoteId)
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
