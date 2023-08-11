//
//  ContentView.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-09.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()

    var body: some View {
        VStack {
            Text("Bluetooth Status: \(bluetoothManager.centralManager.state.rawValue)")
            Button("Start Scanning") {
                bluetoothManager.startScanning()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
