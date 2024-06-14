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
    @Bindable var viewModel: AmountViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State private var address: String = ""
    @State var numpadAmount = "0"
    @State var parseError: MondayError?
    @State var payment: Payment = .isNone
    @State private var showingAmountViewErrorAlert = false
    let pasteboard = UIPasteboard.general
    var spendableBalance: UInt64

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
                                let (extractedAddress, extractedAmount, extractedPayment) =
                                    string.extractPaymentInfo(spendableBalance: spendableBalance)
                                address = extractedAddress
                                numpadAmount = extractedAmount
                                payment = extractedPayment
                                if extractedPayment == .isNone {
                                    self.parseError = .init(
                                        title: "Scan Error",
                                        detail: "Unsupported paste format"
                                    )
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
                    .sheet(isPresented: $isShowingScanner) {
                        CodeScannerView(
                            codeTypes: [.qr],
                            simulatedData: "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
                            completion: handleScan
                        )
                    }

                    Spacer()

                    VStack {
                        Text("\(numpadAmount.formattedAmountZero()) sats")
                            .textStyle(BitcoinTitle1())
                        Text(address)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .fontWeight(.semibold)
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                            switch payment {
                            case .isLightning:

                                if address.bolt11amount() == "0" {
                                    if let amountSats = UInt64(numpadAmount) {
                                        let amountMsat = amountSats * 1000
                                        await viewModel.sendPaymentUsingAmount(
                                            invoice: address,
                                            amountMsat: amountMsat
                                        )

                                    } else {
                                        viewModel.amountConfirmationViewError = .init(
                                            title: "Unexpected error",
                                            detail: "Invalid amount entered"
                                        )
                                    }
                                } else {
                                    await viewModel.sendPayment(invoice: address)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    self.presentationMode.wrappedValue.dismiss()
                                }

                            case .isBitcoin:

                                if numpadAmount == "0" {
                                    viewModel.amountConfirmationViewError = .init(
                                        title: "Unexpected error",
                                        detail: "Invalid amount entered"
                                    )
                                } else if let amount = UInt64(numpadAmount) {
                                    await viewModel.sendToOnchain(
                                        address: address,
                                        amountMsat: amount
                                    )
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                } else {
                                    viewModel.amountConfirmationViewError = .init(
                                        title: "Unexpected error",
                                        detail: "Unknown error occured"
                                    )
                                }
                            case .isLightningURL:
                                viewModel.amountConfirmationViewError = .init(
                                    title: "LNURL Error",
                                    detail: "LNURL not supported yet"
                                )
                            case .isNone:
                                print("not sure")
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
                    .tint(viewModel.networkColor)
                    .frame(width: 300, height: 25)
                    .padding()
                    .padding(.bottom, 20.0)

                }
                .padding()
                .onAppear {
                    viewModel.getColor()
                }
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
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let scanResult):
            let scanString = scanResult.string
            let (extractedAddress, extractedAmount, extractedPayment) =
                scanString.extractPaymentInfo(spendableBalance: spendableBalance)
            address = extractedAddress
            numpadAmount = extractedAmount
            payment = extractedPayment

            if extractedPayment == .isNone {
                self.parseError = .init(title: "Scan Error", detail: "Unsupported scan format")
            }

        case .failure(let scanError):
            self.parseError = .init(title: "Scan Error", detail: scanError.localizedDescription)
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
            Text(character).textStyle(BitcoinTitle3())
        }
    }
}

#Preview {
    AmountView(viewModel: .init(), spendableBalance: UInt64(21000))
}
