//
//  SegMask.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-12.
//

import Foundation

class SegMask {
    
    var maskData: Array<UInt8> = Array()
    
    
    func push(data: Data) {
        for i in 0..<data.count {
            maskData.append(data.dropFirst(i).uint8)
        }
    }
    
    func printRaw() {
        print(maskData as Array)
    }
    
    func beatIdxs() -> Array<Int> {
        var idxs: Array<Int> = []
        for i in 0..<maskData.count {
            if (maskData[i] >> 4) != 0 {
                idxs.append(i)
            }
        }
        return idxs
    }
    
    func normalBeatIdxs() -> Array<Int> {
        var idxs: Array<Int> = []
        for beatIdx in self.beatIdxs() {
            if (self.maskData[beatIdx] >> 4) == 1 {
                idxs.append(beatIdx)
            }
        }
        return idxs
    }
    
    func pacBeatIdxs() -> Array<Int> {
        var idxs: Array<Int> = []
        for beatIdx in self.beatIdxs() {
            if (self.maskData[beatIdx] >> 4) == 2 {
                idxs.append(beatIdx)
            }
        }
        return idxs
    }
    
    func pvcBeatIdxs() -> Array<Int> {
        var idxs: Array<Int> = []
        for beatIdx in self.beatIdxs() {
            if (self.maskData[beatIdx] >> 4) == 3 {
                idxs.append(beatIdx)
            }
        }
        return idxs
    }

    
}
