import CoreBluetooth

extension CBCharacteristicProperties {
    var propertiesDescription: String {
        var descriptions: [String] = []
        if contains(.broadcast) {
            descriptions.append("Broadcast")
        }
        if contains(.read) {
            descriptions.append("Read")
        }
        if contains(.writeWithoutResponse) {
            descriptions.append("WriteWithoutResponse")
        }
        if contains(.write) {
            descriptions.append("Write")
        }
        if contains(.notify) {
            descriptions.append("Notify")
        }
        if contains(.indicate) {
            descriptions.append("Indicate")
        }
        if contains(.authenticatedSignedWrites) {
            descriptions.append("AuthenticatedSignedWrites")
        }
        if contains(.extendedProperties) {
            descriptions.append("ExtendedProperties")
        }
        if contains(.notifyEncryptionRequired) {
            descriptions.append("NotifyEncryptionRequired")
        }
        if contains(.indicateEncryptionRequired) {
            descriptions.append("IndicateEncryptionRequired")
        }
        return descriptions.joined(separator: ", ")
    }
}
