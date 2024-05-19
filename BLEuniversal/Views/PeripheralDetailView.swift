import CoreBluetooth
import SwiftUI

struct PeripheralDetailView: View {
    var peripheralId: String
    @EnvironmentObject var viewModel: BLEManager
    @State private var isNavigatingToServiceDetail = false
    
    private var peripheral: DiscoveredPeripheral? {
        viewModel.findPeripheral(by: peripheralId)
    }
    
    var body: some View {
        VStack {
            headerView
            serviceListView
        }
        .padding()
        .background(backgroundColor)
        .navigationTitle("Device Details")
        .onAppear {
            loadPeripheralDetails()
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                refreshButton
            }
        }
        .onChange(of: viewModel.discoveredPeripherals) { newValue, oldValue in
            withAnimation {
                self.updateView()
            }
        }
    }
    
    private func loadPeripheralDetails() {
        guard let peripheralToConnect = self.peripheral else { return }
        if peripheralToConnect.services.isEmpty {
            if peripheralToConnect.peripheral.state != .connected {
                viewModel.connectToDevice(peripheralToConnect)
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        if let peripheral = peripheral {
            VStack(alignment: .center, spacing: 8) {
                Text("\(peripheral.name)").font(.title)
                Text("ID: \(peripheral.id)").font(.caption)
                HStack {
                    VStack(alignment: .center) {
                        Text("Signal Strength: \(peripheral.rssi) dBm").font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .shadow(radius: 1)
                    
                    VStack(alignment: .center) {
                        Text("Total Services: \(peripheral.services.count)").font(.headline)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .shadow(radius: 1)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1)))
        } else {
            Text("Device not found").italic()
        }
    }
    
    @ViewBuilder
    private var serviceListView: some View {
        if let services = peripheral?.services, !services.isEmpty {
            List {
                Section(header: Text("Uncovered services")) {
                    ForEach(services) { service in
                        NavigationLink(destination: ServiceDetailView(serviceId: service.id)) {
                            VStack(alignment: .leading) {
                                Text("Service: \(viewModel.serviceName(for: service.service.uuid))").font(.headline)
                                Text("Characteristics: \(service.characteristics.count)").font(.caption)
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(backgroundColor)
        } else {
            VStack {
                ProgressView("Discovering services...").progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
    
    @ViewBuilder
    private var backButton: some View {
        Button(action: {
            viewModel.pop()
        }) {
            Label("Back", systemImage: "arrow.backward")
        }
    }
    
    @ViewBuilder
    private var refreshButton: some View {
        Button(action: {
            if let peripheral = self.peripheral {
                viewModel.connectToDevice(peripheral)
            }
        }) {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
    }

    private func updateView() {
        if peripheral != nil {
            self.loadPeripheralDetails()
        }
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
struct PeripheralDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralDetailView(peripheralId: "TestPeripheralID")
            .environmentObject(BLEManager.shared)
    }
}
#endif
