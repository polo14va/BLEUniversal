// OTAProgressView.swift
// BLEUniversal
//
// Created by Pedro Martinez Acebron on 12/5/24.
// Copyright © 2024 pedromartinezweb. All rights reserved.

import SwiftUI

struct OTAProgressView: View {
    @ObservedObject var otaProgress: OTAProgress
    @Binding var isPresented: Bool
    @State private var showCompletionAlert: Bool = false

    var otaManager: OTAManager

    var body: some View {
        VStack {
            Text("OTA Firmware Update")
                .font(.largeTitle)
                .padding()

            ProgressView(value: otaProgress.progress, total: 100.0)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Text("\(Int(otaProgress.progress))%")
                .font(.title2)
                .padding()

            Text(otaProgress.message)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .lineLimit(10)

            Button("Cancel") {
                otaManager.cancelUpdate()
                isPresented = false
            }
            .padding()
            .buttonStyle(ActionButtonStyle())
        }
        .padding()
        .onChange(of: otaProgress.progress) { progress, old in
            if progress >= 100 {
                showCompletionAlert = true
            }
        }
        .alert(isPresented: $showCompletionAlert) {
            Alert(
                title: Text("OTA Update Completed"),
                message: Text("OTA Update Completed Successfully!"),
                dismissButton: .default(Text("Restart App")) {
                    self.isPresented = false
//                    otaManager.bleManager.resetApp()
                }
            )
        }
    }
}
