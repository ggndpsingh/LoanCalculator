//
//  HomeLoanForm.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 8/2/21.
//

import SwiftUI

struct HomeLoanForm: View {

    @State private var loanValue: Double? = 650000
    @State private var duration: Int? = 30
    @State var repayment: Repayment? = .fixedPeriod(.init(duration: 5, fixedRate: 2.99, variableRate: 3.85))

    @State private var repaymentType = 1
    @State var presentingLoan: Bool = false

    private var canCalculate: Bool {
        guard
            let loan = loanValue,
            let duration = duration,
            let repayment = self.repayment
        else { return false }
        return loan > 0 && duration > 0 && repayment.isValid
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Loan Details".uppercased())
                    .font(Font.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                VStack(alignment: .leading) {
                    Text("I would like to borrow")
                        .font(Font.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.primary)

                    TextField("100,000", value: $loanValue, formatter: NumberFormatter.currencyInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                }
                .padding(.top, 4)

                VStack(alignment: .leading) {
                    Text("Over")
                        .font(Font.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.primary)

                    HStack {
                        TextField("10", value: $duration, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(Font.system(size: 20, weight: .light, design: .rounded))
                            .frame(width: 40, alignment: .center)
                            .multilineTextAlignment(.center)
                        Text("years")
                            .font(Font.system(size: 20, weight: .light, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)

                Text("Repayment Type".uppercased())
                    .font(Font.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.top, 32)

                Picker(selection: $repaymentType, label: Text("Loan Type")) {
                    Text("Standard Variable").tag(0)
                    Text("Fixed Period").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top)

                if repaymentType == 0 {
                    StandardInterestView(repayment: $repayment)
                } else {
                    FixedPeriodInterestView(repayment: $repayment)
                }

                Spacer()

                Button(action: {
                    presentingLoan = true
                }) {
                    Text("Calculate")
                }
                .disabled(!canCalculate)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(canCalculate ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 32)
            }
            .navigationTitle("Home Loan")
            .padding(.horizontal)
            .padding(.top)
        }
        .fullScreenCover(isPresented: $presentingLoan) {
            let loan = HomeLoan(loanAmount: loanValue!, duration: duration!, repayment: repayment!)
            ContentView(loan: loan)
        }
        .keyboardType(.decimalPad)
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

struct StandardInterestView: View {
    @Binding var repayment: Repayment?
    @State private var interestRate: Double? = 1.99

    var body: some View {
        VStack(alignment: .leading) {
            Text("Interest Rate")
                .font(Font.system(size: 16, weight: .light, design: .rounded))
                .foregroundColor(.primary)

            HStack {
                TextField("2.00", value: $interestRate, formatter: NumberFormatter.decimal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Font.system(size: 20, weight: .light, design: .rounded))
                    .frame(width: 80, alignment: .center)
                    .multilineTextAlignment(.center)
                Text("%")
                    .font(Font.system(size: 20, weight: .light, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: interestRate) { value in
            guard let rate = value else {
                repayment = nil
                return
            }

            repayment = .standard(rate)
        }
        .padding(.top)
    }
}

struct FixedPeriodInterestView: View {
    @Binding var repayment: Repayment?
    @State private var fixedRate: Double? = 2.99 {
        didSet { makeRepayment() }
    }
    @State private var fixedPeriod: Int? = 5 {
        didSet { makeRepayment() }
    }
    @State private var variableRate: Double? = 3.85 {
        didSet { makeRepayment() }
    }

    private func makeRepayment() {
        guard let rate = fixedRate, let period = fixedPeriod, let vRate = variableRate else { return }
        repayment = .fixedPeriod(.init(duration: period, fixedRate: rate, variableRate: vRate))
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Fixed Period")
                    .font(Font.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.primary)

                HStack {
                    TextField("10", value: $fixedPeriod, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                        .frame(width: 40, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text("years")
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)

            VStack(alignment: .leading) {
                Text("Fixed Interest Rate")
                    .font(Font.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.primary)

                HStack {
                    TextField("2.00", value: $fixedRate, formatter: NumberFormatter.decimal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                        .frame(width: 80, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text("%")
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)

            VStack(alignment: .leading) {
                Text("Standard Interest Rate")
                    .font(Font.system(size: 16, weight: .light, design: .rounded))
                    .foregroundColor(.primary)

                HStack {
                    TextField("2.00", value: $variableRate, formatter: NumberFormatter.decimal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                        .frame(width: 80, alignment: .center)
                        .multilineTextAlignment(.center)
                    Text("%")
                        .font(Font.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
        }
        .onChange(of: fixedPeriod) { _ in
            makeRepayment()
        }
        .onChange(of: fixedRate) { _ in
            makeRepayment()
        }
        .onChange(of: variableRate) { _ in
            makeRepayment()
        }
        .padding(.top)
    }
}
