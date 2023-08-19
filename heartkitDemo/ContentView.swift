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
    
    func formatText(input: String) -> String {
        return input == "" ? "--" : input
    }
    
    var body: some View {
        // Color vars
        let normColor = Color.blue
        let pacColor = Color.green
        let pvcColor = Color.orange
        let ecgColor = Color.red
        let bpmColor = Color.red
        
        VStack(alignment: .center) {
            // ECG Graph
            ECGGraph(data: bluetoothManager.sampleData, ecgColor: ecgColor, normColor: normColor)
                .padding()
            
            // Rhythm Type
            Text(formatText(input:bluetoothManager.results.heartRhythm))
                .font(.largeTitle.bold())
                .lineLimit(1)
                .padding()
            
            Text("HEART RHYTHM")
                .font(.footnote)
            
            // HR and Beat guages
            HRGuageView(value: Double(bluetoothManager.results.heartRate), minValue: 0, maxValue: 200, color: bpmColor)
                    .padding(.horizontal, 15)
                    .padding()

            
            
            BeatGuageView(numNormBeats: Double(bluetoothManager.results.numNormBeats), numPacBeats: Double(bluetoothManager.results.numPacBeats), numPvcBeats: Double(bluetoothManager.results.numPvcBeats))
                .padding()
            
            
            
            
            
            // Debugging stata
            HStack {
                VStack {
                    Text(formatText(input: bluetoothManager.CBCentralManagerState))
                        .font(.title2.bold())
                    Text("BLE Status")
                        .font(.footnote)
                }
                .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                VStack {
                    Text(formatText(input: bluetoothManager.sampleDataLog))
                        .font(.title2.bold())
                    Text("ECG Status")
                        .font(.footnote)
                }
                .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            }
            .padding()
            
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
