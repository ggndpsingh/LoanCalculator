//
//  ContentView.swift
//  Shared
//
//  Created by Gagandeep Singh on 2/2/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) private var presentationMode

    let loan: HomeLoan

    fileprivate func cellText(_ text: String) -> some View {
        return Text(text)
            .font(.caption)
            .padding(.horizontal, 4)
            .frame(minWidth: 0, maxWidth: .infinity)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("\(loan.loanAmount) \(loan.duration) \(loan.repayment.description)")
                    Text("\(loan.totalLoan) \(loan.totalInterest)")
                    LineChart(loan: loan)
                        .frame(height: 200)
                        .padding()

                    VStack(spacing: 0) {
                        Divider()
                        
                        HStack(spacing: 0) {
                            cellText("#").frame(width: 44)
                            Spacer()
                            cellText("Interest")
                            Spacer()
                            cellText("Payment")
                            Spacer()
                            cellText("Balance")
                        }
                        .padding(.vertical)
                        .background(Color.gray.opacity(0.3))

                        Divider()

                        ForEach(loan.table) { row in
                            HStack(spacing: 0) {
                                cellText(String(row.id)).frame(width: 44)
                                Spacer()
                                cellText(row.interest.currencyString)
                                Spacer()
                                cellText(row.repayment.currencyString)
                                Spacer()
                                cellText(row.balance.currencyString)
                            }
                            .padding(.vertical)
                            .background(row.id.isMultiple(of: 2) ? Color.white : Color.gray.opacity(0.1))

                            if (row.id > 0 && row.id < loan.totalDuration && row.id.isMultiple(of: 12)) {
                                let remaining = Int((loan.totalDuration - row.id) / 12)
                                Text("\(remaining) years remaining: \(row.balance.currencyString)")
                                    .font(.caption)
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.yellow)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Loan Details")
            .navigationBarItems(trailing:
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loan: .init(loanAmount: 650000, duration: 30, repayment: .fixedPeriod(.init(duration: 4, fixedRate: 1.99, variableRate: 3.85))))
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        return formatter
    }()

    static var currencyInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""
        return formatter
    }()

    static var decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Double {
    var currencyString: String {

        return NumberFormatter.currency.string(from: NSNumber(value: self)) ?? ""
    }

    var percentageString: String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.minimumFractionDigits = 2
            return formatter
        }()


        return formatter.string(from: NSNumber(value: self / 100)) ?? ""
    }
}

struct DataPoint {
    let value: Double
}

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

struct LineChart: View {
    let loan: HomeLoan

    private var dataPoints: [DataPoint] { loan.table.map { DataPoint(value: $0.balance) } }
    private var extraDataPoints: [DataPoint] { loan.extraTable.map { DataPoint(value: $0.balance) } }
    private var maxValue: Int { Int(dataPoints.max { $0.value < $1.value }?.value ?? 1) }

    var body: some View {
        VStack(alignment: .leading) {
            Text(String(dataPoints[0].value.currencyString))
                .font(.caption)

            HStack(spacing: 0) {
                ZStack {
                    if let fixedPeriod = loan.repayment.fixedPeriod {
                        GeometryReader { geo in
                            let width = (geo.size.width / CGFloat(dataPoints.count) * CGFloat(fixedPeriod))
                            Rectangle()
                                .fill(Color.yellow.opacity(0.4))
                                .frame(maxWidth: width, maxHeight: .infinity)
                            }
                    }
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
                        .stroke(Color.gray, lineWidth: 2)

                    LineChartShape(drawDataPoints: extraDataPoints, sizeDataPoints: dataPoints)
                        .stroke(Color.yellow, lineWidth: 2)
                }
            }

            HStack {
                Text("Today").font(.caption)
                Spacer()
                Text("\((dataPoints.count - 1)/12) Years").font(.caption)
            }
        }
    }
}
