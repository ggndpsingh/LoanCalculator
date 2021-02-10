//
//  ContentView.swift
//  Shared
//
//  Created by Gagandeep Singh on 2/2/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) private var presentationMode

    @ObservedObject var loan: HomeLoan

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Group {
                                Text("Borrowing")
                                    .font(.system(size: 13, weight: .regular))
                                + Text(" \(loan.loanAmount.currencyString)")
                                    .font(.system(size: 14, weight: .bold))
                                + Text(" over")
                                    .font(.system(size: 13, weight: .regular))
                                + Text(" \(loan.duration) years")
                                    .font(.system(size: 14, weight: .bold))
                            }

                            Group {
                                Text("at")
                                    .font(.system(size: 13, weight: .regular))
                                + Text(" \(loan.repayment.description)")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        HStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total loan repayments")
                                    .font(.system(size: 13, weight: .regular))
                                Text(" \(loan.totalRepayments.currencyString)")
                                    .font(.system(size: 14, weight: .bold))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total interest charged")
                                    .font(.system(size: 13, weight: .regular))
                                Text(" \(loan.totalInterest.currencyString)")
                                    .font(.system(size: 14, weight: .bold))
                            }

                            Spacer()
                        }
                    }
                    .padding()

                    VStack(alignment: .leading) {
                        Text("Extra Repayment")
                        TextField("0.0", value: $loan.extraRepayment, formatter: NumberFormatter.currencyInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()

                    LineChart(
                        loanAmount: loan.loanAmount,
                        normalPayments: loan.normalRepaymentsTable.map{$0.closing},
                        extraPayments: loan.extraRepaymentsTable.map{$0.closing})
                        .frame(height: 200)
                        .padding()

                    AmortizationView(groups: loan.table, repayment: loan.repayment)
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
//        ContentView(loan: .init(loanAmount: 650000, duration: 30, repayment: .fixedPeriod(.init(duration: 4, fixedRate: 1.99, variableRate: 3.85))))
        ContentView(loan: .init(loanAmount: 650000, duration: 30, repayment: .standard(1.99)))
    }
}
