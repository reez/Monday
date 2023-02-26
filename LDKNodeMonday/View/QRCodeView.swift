//
//  QRCodeView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/26/23.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    var address: String

    var body: some View {
        Image(uiImage: generateQRCode(from: "bitcoin:\(address)"))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }
}

extension QRCodeView {
    func generateQRCode(from string: String) -> UIImage {
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

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(address: "tb1qz9hhk2qlsmdanrzgl38uv86hqnqe5vyszrld7s")
    }
}
