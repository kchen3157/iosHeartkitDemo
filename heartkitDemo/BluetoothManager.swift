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


    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
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
    
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [ECG_SERVICE_CBUUID, HR_SERVICE_CBUUID])
        print("Scanning Started")
        DispatchQueue.main.async {
            self.CBCentralManagerState = "Scanning Started"
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
        print("Scanning Stopped")
        DispatchQueue.main.async {
            self.CBCentralManagerState = "Scanning Stopped"
        }
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        ECGSensorPeripheral = peripheral
        ECGSensorPeripheral.delegate = self
        stopScanning()
        centralManager.connect(ECGSensorPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.CBCentralManagerState = "Connected to \(self.ECGSensorPeripheral.name ?? "nameUnknown")"
        }
        print("Connected to \(ECGSensorPeripheral.name ?? "nameUnknown")")
        ECGSensorPeripheral.discoverServices([ECG_SERVICE_CBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("Found Services:")
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        print("Found Characteristics:")
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("Characteristic \(characteristic.uuid) properties contains read flag.")
            }
            if characteristic.properties.contains(.notify) {
                print("Characteristic \(characteristic.uuid) properties contains notify flag.")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.main.async {
            switch characteristic.uuid {
            case ECG_SAMPLE_DATA_CHARACTERISTIC_CBUUID:
                self.sampleDataLog = self.ParseECGSample(from: characteristic)
                print("Got ECGSample: \(self.sampleDataLog)")
            case ECG_SAMPLE_MASK_CHARACTERISTIC_CBUUID:
                print("Notified of ECGSampleMask")
            case ECG_RESULT_CHARACTERISTIC_CBUUID:
                self.resultLog = self.ParseECGResult(from: characteristic)
                print("""
                Got ECGResult:
                \(self.resultLog)
                """)
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
        
    }
    
    private func ParseECGSample(from characteristic: CBCharacteristic) -> String {
        
        let index = characteristic.value!.prefix(upTo: 4).uint32
        if (index == 0) {
            startDataCollection = true
            sampleData.removeAll(keepingCapacity: false)
            resultLog = ""
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
        return "Incomplete Data"
        
    }
    
    
    private func ParseECGResult(from characteristic: CBCharacteristic) -> String {
        
        if (startDataCollection) {
            let data = characteristic.value!
            
            results.heartRate = data.uint32
            results.heartRhythmID = data.dropFirst(4).uint32
            results.heartRhythm = HK_HEART_RATE_LABELS[Int(results.heartRhythmID)]
            results.numNormBeats = data.dropFirst(8).uint32
            results.numPacBeats = data.dropFirst(12).uint32
            results.numPvcBeats = data.dropFirst(16).uint32
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
    var uint32:UInt32 {
        return UInt32(littleEndian: self.withUnsafeBytes { bytes in
            bytes.load(as: UInt32.self)
        })
    }
}
