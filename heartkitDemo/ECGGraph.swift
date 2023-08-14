//
//  ECGGraph.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-14.
//

import Foundation
import SwiftUI
import Charts

struct ECGGraph: View {
    var data: Array<Float>
    var ecgColor: Color
    var normColor: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            Chart(0..<data.count, id: \.self) { nr in
                LineMark(
                    x: .value("X values", nr),
                    y: .value("Y values", data[nr])
                )
                .lineStyle(.init(lineWidth: 1))
                .foregroundStyle(ecgColor)
                
            }
            .frame(width: 380, height: 200)
            //                .chartYScale(domain: -6...6)
            .chartXScale(domain: 0...2500)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 0))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 0))
            }
            
            // Beat Labels
            //                GeometryReader { geometry in
            //                    ZStack{
            //                        Path { path in
            //                            for x in bluetoothManager.segMask.beatIdxs() {
            //                                let normalizedX = CGFloat(x) * geometry.size.width / CGFloat(SAMPLE_SIZE)
            //                                path.move(to: CGPoint(x: normalizedX, y: 0))
            //                                path.addLine(to: CGPoint(x: normalizedX, y: geometry.size.height - 20))
            //                            }
            //                        }
            //                        .stroke(normColor, lineWidth: 1)
            //
            //                        ForEach(bluetoothManager.segMask.normalBeatIdxs().indices, id: \.self) { x in
            //                            let normalizedX = CGFloat(bluetoothManager.segMask.normalBeatIdxs()[x]) * geometry.size.width / CGFloat(SAMPLE_SIZE)
            //                            Text("""
            //                                                        N
            //                                                        S
            //                                                        R
            //                                                        """)
            //                            .font(.caption)
            //                            .foregroundStyle(normColor)
            //                            .bold()
            //                            .position(x: normalizedX, y: geometry.size.height - 20)
            //                        }
            //                    }
            //
            //                }
            //                .frame(width: 380, height: 220)
            //
            //            }
            //            .frame(width: 380, height: 240)
        }
    }
    
}

