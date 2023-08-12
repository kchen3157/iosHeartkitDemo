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
    
    var buttonText: String {
        if bluetoothManager.CBCentralManagerState == "connected" {
            return "Disconnect"
        } else if bluetoothManager.CBCentralManagerState == "scanStart" {
            return "Stop Scan"
        } else if bluetoothManager.CBCentralManagerState == "scanStop" ||
                    bluetoothManager.CBCentralManagerState == "poweredOn" ||
                    bluetoothManager.CBCentralManagerState == "disconnected" {
            return "Start Scan"
        } else {
            return "Check BT"
        }
    }
    
    var body: some View {
        VStack {
            Chart(0..<bluetoothManager.sampleData.count, id: \.self) { nr in
                LineMark(
                    x: .value("X values", nr),
                    y: .value("Y values", bluetoothManager.sampleData[nr])
                )
                .lineStyle(.init(lineWidth: 1))
            }
            .frame(width: 380, height: 200)
            .chartYScale(domain: -6...6)
            .chartXScale(domain: 0...2500)
            
            
            HStack(alignment: .top) {
                
                VStack {
                    HRGuageView(value: Double(bluetoothManager.results.heartRate), minValue: 0, maxValue: 150)
                        .padding()
                    
                    VStack {
                        Text(bluetoothManager.results.heartRhythm)
                            .font(.title2)
                            .bold()

                        Text("HEART RHYTHM")
                            .font(.footnote)
                    }
                }
                
                BeatGuageView(normBeats: Double(bluetoothManager.results.numNormBeats), pacBeats: Double(bluetoothManager.results.numPacBeats), pvcBeats: Double(bluetoothManager.results.numPvcBeats), title: "BEATS")
                    .padding()
            }
            
            
            Text("Bluetooth Status: \(bluetoothManager.CBCentralManagerState)")
            Text("ECGSample Get: \(bluetoothManager.sampleDataLog)")
//            Text("""
//                 ECGResult Get:
//                 \(bluetoothManager.resultLog)
//                 """)
            
            
            Button(action: {
                if buttonText == "Disconnect" {
                    bluetoothManager.disconnectPeripheral()
                } else if buttonText == "Stop Scan" {
                    bluetoothManager.stopScanning()
                } else if buttonText == "Start Scan" {
                    bluetoothManager.startScanning()
                }
            }) {
                Text(buttonText)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        
    }
}

#Preview {
    ContentView()
}
