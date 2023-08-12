//
//  Guages.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-11.
//

import Foundation
import SwiftUI

struct HRGuageView: View {
    var value: Double
    let minValue: Double
    let maxValue: Double
    let bottomBlack = Double(0.15)
    
    var body: some View {
        ZStack {
            
            Circle()
                .trim(from: bottomBlack, to: CGFloat(1))
                .stroke(Color.primary, lineWidth: 20)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(90 - bottomBlack * 180))
            
            Circle()
                .trim(from: bottomBlack * 1.05, to: CGFloat((value - minValue) / (maxValue - minValue)))
                .stroke(Color.red, lineWidth: 18)
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(90 - bottomBlack * 1.05 * 180))
            
            
            VStack {
                Text("\(Int(value))")
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
                Text("BPM")
                    .font(.subheadline)
            }
            
            
        }
        .padding()
        
    }
}

struct BeatGuageView: View {
    var normBeats: Double
    var pacBeats: Double
    var pvcBeats: Double
    let title: String
    
    var body: some View {
        
        let totalBeats = normBeats + pacBeats + pvcBeats
        
        let normEnd = normBeats / totalBeats
        
        let pacEnd = pacBeats / totalBeats + normEnd
        
        VStack {
            
            ZStack {
                
                Circle()
                    .trim(from: 0, to: CGFloat(1))
                    .stroke(Color.primary, lineWidth: 35)
                    .frame(width: 160, height: 160)
                
                
                if (totalBeats != 0) {
                    // NORM BEATS
                    Circle()
                        .trim(from: 0, to: normEnd)
                        .stroke(Color.blue, lineWidth: 32)
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(90))
                    
                    // PAC BEATS
                    Circle()
                        .trim(from: normEnd, to: pacEnd)
                        .stroke(Color.purple, lineWidth: 32)
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(90))
                    
                    // PVC BEATS
                    Circle()
                        .trim(from: pacEnd, to: 1)
                        .stroke(Color.red, lineWidth: 32)
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(90))
                }
                
                
                VStack {
                    Text("\(Int(totalBeats))")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.subheadline)
                }
                
                
            }
            .padding(.top)
            .padding(.bottom, 30)
            
            
            HStack {
                VStack(alignment: .center) {
                    Text("\(Int(normBeats))")
                        .font(.title)
                        .bold()
                        .lineLimit(1)
                    Text("""
                        N
                        S
                        R
                        """)
                        .font(.caption)
                        .bold()
                }
                .padding(8)
                .background(Color.blue)
                .cornerRadius(10)
                
                VStack(alignment: .center) {
                    Text("\(Int(pacBeats))")
                        .font(.title)
                        .bold()
                    Text("""
                        P
                        A
                        C
                        """)                        
                        .font(.caption)
                        .bold()
                }
                .padding(8)
                .background(Color.purple)
                .cornerRadius(10)
                
                VStack(alignment: .center) {
                    Text("\(Int(pvcBeats))")
                        .font(.title)
                        .bold()
                    Text("""
                        P
                        V
                        C
                        """)                          
                        .font(.caption)
                        .bold()
                }
                .padding(8)
                .background(Color.red)
                .cornerRadius(10)
            }
            
            
            
        }
        
    }
}
