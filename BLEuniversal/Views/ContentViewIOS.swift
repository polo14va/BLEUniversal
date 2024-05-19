//
//  ContentViewIOS.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 5/4/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
#if os(iOS)
import SwiftUI

struct ContentViewIOS: View {
    @EnvironmentObject var viewModel: BLEManager
    @State private var selectedPeripheralID: String?
    @State private var showingSettings: Bool = false
    @Environment(\.horizontalSizeClass) var sizeClass
    
    private var connectablesWithName: [DiscoveredPeripheral] {
        viewModel.discoveredPeripherals.filter { $0.isConnectable && !$0.name.isEmpty && $0.name != "Unknown" }.sorted(by: { $0.rssi > $1.rssi })
    }
    
    private var connectablesWithoutName: [DiscoveredPeripheral] {
        viewModel.discoveredPeripherals.filter { $0.isConnectable && ($0.name.isEmpty || $0.name == "Unknown") }.sorted(by: { $0.rssi > $1.rssi })
    }
    
    private var nonConnectables: [DiscoveredPeripheral] {
        viewModel.discoveredPeripherals.filter { !$0.isConnectable }.sorted(by: { $0.rssi > $1.rssi })
    }
    
    var body: some View {
        Group {
            if sizeClass == .compact {
                iPhoneView
            } else {
                iPadView
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var iPhoneView: some View {
        NavigationView {
            NavigationStack {
                listSection
                    .navigationTitle("Devices")
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            settingsButton
                            scanButton
                        }
                    }
            }
        }
    }
    
    private var iPadView: some View {
        NavigationSplitView {
            listSection
        } detail: {
            detailView
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                settingsButton
                scanButton
            }
        }
    }
    
    private var listSection: some View {
        NavigationStack {
            List {
                sectionView(for: connectablesWithName, title: "Connectables With Name", systemImage: "wifi")
                sectionView(for: connectablesWithoutName, title: "Connectables Without Name", systemImage: "wifi.exclamationmark")
                sectionView(for: nonConnectables, title: "Non-Connectables", systemImage: "wifi.slash")
            }
            .navigationTitle("Devices")
            .navigationDestination(for: String.self) { id in
                PeripheralDetailView(peripheralId: id)
            }
        }
    }
    
    private func sectionView(for peripherals: [DiscoveredPeripheral], title: String, systemImage: String) -> some View {
        Section(header: Text(title)) {
            ForEach(peripherals) { peripheral in
                NavigationLink(value: peripheral.id) {
                    PeripheralRow(peripheral: peripheral, systemImage: systemImage)
                }
                .tag(peripheral.id)
            }
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let id = selectedPeripheralID, viewModel.findPeripheral(by: id) != nil {
            PeripheralDetailView(peripheralId: id)
        } else {
            Text("Please select an item from the list").foregroundColor(.secondary)
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Label("Settings", systemImage: "gear")
                .labelStyle(IconOnlyLabelStyle())
        }
    }
    
    private var scanButton: some View {
        Button(action: toggleScanning) {
            Label(viewModel.isScanning ? "Pause" : "Start", systemImage: viewModel.isScanning ? "pause.fill" : "play.fill")
        }
    }
    
    private func toggleScanning() {
        if viewModel.isScanning {
            viewModel.stopScanning()
        } else {
            viewModel.startScanning()
        }
    }
    
    private func updateSelectionIfNeeded() {
        guard !viewModel.discoveredPeripherals.isEmpty else { return }
        
        let firstConnectable = viewModel.discoveredPeripherals.first { $0.isConnectable }
        if selectedPeripheralID == nil, let firstConnectable = firstConnectable {
            selectedPeripheralID = firstConnectable.id
        }
    }
}

struct ContentViewIOS_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewIOS().environmentObject(BLEManager())
    }
}
#endif
