//
//  QRView.swift
//
//
//  Created by Daniel Nordh on 2/19/25.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

public struct QRView: View {
    @State private var viewState = CGSize.zero
    let screenBounds = UIScreen.main.bounds
    public var paymentAddress: PaymentAddress

    public init(paymentAddress: PaymentAddress) {
        self.paymentAddress = paymentAddress
    }

    public var body: some View {
        Image(uiImage: generateQRCode(from: paymentAddress.qrString))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }

    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
