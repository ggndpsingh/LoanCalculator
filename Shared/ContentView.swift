//
//  ContentView.swift
//  Shared
//
//  Created by Gagandeep Singh on 2/2/21.
//

import SwiftUI

struct ContentView: View {

    @State private var loanAmount: String = "650000"
    @State private var interestRate: String = "1.99"
    @State private var duration: String = "120"

    var loan: HomeLoan {
        .init(loanAmount: 650000, term: .months(360), interest: .mix((48, 1.99), 3.85))
//        .init(loanAmount: 650000, term: .months(360), interest: .fixed(1.99))
    }

    private var loanA: Double {
        let formatter = NumberFormatter()
        let loan = formatter.number(from: loanAmount)?.doubleValue ?? 0
        print(loan)
        return loan
    }

    private var interest: Double {
        let formatter = NumberFormatter()
        return formatter.number(from: interestRate)?.doubleValue ?? 0
    }

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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Loan Amount")
                        TextField("100,000", text: $loanAmount)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interest Rate")
                        TextField("1.99", text: $interestRate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration (Months)")
                        TextField("120", text: $duration)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    Text("\(loan.loanAmount.currencyString) for \(loan.term.description)")

                    HStack {
                        Text("Total Payable")
                        Text(loan.totalLoan.currencyString)
                    }

                    HStack {
                        Text("Total Interest")
                        Text(loan.totalInterest.currencyString)
                    }

                    HStack {
                        Text(loan.repaymentType.description)
                    }

                    let data = loan.table.map { DataPoint(value: $0.balance) }

                    LineChart(term: loan.term, dataPoints: data)
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

                            if (row.id > 0 && row.id < loan.term.value && row.id.isMultiple(of: 12)) {
                                let remaining = Int((loan.term.value - row.id) / 12)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Double {
    var currencyString: String {
        let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currencyAccounting
            return formatter
        }()

        return formatter.string(from: NSNumber(value: self)) ?? ""
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
    let dataPoints: [DataPoint]
    let pointSize: CGFloat
    let maxValue: Double

    init(dataPoints: [DataPoint], pointSize: CGFloat) {
        self.dataPoints = dataPoints
        self.pointSize = pointSize

        let highestPoint = dataPoints.max { $0.value < $1.value }
        maxValue = highestPoint?.value ?? 1
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let drawRect = rect.insetBy(dx: pointSize, dy: pointSize)

        let xMultiplier = drawRect.width / CGFloat(dataPoints.count - 1)
        let yMultiplier = drawRect.height / CGFloat(maxValue)

        for (index, dataPoint) in dataPoints.enumerated() {
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
    let term: Term
    let dataPoints: [DataPoint]
    let lineColor: Color
    let lineWidth: CGFloat
    let pointSize: CGFloat

    let maxValue: Int

    init(term: Term, dataPoints: [DataPoint], lineColor: Color = Color.blue, lineWidth: CGFloat = 4, pointSize: CGFloat = 5) {
        self.term = term
        self.dataPoints = dataPoints
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.pointSize = pointSize

        maxValue = Int(dataPoints.max { $0.value < $1.value }?.value ?? 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach((1...5).reversed(), id: \.self) { i in
                        let val = maxValue / 5 * i
                        Text(String(val))
                        Spacer()
                    }
                    Text("")
                }
                .font(.caption)
                .padding([.trailing])

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

                        HStack {
                            let count = term.value / 12 / 5
                            ForEach(0...count, id: \.self) { i in
                                Text(String(i * 5))
                                    .font(.caption)
                                if i < count {
                                    Spacer()
                                }
                            }
                        }
                        .padding(.top)
                    }

                    if lineColor != .clear {
                        LineChartShape(dataPoints: dataPoints, pointSize: pointSize)
                            .stroke(lineColor, lineWidth: lineWidth)
                            .padding(.bottom, 36)
                    }
                }
            }
        }
    }
}
