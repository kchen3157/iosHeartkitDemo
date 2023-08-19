//
//  Guages.swift
//  heartkitDemo
//
//  Created by Kyle Chen on 2023-08-11.
//

import Foundation
import SwiftUI
import Charts


struct HRGuageView: View {
    
    var value: Double
    let minValue: Double
    let maxValue: Double
    let color: Color
    
    var body: some View {
        VStack {
                Gauge(value: value, in: minValue...maxValue) {
                } currentValueLabel: {
                    Text("\(Int(value))")
                        .foregroundStyle(.foreground)
                        .font(.largeTitle)
                        .bold()
                } minimumValueLabel: {
                    Text("\(Int(minValue))")
                        .foregroundStyle(.foreground)
                        .bold()
                } maximumValueLabel: {
                    Text("\(Int(maxValue))")
                        .foregroundStyle(.foreground)
                        .bold()
                }
                .gaugeStyle(AccessoryLinearGaugeStyle())
                .tint(Gradient(stops: [Gradient.Stop(color: .red, location: 0),
                                       Gradient.Stop(color: .orange, location: 0.1),
                                       Gradient.Stop(color: .yellow, location: 0.2),
                                       Gradient.Stop(color: .green, location: 0.3),
                                       Gradient.Stop(color: .green, location: 0.7),
                                       Gradient.Stop(color: .yellow, location: 0.8),
                                       Gradient.Stop(color: .orange, location: 0.9),
                                       Gradient.Stop(color: .red, location: 1)]))
            Text("\(Int(value))")
                .foregroundStyle(.foreground)
                .font(.largeTitle)
                .bold()
            
            Text("HR (BPM)")
                .font(.footnote)
        }
        
    }
}


struct BeatGuageView: View {
    
    var data: [(name: String, number: Double)]
    var total: (name: String, number: Double)
    
    let cumulativeSalesRangesForStyles: [(name: String, range: Range<Double>)]
    
    @State var selectedSales: Double? = nil
    
    init(numNormBeats: Double, numPacBeats: Double, numPvcBeats: Double) {
        self.data = [
            (name: "NSR", number: numNormBeats),
            (name: "PAC", number: numPacBeats),
            (name: "PVC", number: numPvcBeats),
        ]
        self.total = (name: "TOTAL", number: (numNormBeats + numPacBeats + numPvcBeats))
        
        var cumulative = 0.0
        self.cumulativeSalesRangesForStyles = data.map {
            let newCumulative = cumulative + Double($0.number)
            let result = (name: $0.name, range: cumulative ..< newCumulative)
            cumulative = newCumulative
            return result
        }
    }
    
    var selectedStyle: (name: String, number: Double)? {
        if let selectedSales,
           let selectedIndex = cumulativeSalesRangesForStyles
            .firstIndex(where: { $0.range.contains(selectedSales) }) {
            return data[selectedIndex]
        }
        return nil
    }
    
    var body: some View {
        Chart(data, id: \.name) { element in
            SectorMark(
                angle: .value("Number", element.number),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .cornerRadius(5.0)
            .foregroundStyle(by: .value("Name", element.name))
            .opacity(element.name == selectedStyle?.name || selectedStyle?.name == nil ? 1 : 0.3)
        }
        .chartLegend(alignment: .center, spacing: 18)
        .chartAngleSelection(value: $selectedSales)
        .scaledToFit()
        
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                VStack {
                    Text(selectedStyle?.number.formatted() ?? total.number.formatted())
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    Text(selectedStyle?.name ?? total.name)
                        .font(.callout)
                        .foregroundStyle(.primary)
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
    }
}

