// FileUploadDelegate.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 15/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation

class FileUploadDelegate: ObservableObject, OTAUpdateServiceDelegate {
    @Published var errorMessage: String?
    @Published var showCompletionAlert: Bool = false
    var otaProgress: OTAProgress

    init(otaProgress: OTAProgress) {
        self.otaProgress = otaProgress
    }

    func otaUpdateProgress(_ progress: Float) {
        DispatchQueue.main.async {
            self.otaProgress.progress = Double(progress)
            self.otaProgress.message = "Update Progress: \(String(format: "%.2f%%", self.otaProgress.progress))"
            print("OTA Update Progress: \(self.otaProgress.progress)%")
        }
    }

    func otaUpdateComplete() {
        DispatchQueue.main.async {
            self.otaProgress.message = "OTA Update Completed Successfully!"
            print("OTA Update Completed Successfully")
            self.showCompletionAlert = true
        }
    }

    func otaUpdateFailed(error: String) {
        DispatchQueue.main.async {
            self.otaProgress.message = "OTA Update Failed: \(error)"
            self.errorMessage = error // Asegurarse de actualizar el errorMessage
            print("OTA Update Failed: \(error)")
        }
    }
}
