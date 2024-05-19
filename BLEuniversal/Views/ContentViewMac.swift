//
//  ContentViewMac.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 5/4/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
#if os(macOS)
import SwiftUI

struct ContentViewMacOS: View {
    @EnvironmentObject var viewModel: BLEManager
    @State private var selectedNavigationItem: NavigationItem?

    private var connectablesWithName: [DiscoveredPeripheral] {
        viewModel.discoveredPeripherals.filter { $0.isConnectable && !$0.name.isEmpty && $0.name != "Unknown" }
            .sorted { $0.rssi > $1.rssi }
    }

    private var connectablesWithoutName: [DiscoveredPeripheral] {
        viewModel.discoveredPeripherals.filter { $0.isConnectable && ($0.name.isEmpty || $0.name == "Unknown") }
            .sorted { $0.rssi > $1.rssi }
    }

    private var nonConnectables: [DiscoveredPeripheral] {
        viewModel.discoveredPeripherals.filter { !$0.isConnectable }
            .sorted { $0.rssi > $1.rssi }
    }

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            NavigationSplitView {
                listSection
                .toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        settingsButton
                        scanButton
                    }
                }
            } detail: {
                detailView
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.startScanning()
                }
            }
        }
    }

    private var listSection: some View {
        List(selection: $selectedNavigationItem) {
            sectionView(for: connectablesWithName, title: "Connectables With Name", systemImage: "wifi")
            sectionView(for: connectablesWithoutName, title: "Connectables Without Name", systemImage: "wifi.exclamationmark")
            sectionView(for: nonConnectables, title: "Non-Connectables", systemImage: "wifi.slash")
        }
        .listStyle(SidebarListStyle())
    }

    private func sectionView(for peripherals: [DiscoveredPeripheral], title: String, systemImage: String) -> some View {
        Section(header: Text(title)) {
            ForEach(peripherals) { peripheral in
                NavigationLink(value: NavigationItem.peripheral(id: peripheral.id)) {
                    PeripheralRow(peripheral: peripheral, systemImage: systemImage)
                }
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedNavigationItem {
        case .peripheral(let id):
            PeripheralDetailView(peripheralId: id)
        case .settings:
            SettingsView()
        case nil:
            Text("Select a device or go to settings").foregroundColor(.secondary)
        default:
            Text("Detail not available").foregroundColor(.secondary)
        }
    }

    private var settingsButton: some View {
        Button(action: {
            selectedNavigationItem = .settings
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
}

struct ContentViewMacOS_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewMacOS().environmentObject(BLEManager.shared)
    }
}
#endif
