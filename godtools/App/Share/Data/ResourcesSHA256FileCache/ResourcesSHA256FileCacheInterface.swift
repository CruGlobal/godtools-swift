//
//  ResourcesSHA256FileCacheInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

protocol ResourcesSHA256FileCacheInterface {
        
    func getFileExists(location: FileCacheLocation) async throws -> Bool
    func getFile(location: FileCacheLocation) async throws -> URL
    func getData(location: FileCacheLocation) async throws -> Data?
    func getUIImage(location: FileCacheLocation) async throws -> UIImage?
    func getImage(location: FileCacheLocation) async throws -> Image?
    
    func storeAttachmentFile(attachmentId: String, fileName: String, fileData: Data) async throws -> FileCacheLocation
    func storeTranslationFile(translationId: String, fileName: String, fileData: Data) async throws -> FileCacheLocation
    func storeTranslationZipFile(translationId: String, zipFileData: Data) async throws -> [FileCacheLocation]
}
