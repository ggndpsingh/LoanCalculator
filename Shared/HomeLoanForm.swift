//
//  HomeLoanForm.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 8/2/21.
//

import SwiftUI

struct HomeLoanForm: View {

    @State private var loanAmount: String = ""
    @State private var interestRate: String = ""
    @State private var duration: String = ""
    @State private var loanType = 0

    @State var presentingLoan: Bool = false

    private var loanValue: Double? {
        let formatter = NumberFormatter()
        return formatter.number(from: loanAmount)?.doubleValue
    }

    private var interestValue: Double? {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.number(from: interestRate)?.doubleValue
    }

    private var durationValue: Int? {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        return formatter.number(from: duration)?.intValue
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Loan Details")) {
                    HStack {
                        Text("Amount")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 60)
                        Divider()
                        Text("$")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("100,000", text: $loanAmount)
                    }

                    HStack {
                        Text("Duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 60)
                        Divider()
                        TextField("10", text: $duration)
                        Text("years")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Loan Type")) {
                    Picker(selection: $loanType, label: Text("Loan Type")) {
                        Text("Standard").tag(0)
                        Text("Partial Fixed").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())

                    HStack {
                        Text("Interest Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 80)
                        Divider()
                        TextField("2.00", text: $interestRate)
                        Text("%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section() {
                    Button(action: {
                        presentingLoan = true
                    }) {
                        Text("Calculate")
                    }
                    .disabled(loanValue.isNil || durationValue.isNil || interestValue.isNil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .fullScreenCover(isPresented: $presentingLoan) {
                let loan = HomeLoan(loanAmount: loanValue!, term: .fixed(.init(duration: durationValue!, rate: interestValue!)))
                ContentView(loan: loan)
            }
            .keyboardType(.decimalPad)
            .navigationTitle("Home Loan")
        }
    }
}

struct HomeLoanForm_Previews: PreviewProvider {
    static var previews: some View {
        HomeLoanForm()
    }
}

extension Optional {
    var isNil: Bool {
        self == nil
    }
}
