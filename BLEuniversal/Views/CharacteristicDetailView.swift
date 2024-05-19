import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import Foundation
import CoreBluetooth

struct CharacteristicDetailView: View {
    @EnvironmentObject var viewModel: BLEManager

    @State private var baseValue: Data = Data()
    @State private var value = ""
    @State private var selectedFormat: DataFormat = .string
    @State private var showMessage = false
    @State private var alertMessage = "reading values..."
    @State private var alertMessageColor = Color.green
    @State private var offset: CGFloat = 0

    var characteristicId: String

    private var characteristic: SimpleCharacteristic? {
        viewModel.findCharacteristic(by: CBUUID(string: characteristicId))
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    if let characteristic = characteristic {
                        VStack(alignment: .leading) {
                            Text("Characteristic UUID: \(characteristic.characteristic.uuid.uuidString)")
                                .font(.headline)
                                .padding()

                            Picker("Format", selection: $selectedFormat) {
                                ForEach(DataFormat.allCases, id: \.self) {
                                    Text($0.rawValue).tag($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            .onChange(of: selectedFormat) { newValue , oldValue in
                                convertValueToSelectedFormat()
                            }

                            VStack {
                                TextField("", text: $value)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                                    .foregroundColor(.primary)
                                    .onChange(of: value) { newValue , oldValue in
                                        updateBaseValue(newValue)
                                    }
                            }
                            .background(Color.clear)

                            if characteristic.characteristic.properties.contains(.read) {
                                HStack {
                                    Button("Read Value") {
                                        readCharacteristic(characteristic)
                                    }
                                    .buttonStyle(ActionButtonStyle())

                                    if canWrite {
                                        Button("Write Value") {
                                            writeCharacteristic(characteristic)
                                        }
                                        .buttonStyle(ActionButtonStyle())
                                    }
                                }
                                .padding(.top)
                            }
                            
                            HStack {
                                Button("Copy") {
                                    copyToClipboard(value)
                                }
                                .buttonStyle(ActionButtonStyle())

                                Button("Paste") {
                                    pasteFromClipboard()
                                }
                                .buttonStyle(ActionButtonStyle())
                            }
                            .padding(.top)
                        }
                        .padding()
                        #if os(iOS)
                        .background(Color(.secondarySystemBackground))
                        #else
                        .background(Color.gray.opacity(0.1))
                        #endif
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    } else {
                        Text("Characteristic not found")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color.gray.opacity(0.1))
                #endif
            }
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    offset = keyboardFrame.height - geometry.safeAreaInsets.bottom
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                offset = 0
            }
            #endif
            .padding(.bottom, offset)
            .animation(.easeOut(duration: 0.16), value: offset)
            .task {
                readCharacteristicIfNeeded()
            }
        }
        .navigationTitle("Characteristic Details")
    }

    private var canWrite: Bool {
        characteristic?.characteristic.properties.contains(.write) ?? false ||
        characteristic?.characteristic.properties.contains(.writeWithoutResponse) ?? false
    }

    private func readCharacteristicIfNeeded() {
        guard let characteristic = characteristic, characteristic.characteristic.properties.contains(.read) else {
            return
        }
        readCharacteristic(characteristic)
    }

    private func readCharacteristic(_ characteristic: SimpleCharacteristic) {
        viewModel.readCharacteristic(characteristic) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.baseValue = data
                    self.updateValueAndFormat()
                    print("Read value: \(self.value)")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.value = "Error: \(error.localizedDescription)"
                    print("Read error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func writeCharacteristic(_ characteristic: SimpleCharacteristic) {
        viewModel.writeCharacteristic(characteristic, data: baseValue) { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    print("Wrote value: \(self.value)")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.value = "Error: \(error.localizedDescription)"
                    print("Write error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateValueAndFormat() {
        if let utf8String = String(data: baseValue, encoding: .utf8) {
            self.value = utf8String
            self.selectedFormat = .string
        } else {
            self.value = baseValue.toHex()
            self.selectedFormat = .hex
        }
    }

    private func convertValueToSelectedFormat() {
        switch selectedFormat {
        case .string:
            value = String(data: baseValue, encoding: .utf8) ?? ""
        case .hex:
            value = baseValue.toHex()
        case .binary:
            value = baseValue.toBinary()
        case .decimal:
            value = baseValue.map { String($0) }.joined(separator: " ")
        }
    }

    private func updateBaseValue(_ newValue: String) {
        switch selectedFormat {
        case .string:
            baseValue = newValue.data(using: .utf8) ?? Data()
        case .hex:
            baseValue = newValue.hexToData()
        case .binary:
            baseValue = newValue.binaryToData()
        case .decimal:
            baseValue = Data(newValue.split(separator: " ").compactMap { UInt8($0) })
        }
        value = newValue
    }

    private func copyToClipboard(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    private func pasteFromClipboard() {
        #if os(iOS)
        if let string = UIPasteboard.general.string {
            value = string
            updateBaseValue(string)
        }
        #elseif os(macOS)
        if let string = NSPasteboard.general.string(forType: .string) {
            value = string
            updateBaseValue(string)
        }
        #endif
    }

    private func updateCharacteristicValue() {
        if let characteristic = characteristic, let latestValue = characteristic.latestValue {
            self.baseValue = latestValue
            convertValueToSelectedFormat()
        }
    }
}
