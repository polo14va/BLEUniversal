//
//  OTAUpdateServiceDelegate.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 15/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

protocol OTAUpdateServiceDelegate: AnyObject {
    func otaUpdateProgress(_ progress: Float)
    func otaUpdateComplete()
    func otaUpdateFailed(error: String)
}
