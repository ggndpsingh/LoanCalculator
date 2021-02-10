//
//  LineChart.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 9/2/21.
//

import SwiftUI

struct DataPoint {
    let value: Double
}

struct LineChart: View {
    let loanAmount: Double
    let normalPayments: [Double]
    let extraPayments: [Double]

    private var dataPoints: [DataPoint] {
        [DataPoint(value: loanAmount)] + normalPayments.map { DataPoint(value: $0) }
    }

    private var extraDataPoints: [DataPoint] {
        [DataPoint(value: loanAmount)] +  extraPayments.map { DataPoint(value: $0) }
    }

    private var maxValue: Int { Int(dataPoints.max { $0.value < $1.value }?.value ?? 1) }

    var body: some View {
        VStack(alignment: .leading) {
            Text(String(dataPoints[0].value.currencyString))
                .font(.system(size: 12, weight: .regular))

            HStack(spacing: 0) {
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { _ in
                            Divider()
                            Spacer()
                        }

                        Rectangle()
                            .fill(Color.primary)
                            .frame(height: 1 / UIScreen.main.scale)
                            .opacity(0.4)
                    }

                    LineChartShape(drawDataPoints: dataPoints, sizeDataPoints: dataPoints)
                        .stroke(extraPayments.isEmpty ? Color.yellow : Color.gray, lineWidth: 2)

                    if !extraPayments.isEmpty {
                        LineChartShape(drawDataPoints: extraDataPoints, sizeDataPoints: dataPoints)
                            .stroke(Color.yellow, lineWidth: 2)
                    }
                }
            }

            HStack {
                Text("Today")
                    .font(.system(size: 12, weight: .regular))
                Spacer()
                Text("\((dataPoints.count - 1)) Years")
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}


struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        let loan = HomeLoan(loanAmount: 650000, duration: 30, repayment: .standard(1.99))
        LineChart(loanAmount: loan.loanAmount, normalPayments: loan.normalRepaymentsTable.map{$0.closing}, extraPayments: loan.extraRepaymentsTable.map{$0.closing})
    }
}
