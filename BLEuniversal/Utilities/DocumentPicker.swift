//
//  DocumentPicker.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 18/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Binding var errorMessage: String?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType("public.data")!], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                parent.errorMessage = "Unable to access the selected file."
                return
            }
            // Ensure that the URL is accessible outside the sandbox
            _ = url.startAccessingSecurityScopedResource()
            parent.fileURL = url
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.errorMessage = "File selection was cancelled."
        }
    }
}
#endif
