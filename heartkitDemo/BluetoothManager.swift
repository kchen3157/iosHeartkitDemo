//
//  BluetoothManager.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-10.
//

import Foundation
import CoreBluetooth

let ECG_SERVICE_CBUUID = CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2000")
let ECG_SAMPLE_DATA_CHARACTERISTIC_CBUUID = CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2012")
let ECG_SAMPLE_MASK_CHARACTERISTIC_CBUUID = CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2013")
let ECG_RESULT_CHARACTERISTIC_CBUUID = CBUUID(string: "00002760-08C2-11E1-9073-0E8AC72E2014")
let HR_SERVICE_CBUUID = CBUUID(string: "0x180D")

let HK_HEART_RATE_LABELS: Array<String> = Array(arrayLiteral: "NORMAL", "TACHYCARDIA", "BRADYCARDIA")


var startDataCollection = false

struct Result {
    var heartRate = UInt32()
    var heartRhythm = String()
    var heartRhythmID = UInt32()
    var numTotalBeats = UInt32()
    var numNormBeats = UInt32()
    var numPacBeats = UInt32()
    var numPvcBeats = UInt32()
    var arrhythmia = Bool()
}


class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    
    
    var centralManager: CBCentralManager!
    var ECGSensorPeripheral: CBPeripheral!
    @Published var CBCentralManagerState = String("unknown")
    @Published var sampleDataLog = String()
    @Published var resultLog = String()
    @Published var sampleData: Array<Float> = Array()
    @Published var results = Result()
    @Published var segMask = SegMask()
    var temp: Array<Data> = Array()
    
    
    
    // Init centralManager
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Display to verify Core Bluetooth Manager state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .unknown:
                self.CBCentralManagerState = "unknown"
                print("central.state is .unknown")
            case .resetting:
                self.CBCentralManagerState = "resetting"
                print("central.state is .resetting")
            case .unsupported:
                self.CBCentralManagerState = "unsupported"
                print("central.state is .unsupported")
            case .unauthorized:
                self.CBCentralManagerState = "unauthorized"
                print("central.state is .unauthorized")
            case .poweredOff:
                self.CBCentralManagerState = "poweredOff"
                print("central.state is .poweredOff")
            case .poweredOn:
                self.CBCentralManagerState = "poweredOn"
                print("central.state is .poweredOn")
            @unknown default:
                self.CBCentralManagerState = "unknown"
                print("central.state is unknown")
            }
        }
    }
    
    // Function to start scanning
    func startScanning() {
        startDataCollection = false
        centralManager.scanForPeripherals(withServices: [ECG_SERVICE_CBUUID, HR_SERVICE_CBUUID])
        print("scanStart")
        DispatchQueue.main.async {
            self.CBCentralManagerState = "scanStart"
        }
    }
    
    // Function to stop scanning
    func stopScanning() {
        centralManager.stopScan()
        print("scanStop")
        DispatchQueue.main.async {
            self.CBCentralManagerState = "scanStop"
        }
    }
    
}

// Extension compliant to handle peripheral
extension BluetoothManager: CBPeripheralDelegate {
    
