//
//  DetailView.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 29/3/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//
import SwiftUI
struct DetailView: View {
    @EnvironmentObject var viewModel: BLEManager
    
    var body: some View {
        VStack {
            switch viewModel.selectedNavigationItem {
            case .peripheral(let id):
                PeripheralDetailView(peripheralId: id)
            case .service(let id):
                ServiceDetailView(serviceId: id)
            case .characteristic(let id):
                CharacteristicDetailView(characteristicId: id)
            case .settings:
                SettingsView()
            case .none:
                Text("Select an item from the list")
            }
        }
    }
}
