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

    private var term: Term {
        return .months(Int(duration) ?? 0)
    }

    fileprivate func cellText(_ text: String, width: CGFloat) -> some View {
        return Text(text)
            .font(.subheadline)
            .frame(width: width, alignment: .center)
    }

    var body: some View {
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
                Text("Monthly Repayment")
//                Text(loan.monthlyRepayment.currencyString)
            }

            HStack {
                Text("Total Payable")
                Text(loan.totalLoan.currencyString)
            }

            GeometryReader { geo in
                ScrollView {
                    VStack {
                        Divider()
                        
                        HStack(spacing: 0) {
                            cellText("#", width: 24)
                            cellText("Interest", width: geo.size.width/3 - 12)
                            cellText("Payment", width: geo.size.width/3 - 12)
                            cellText("Balance", width: geo.size.width/3 - 12)
                        }

                        Divider()

                        ForEach(loan.table) { row in
                            HStack(spacing: 0) {
                                cellText(String(row.id), width: 36)
                                cellText(row.interest.currencyString, width: geo.size.width/3 - 12)
                                cellText(row.repayment.currencyString, width: geo.size.width/3 - 12)
                                cellText(row.balance.currencyString, width: geo.size.width/3 - 12)
                            }
                            Divider()
                        }
                    }
                    .background(Color.yellow)
                    .frame(width: geo.size.width)
                }
            }
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
