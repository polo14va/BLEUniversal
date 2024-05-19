//
//  SuccessView.swift
//  BLEUniversal
//
//  Created by Pedro Martinez Acebron on 17/5/24.
//  Copyright © 2024 pedromartinezweb. All rights reserved.
//

import SwiftUI

struct SuccessView: View {
    @State private var timeRemaining: Int = 10
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("OTA Update Completed Successfully!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            Text("Returning to the main screen in \(timeRemaining) seconds.")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Spacer()
                    Text("Accept")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


#if DEBUG
struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView().environmentObject(BLEManager.shared)
    }
}
#endif
