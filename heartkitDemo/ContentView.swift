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
        let normColor = Color.blue
        let pacColor = Color.purple
        let pvcColor = Color.red
        let ecgColor = Color.red
        let bpmColor = Color.red
        
        VStack {
            
            ZStack(alignment: .top) {
                Chart(0..<bluetoothManager.sampleData.count, id: \.self) { nr in
                    LineMark(
                        x: .value("X values", nr),
                        y: .value("Y values", bluetoothManager.sampleData[nr])
                    )
                    .lineStyle(.init(lineWidth: 1))
                    .foregroundStyle(ecgColor)
                    
                }
                .frame(width: 380, height: 200)
                .chartYScale(domain: -6...6)
                .chartXScale(domain: 0...2500)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 0))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 0))
                }
                
                // Beat Labels
                GeometryReader { geometry in
                    ZStack{
                        Path { path in
                            for x in bluetoothManager.segMask.beatIdxs() {
                                let normalizedX = CGFloat(x) * geometry.size.width / CGFloat(SAMPLE_SIZE)
                                path.move(to: CGPoint(x: normalizedX, y: 0))
                                path.addLine(to: CGPoint(x: normalizedX, y: geometry.size.height - 20))
                            }
                        }
                        .stroke(normColor, lineWidth: 1)
                        
//                        ForEach(bluetoothManager.segMask.normalBeatIdxs().indices, id: \.self) { x in
//                            let normalizedX = CGFloat(bluetoothManager.segMask.normalBeatIdxs()[x]) * geometry.size.width / CGFloat(SAMPLE_SIZE)
//                            Text("""
//                                N
//                                S
//                                R
//                                """)
//                                .font(.caption)
//                                .foregroundStyle(normColor)
//                                .bold()
//                                .position(x: normalizedX, y: geometry.size.height - 20)
//                        }
                    }
                    
                }
                .frame(width: 380, height: 220)

            }
            .frame(width: 380, height: 240)
            
            
            
            
            VStack {
                var heartRhythmText: String {
                    if bluetoothManager.results.heartRhythm == "" {
                        return "--"
                    }
                    return bluetoothManager.results.heartRhythm
                }
                
                Text(heartRhythmText)
                    .font(.title)
                    .bold()
                    .lineLimit(1)
                
                Text("HEART RHYTHM")
                    .font(.footnote)
            }
            
            
            HStack(alignment: .top) {
                
                HRGuageView(value: Double(bluetoothManager.results.heartRate), minValue: 0, maxValue: 150, color: bpmColor)
                    .padding()
                
                BeatGuageView(normBeats: Double(bluetoothManager.results.numNormBeats), pacBeats: Double(bluetoothManager.results.numPacBeats), pvcBeats: Double(bluetoothManager.results.numPvcBeats), title: "BEATS", normColor: normColor, pacColor: pacColor, pvcColor: pvcColor)
                    .padding()
            }
            
            
            Text("Bluetooth Status: \(bluetoothManager.CBCentralManagerState)")
            Text("ECG Get: \(bluetoothManager.sampleDataLog)")
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
