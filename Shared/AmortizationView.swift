//
//  AmortizationView.swift
//  LoanCalculator
//
//  Created by Gagandeep Singh on 9/2/21.
//

import SwiftUI

struct AmortizationView: View {
    let groups: [TableGroup]
    let repayment: InterestType

    @State private var expandedGroups: Set<Int> = []

    private func isGroupExpanded(at groupIndex: Int) -> Bool {
        expandedGroups.contains(groupIndex)
    }

    private func toggleGroup(at index: Int) {
        if isGroupExpanded(at: index) {
            expandedGroups.remove(index)
            return
        }

        expandedGroups.insert(index)
    }

    func standardInterestHeader(payment: Double) -> some View {
        Text("Interest rate \(repayment.standardInterestRate.percentageString) with monthly repayments of \(payment.currencyString)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(4)
            .background(Color.black)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .regular))
    }

    func fixedInterestHeader(interestRate: Double, payment: Double) -> some View {
        Text("Interest rate \(interestRate.percentageString) with monthly repayments of \(payment.currencyString)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(4)
            .background(Color.black)
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .regular))
    }

    var body: some View {
        VStack(spacing: 0) {
            if !groups.isEmpty {
                tableHeader()

                if let rate = repayment.fixedInterestRate {
                    fixedInterestHeader(interestRate: rate, payment: groups.first!.rows.first!.repayment)
                }

                ForEach(groups) { group in
                    let index = group.id
                    groupRow(for: group, at: index)

                    if isGroupExpanded(at: index) {
                        rowsView(with: group.rows)
                    }

//                    if let period = repayment.fixedPeriod, index == period - 1 {
//                        standardInterestHeader(payment: groups[period].rows.first!.repayment)
//                    }
                }
            }
        }
    }

    fileprivate func tableHeader() -> some View {
        return Self.makeRow(values: ("Year", "Interest", "Repayments", "Balance"), font: .system(size: 14, weight: .medium))
                .padding(.horizontal, 4)
                .background(Color.gray.opacity(0.3))
    }

    func groupRow(for group: TableGroup, at index: Int) -> some View {
        Self.makeRow(
            values: (
                String(index + 1),
                group.interest.currencyString,
                group.repayment.currencyString,
                group.closing.currencyString
            ),
            font: .caption,
            chevronAngle: isGroupExpanded(at: index) ? 90 : 0)
            .onTapGesture {
                toggleGroup(at: index)
            }
            .background(group.id.isMultiple(of: 2) ? Color.white : Color.gray.opacity(0.1))
            .animation(.easeInOut)
    }

    fileprivate func rowsView(with rows: [TableRow]) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<rows.count) { index in
                let row = rows[index]
                Self.makeRow(
                    values: (
                        String(index + 1),
                        row.interest.currencyString,
                        row.repayment.currencyString,
                        row.closing.currencyString
                    ),
                    font: .system(size: 13, weight: .regular))
                    .background(index.isMultiple(of: 2) ? Color.blue.opacity(0.1) : Color.blue.opacity(0.2))
            }
        }
        .padding(.bottom)
    }

    private static func makeRow(values: (String, String, String, String), font: Font, chevronAngle: Double? = nil) -> some View {
        func makeCell(_ text: String) -> some View {
            return Text(text)
                .font(font)
                .frame(minWidth: 0, maxWidth: .infinity)
        }

        return HStack(spacing: 0) {
            makeCell(values.0).frame(width: 44)
            Spacer()
            makeCell(values.1)
            Spacer()
            makeCell(values.2)
            Spacer()
            makeCell(values.3)
            Spacer()
            if let angle = chevronAngle {
                Image(systemName: "chevron.forward")
                    .frame(width: 32)
                    .font(.caption)
                    .rotationEffect(.init(degrees: angle))
            } else {
                makeCell("").frame(width: 32)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 4)
    }

}

struct TableGroup: Identifiable {
    let id: Int
    let opening: Double
    let interest: Double
    let repayment: Double
    let closing: Double
    let rows: [TableRow]

    init(id: Int, opening: Double, closing: Double, interest: Double, repayment: Double, rows: [TableRow]) {
        self.id = id
        self.opening = opening
        self.interest = interest
        self.repayment = repayment
        self.closing = closing
        self.rows = rows
    }
}

struct TableRow: Identifiable {
    let id: Int
    let opening: Double
    let interest: Double
    let repayment: Double
    let closing: Double
}


struct AmortizationView_Previews: PreviewProvider {
    static var previews: some View {
        let loan = HomeLoan(loanAmount: 650000, duration: 30, repayment: .fixedPeriod(.init(duration: 4, fixedRate: 1.99, variableRate: 3.85)))
//            let loan = HomeLoan(loanAmount: 650000, duration: 30, repayment: .standard(1.99))
        
        ScrollView {
            return AmortizationView(groups: loan.table, repayment: loan.interestType)
        }
    }
}