    // After peripheral is discovered, connect to peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        ECGSensorPeripheral = peripheral
        ECGSensorPeripheral.delegate = self
        stopScanning()
        centralManager.connect(ECGSensorPeripheral)
    }
    
    // After peripheral connection successful, display and then discover services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.CBCentralManagerState = "connected"
        }
        print("Connected to \(ECGSensorPeripheral.name ?? "nameUnknown")")
        ECGSensorPeripheral.discoverServices([ECG_SERVICE_CBUUID])
    }
    
    // After services discovered, display and then discover chars for each service.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("Found Services:")
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // After chars discovered, display.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        print("Found Characteristics:")
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            print(characteristic)
        }
    }
    
    // Upon characteristic value update, run helper functions to parse new data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.main.async {
            switch characteristic.uuid {
            case ECG_SAMPLE_DATA_CHARACTERISTIC_CBUUID:
                self.sampleDataLog = self.parseECGSample(from: characteristic)
                let sampleIndex = characteristic.value!.uint32
                print("Got ECGSample \(sampleIndex): \(self.sampleDataLog)")
            case ECG_SAMPLE_MASK_CHARACTERISTIC_CBUUID:
                print("Got ECGMask \(characteristic.value?.count ?? -1)")
                self.parseECGMask(from: characteristic)
            case ECG_RESULT_CHARACTERISTIC_CBUUID:
                self.resultLog = self.parseECGResult(from: characteristic)
                print("""
                Got ECGResult:
                \(self.resultLog)
                """)
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
        
    }
    
    // function to disconnect peripheral
    func disconnectPeripheral() {
        centralManager.cancelPeripheralConnection(ECGSensorPeripheral)
    }
    
    
    // After peripheral disconnection, update state and clear data.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            print("Disconnected from \(self.ECGSensorPeripheral.name ?? "nameUnknown")")
            self.CBCentralManagerState = "disconnected"
            startDataCollection = false
            self.dataClear(willClearResults: true)
        }
    }
    
    // function to clear data
    func dataClear(willClearResults clearResults: Bool) {
        DispatchQueue.main.async {
            self.sampleDataLog = ""
            self.sampleData.removeAll()
            self.resultLog = ""
            if (clearResults) {
                self.results = Result()
            }
        }
    }
    
    // Handle incoming ECGSample, store into data array, return first float value of array as string.
    private func parseECGSample(from characteristic: CBCharacteristic) -> String {
        
        let index = characteristic.value!.prefix(upTo: 4).uint32
        if (index == 0) {
            startDataCollection = true
            dataClear(willClearResults: false)
        }
        
        if (startDataCollection) {
            
            let dataRaw = characteristic.value!.dropFirst(4)
            let dataLen = dataRaw.count
            
            for i in stride(from: 0, to: dataLen, by: 4) {
                sampleData.append(Float(bitPattern: dataRaw.dropFirst(i).uint32))
            }
            
            
            //      if (index == 2450) {
            //        print(sampleData as Array)
            //      }
            
            return String(format: "%08f", Float(bitPattern: dataRaw.uint32))
        }
        return "Waiting for next data transfer"
        
    }
    
    private func parseECGMask(from characteristic: CBCharacteristic) -> Void {
        if (startDataCollection) {
            segMask.push(data: characteristic.value!)
        }
        
        if (segMask.maskData.count == 2500) {
            segMask.printRaw()
        }
    }
    
    // Handle incoming ECGResult, return String summary of preceding ECG Data.
    private func parseECGResult(from characteristic: CBCharacteristic) -> String {
        
        if (startDataCollection) {
            let data = characteristic.value!
            
            results.heartRate = data.uint32
            results.heartRhythmID = data.dropFirst(4).uint32
            results.heartRhythm = HK_HEART_RATE_LABELS[Int(results.heartRhythmID)]
            results.numNormBeats = data.dropFirst(8).uint32
            results.numPacBeats = data.dropFirst(12).uint32
            results.numPvcBeats = data.dropFirst(16).uint32
            results.numTotalBeats = results.numNormBeats + results.numPacBeats + results.numPvcBeats
            results.arrhythmia = data.dropFirst(20).uint32 == 0 ? false : true
            
            
            return """
          Heart Rate: \(results.heartRate)
          Heart Rhythm: \(results.heartRhythm)
          Number of Normal Beats: \(results.numNormBeats)
          Number of Pac Beats: \(results.numPacBeats)
          Number of Pvc Beats: \(results.numPvcBeats)
          Arrhythmia: \(results.arrhythmia)
        """
        }
        
        return "Result of Incomplete Data"
    }
    
}


extension Data {
    var uint32: UInt32 {
        return UInt32(littleEndian: self.withUnsafeBytes { bytes in
            bytes.load(as: UInt32.self)
        })
    }
    
    var uint8: UInt8 {
        return UInt8(littleEndian: self.withUnsafeBytes { bytes in
            bytes.load(as: UInt8.self)
        })
    }
}
