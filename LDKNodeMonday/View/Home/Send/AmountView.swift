//
//  AmountView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/24/24.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct AmountView: View {
    @ObservedObject var viewModel: SendViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State var address = ""
    @State var numpadAmount = "0"
    @State var parseError: MondayError?
    @State var payment: PaymentType = .none
    @State private var showingAmountViewErrorAlert = false
    let pasteboard = UIPasteboard.general
    //var spendableBalance: UInt64
    @Binding var sendViewState: SendViewState

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: .systemBackground)

                VStack(spacing: 20) {

                    HStack {

                        Button {
                            isShowingScanner = true
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                                .minimumScaleFactor(0.5)
                        }

                        Spacer()

                        Button {
                            if pasteboard.hasStrings, let string = pasteboard.string {
                                if address.starts(with: "lno") {
                                    address = address
                                    numpadAmount = "0"
                                    payment = .lightning
                                } else {
                                    //                                    let (extractedAddress, extractedAmount, extractedPayment) =
                                    //                                        string.extractPaymentInfo(
                                    //                                            spendableBalance: spendableBalance
                                    //                                        )
                                    //                                    address = extractedAddress
                                    //                                    viewModel.numpadAmount = extractedAmount
                                    //                                    payment = extractedPayment
                                    //                                    if extractedPayment == .none {
                                    //                                        self.parseError = .init(
                                    //                                            title: "Scan Error",
                                    //                                            detail: "Unsupported paste format"
                                    //                                        )
                                    //                                    }
                                }
                            } else {
                                self.parseError = .init(
                                    title: "Pasteboard Error",
                                    detail: "No address found in pasteboard"
                                )
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .minimumScaleFactor(0.5)
                            }
                        }

                    }
                    .padding(.top, 40.0)
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.label))

                    Spacer()

                    VStack {

                        // Need to figure out how to decode or add amount
                        if address.starts(with: "lno") {
                            // TODO: grab amount
                            Text("BOLT12 Offer")
                                .textStyle(BitcoinTitle1())
                            Text(address)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .fontWeight(.semibold)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(numpadAmount.formattedAmount(defaultValue: "0")) sats")
                                .textStyle(BitcoinTitle1())
                            Text(address)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .fontWeight(.semibold)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                    }
                    .padding()

                    GeometryReader { geometry in
                        let buttonSize = geometry.size.width / 4
                        VStack(spacing: buttonSize / 10) {
                            numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                            numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                            numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                            numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 300)

                    Spacer()

                    Button {
                        Task {
                            try await viewModel.send(uriStr: address)
                        }
                        if viewModel.amountConfirmationViewError == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                //navigationPath.removeLast(navigationPath.count)
                            }
                        }
                    } label: {
                        Text("Send")
                            .bold()
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                            .frame(maxWidth: .infinity)
                            .padding(.all, 8)
                    }
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.borderedProminent)
                    .frame(width: 300, height: 25)
                    .padding()
                    .padding(.bottom, 20.0)

                }
                .padding()
                .alert(isPresented: $showingAmountViewErrorAlert) {
                    Alert(
                        title: Text(viewModel.amountConfirmationViewError?.title ?? "Unknown"),
                        message: Text(viewModel.amountConfirmationViewError?.detail ?? ""),
                        dismissButton: .default(Text("OK")) {
                            viewModel.amountConfirmationViewError = nil
                        }
                    )
                }

            }

        }

    }

}

extension AmountView {
    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize / 1.5)
            }
        }
    }
}

struct NumpadButton: View {
    @Binding var numpadAmount: String
    var character: String

    var body: some View {
        Button {
            if character == "<" {
                if numpadAmount.count > 1 {
                    numpadAmount.removeLast()
                } else {
                    numpadAmount = "0"
                }
            } else if character == " " {
                return
            } else {
                if numpadAmount == "0" {
                    numpadAmount = character
                } else {
                    numpadAmount.append(character)
                }
            }
        } label: {
            if character == "<" {
                Image(systemName: "delete.left")
                    .bold()
                    .foregroundColor(.primary)
            } else {
                Text(character)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
}

#if DEBUG
    #Preview {
        AmountView(
            viewModel: .init(lightningClient: .mock, sendViewState: .manual),
            sendViewState: .constant(.manual)
        )
    }
#endif
