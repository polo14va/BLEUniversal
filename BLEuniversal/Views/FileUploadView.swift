// FileUploadView.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 18/4/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers
import CoreBluetooth

let UART_RX_CHAR_UUID = CBUUID(string: "fb1e4002-54ae-4a28-9f74-dfccb248601d")
let UART_TX_CHAR_UUID = CBUUID(string: "fb1e4003-54ae-4a28-9f74-dfccb248601d")

struct FileUploadView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Environment(\.presentationMode) var presentationMode
    @State private var fileURL: URL?
    @State private var errorMessage: String?
    @State private var isPresentingDocumentPicker: Bool = false
    @StateObject private var otaProgress = OTAProgress()
    @State private var showOTAProgressView: Bool = false
    @State private var otaManager: OTAManager?
    @StateObject private var uploadDelegate: FileUploadDelegate
    @State private var showRestartAlert: Bool = false

    init() {
        let otaProgress = OTAProgress()
        _uploadDelegate = StateObject(wrappedValue: FileUploadDelegate(otaProgress: otaProgress))
        _otaProgress = StateObject(wrappedValue: otaProgress)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Select the firmware file (.bin) to send OTA update.")
                .padding()
                .multilineTextAlignment(.center)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("Select File") {
                selectFile()
            }
            .padding()
            .buttonStyle(ActionButtonStyle())

            if let fileURL = fileURL {
                HStack {
                    Text("Selected file: \(fileURL.lastPathComponent)")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Button(action: {
                        self.fileURL = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                Button("Send OTA Update") {
                    checkServicesAndSendOTAUpdate(fileURL)
                }
                .padding()
                .buttonStyle(ActionButtonStyle())
            }
        }
        .sheet(isPresented: $isPresentingDocumentPicker) {
            #if os(iOS)
            DocumentPicker(fileURL: $fileURL, errorMessage: $errorMessage)
            #endif
        }
        .sheet(isPresented: $showOTAProgressView) { // Usar .sheet en lugar de .fullScreenCover
            if let otaManager = otaManager {
                OTAProgressView(
                    otaProgress: otaProgress,
                    isPresented: $showOTAProgressView,
                    otaManager: otaManager
                )
            } else {
                Text("Error: OTA Manager no está inicializado.")
            }
        }
        .alert(isPresented: $showRestartAlert) {
            Alert(
                title: Text("Device Restarting"),
                message: Text("Your device is restarting. Please wait a few seconds."),
                dismissButton: .default(Text("Accept")) {
                    restartApp()
                }
            )
        }
        .onChange(of: uploadDelegate.errorMessage) { error, oldv in
            if let error = error {
                self.errorMessage = error
            }
        }
        .onChange(of: otaProgress.message) { message, oldv in
            print(message)
            if message == "OTA Update Completed Successfully!" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showRestartAlert = true
                }
            }
        }
        .onChange(of: otaProgress.progress) { progress, oldv in
            print("Progress updated in view: \(progress)%")
        }
    }

    private func selectFile() {
        #if os(iOS)
        isPresentingDocumentPicker = true
        #elseif os(macOS)
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType(filenameExtension: "bin")!]

        if panel.runModal() == .OK {
            self.fileURL = panel.urls.first
        } else {
            self.errorMessage = "File selection was cancelled."
        }
        #endif
    }

    private func checkServicesAndSendOTAUpdate(_ url: URL) {
        guard let peripheral = bleManager.connectedPeripheral else {
            errorMessage = "No connected peripheral."
            return
        }

        if peripheral.isDiscoveringServices {
            peripheral.pauseServiceDiscovery()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.sendOTAUpdate(url)
            }
        } else {
            sendOTAUpdate(url)
        }
    }

    private func sendOTAUpdate(_ url: URL) {
        do {
            let firmwareData = try Data(contentsOf: url)
            otaProgress.progress = 0.0
            otaProgress.message = "Starting OTA Update..."

            guard let peripheral = bleManager.connectedPeripheral else {
                errorMessage = "No connected peripheral."
                return
            }

            guard let rxCharacteristic = bleManager.findCharacteristic(by: UART_RX_CHAR_UUID),
                  let txCharacteristic = bleManager.findCharacteristic(by: UART_TX_CHAR_UUID) else {
                errorMessage = "RX or TX Characteristic not found."
                return
            }

            let otaManager = OTAManager(
                peripheral: peripheral,
                rxCharacteristic: rxCharacteristic.characteristic,
                txCharacteristic: txCharacteristic.characteristic,
                firmwareData: firmwareData,
                delegate: uploadDelegate,
                bleManager: bleManager
            )

            bleManager.otaManager = otaManager
            self.otaManager = otaManager
            peripheral.setNotifyValue(true, for: txCharacteristic.characteristic)
            otaManager.startUpdate()
            showOTAProgressView = true
        } catch {
            errorMessage = "Failed to read firmware data: \(error.localizedDescription)"
        }
    }

    private func restartApp() {
        presentationMode.wrappedValue.dismiss()
        bleManager.discoveredPeripherals.removeAll()
        bleManager.startScanning()
    }
}
