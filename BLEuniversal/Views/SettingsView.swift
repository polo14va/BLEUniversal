//
//  SettingsView.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 25/2/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    
    var body: some View {
        List {
            Section(header: Text("Support")) {
                Link("Send email to support contact", destination: URL(string: "mailto:support@pedromartinezweb.com")!)
            }
            
            Section(header: Text("App Info")) {
                Text("Version: \(appVersion)-\(buildNumber)")
                Link("Web support", destination: URL(string: "https://pedromartinezweb.com")!)
            }
        }
        .navigationTitle("Settings")
    }
}
