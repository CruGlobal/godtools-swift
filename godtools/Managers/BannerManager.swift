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
import Alamofire

class BannerManager: GTDataManager {
    let path = "attachments"
    
    override init() {
        super.init()
        
        createBannersDirectoryIfNecessary()
    }
    
    let defaultExtension = "png"
    
    func downloadFor(_ resource: DownloadedResource) {
        
        let homeBannerAttachment = loadAttachment(remoteId: resource.bannerRemoteId)
        
        if homeBannerAttachment != nil && bannerHasChanged(attachment: homeBannerAttachment!) {
            _ = issueDownloadRequest(attachment: homeBannerAttachment!).then(execute: { (image) -> Void in
                self.postCompletedNotification(resource: resource)
            })
        }

        let aboutBannerAttachment = loadAttachment(remoteId: resource.bannerRemoteId)

        if aboutBannerAttachment != nil && bannerHasChanged(attachment: aboutBannerAttachment!) {
            _ = issueDownloadRequest(attachment: aboutBannerAttachment!)
        }
    }
    
    private func issueDownloadRequest(attachment: Attachment) -> Promise<UIImage?> {
        return issueGETRequest(bannerId: attachment.remoteId).then { image -> Promise<UIImage?> in
            self.saveImageToDisk(image, attachment: attachment)
            
            return Promise<UIImage?>(value: UIImage(data: image))
            }.catch(execute: { error in
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error downloading banner."])
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
    
    func issueGETRequest(bannerId: String) -> Promise<Data> {
        let url = Config.shared().baseUrl?
            .appendingPathComponent(self.path)
            .appendingPathComponent(bannerId)
            .appendingPathComponent("download")
        
        return Alamofire.request(url!).responseData()
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
                Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error writing banner."])
            }
        }
    }
    
    private func loadAttachment(remoteId: String?) -> Attachment? {
        if remoteId == nil {
            return nil
        }
        
        return findEntityByRemoteId(Attachment.self, remoteId: remoteId!)
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
