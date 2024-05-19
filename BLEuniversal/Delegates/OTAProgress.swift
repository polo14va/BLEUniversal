//
//  OTAProgress.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 18/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import Foundation
import Combine

class OTAProgress: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var message: String = ""
}
