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
    
    var heartRhythmText: String {
        if bluetoothManager.results.heartRhythm == "" {
            return "--"
        }
        return bluetoothManager.results.heartRhythm
    }
    
    var body: some View {
        // Color vars
        let normColor = Color.blue
        let pacColor = Color.green
        let pvcColor = Color.orange
        let ecgColor = Color.red
        let bpmColor = Color.red
        
        VStack {
            // ECG Graph
            ECGGraph(data: bluetoothManager.sampleData, ecgColor: ecgColor, normColor: normColor)
            
            
            
            // Rhythm Type
            VStack {
                Text(heartRhythmText)
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                
                Text("HEART RHYTHM")
                    .font(.footnote)
            }
            
            // HR and Beat guages
            HStack(alignment: .top) {
                
                HRGuageView(value: Double(bluetoothManager.results.heartRate), minValue: 0, maxValue: 150, color: bpmColor)
                    .padding()
                
                BeatGuageView(numNormBeats: Double(bluetoothManager.results.numNormBeats), numPacBeats: Double(bluetoothManager.results.numPacBeats), numPvcBeats: Double(bluetoothManager.results.numPvcBeats))
                    .padding()
            }
            
            // Debugging stata
            Text("Bluetooth Status: \(bluetoothManager.CBCentralManagerState)")
            Text("ECG Get: \(bluetoothManager.sampleDataLog)")
            //            Text("""
            //                 ECGResult Get:
            //                 \(bluetoothManager.resultLog)
            //                 """)
            
            //Button
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
        
    }    
}

#Preview {
    ContentView()
}
