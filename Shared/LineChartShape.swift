//
//  LineChartShape.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 9/2/21.
//

import SwiftUI

struct LineChartShape: Shape {
    let drawDataPoints: [DataPoint]
    let sizeDataPoints: [DataPoint]
    let maxValue: Double
    let pointSize: CGFloat = 0

    init(drawDataPoints: [DataPoint], sizeDataPoints: [DataPoint]) {
        self.drawDataPoints = drawDataPoints
        self.sizeDataPoints = sizeDataPoints

        let highestPoint = sizeDataPoints.max { $0.value < $1.value }
        maxValue = highestPoint?.value ?? 1
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let drawRect = rect.insetBy(dx: pointSize, dy: pointSize)

        let xMultiplier = drawRect.width / CGFloat(sizeDataPoints.count - 1)
        let yMultiplier = drawRect.height / CGFloat(maxValue)

        for (index, dataPoint) in drawDataPoints.enumerated() {
            var x = xMultiplier * CGFloat(index)
            var y = yMultiplier * CGFloat(dataPoint.value)
            y = drawRect.height - y

            x += drawRect.minX
            y += drawRect.minY

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

struct LineChartShape_Previews: PreviewProvider {
    static var previews: some View {
        LineChartShape(drawDataPoints: [], sizeDataPoints: [])
    }
}
