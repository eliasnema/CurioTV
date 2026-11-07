import CoreImage.CIFilterBuiltins
import SwiftUI

struct QRCodeView: View {
    let url: URL

    private var image: CGImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.absoluteString.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        return CIContext().createCGImage(output.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
                                       from: output.extent.applying(CGAffineTransform(scaleX: 8, y: 8)))
    }

    var body: some View {
        Group {
            if let image {
                Image(decorative: image, scale: 1)
                    .interpolation(.none).resizable().scaledToFit()
                    .padding(22).background(.white, in: .rect(cornerRadius: 16))
            } else {
                Text(url.absoluteString).font(.caption)
            }
        }
        .frame(width: 280, height: 280)
        .accessibilityLabel("QR code for \(url.absoluteString)")
    }
}
