//  ServiceDetailView.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 29/2/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.import SwiftUI

import SwiftUI
import CoreBluetooth

struct ServiceDetailView: View {
    @EnvironmentObject var viewModel: BLEManager
    var serviceId: String
    
    private var service: SimpleService? {
        getService(by: serviceId)
    }
    
    var body: some View {
        VStack {
            if let service = service {
                Text("Service UUID: \(service.service.uuid.uuidString)").font(.headline)
                serviceListView(for: service)
            } else {
                Text("Service not found").font(.headline)
            }
        }
        .padding()
        .background(backgroundColor)
        .navigationTitle("Service Detail")
        .toolbar {
            #if os(macOS)
            ToolbarItem {
                Button(action: {
                    viewModel.pop()
                }) {
                    Label("Back", systemImage: "arrow.clockwise")
                }
            }
            #endif
        }
    }
    
    @ViewBuilder
    private func serviceListView(for service: SimpleService) -> some View {
        List {
            Section(header: Text("Characteristics")) {
                ForEach(service.characteristics, id: \.id) { characteristic in
                    if characteristic.characteristic.uuid == CBUUID(string: "fb1e4002-54ae-4a28-9f74-dfccb248601d") {
                        NavigationLink(destination: FileUploadView()) {
                            characteristicRow(for: characteristic)
                        }
                    } else {
                        NavigationLink(destination: CharacteristicDetailView(characteristicId: characteristic.id)) {
                            characteristicRow(for: characteristic)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(backgroundColor)
    }
    
    @ViewBuilder
    private func characteristicRow(for characteristic: SimpleCharacteristic) -> some View {
        VStack(alignment: .leading) {
            let uuidName = viewModel.serviceName(for: characteristic.characteristic.uuid)
            Text("Type: \(uuidName)")
            Text("Properties: \(characteristic.characteristic.properties.propertiesDescription)")
        }
    }
    
    private func getService(by id: String) -> SimpleService? {
        for peripheral in viewModel.discoveredPeripherals {
            if let service = peripheral.services.first(where: { $0.id == id }) {
                return service
            }
        }
        return nil
    }
    
    private var backgroundColor: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}

#if DEBUG
struct ServiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDetailView(serviceId: "TestServiceID")
            .environmentObject(BLEManager.shared)
    }
}
#endif
