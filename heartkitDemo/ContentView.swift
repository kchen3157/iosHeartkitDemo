//
//  ContentView.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-09.
//

import SwiftUI
import CoreBluetooth
import Charts

struct ContentView: View {
    
    
    @ObservedObject var bluetoothManager = BluetoothManager()
    
    var body: some View {
        VStack {
            Chart(0..<bluetoothManager.sampleData.count, id: \.self) { nr in
                LineMark(
                    x: .value("X values", nr),
                    y: .value("Y values", bluetoothManager.sampleData[nr])
                )
                .lineStyle(.init(lineWidth: 1))
            }
            .frame(width: 400, height: 200)
            .chartYScale(domain: -6...6)
            .chartXScale(domain: 0...2500)
            
            Text("Bluetooth Status: \(bluetoothManager.CBCentralManagerState)")
            Text("ECGSample Get: \(bluetoothManager.sampleDataLog)")
            Text("""
                 ECGResult Get:
                 \(bluetoothManager.resultLog)
                 """)
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
