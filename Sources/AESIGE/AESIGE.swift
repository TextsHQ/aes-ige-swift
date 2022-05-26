import Foundation
import CommonCrypto

public final class AESIGE {
    private var iv: Data
    private var key: Data

    public init(key: Data, iv: Data) throws {
        self.key = key
        self.iv = iv
    }
}

extension AESIGE {
    public func decrypt(buffer: Data) throws -> Data {
        var cryptorRef: CCCryptorRef?
        var status: CCCryptorStatus = 0

        status = CCCryptorCreate(
            CCOperation(kCCDecrypt),
            CCAlgorithm(kCCAlgorithmAES),
            CCOptions(kCCOptionECBMode),
            key.withUnsafeBytes { $0.baseAddress },
            key.count,
            iv.withUnsafeBytes { $0.baseAddress },
            &cryptorRef
        )

        defer { CCCryptorRelease(cryptorRef) }

        if status != kCCSuccess {
            throw AESIGEError.initializationError
        }

        var top = iv.subdata(in: 16..<32)
        var bottom = iv.subdata(in: 0..<16)

        var result = Data(count: buffer.count)
        var current: Data

        let dataLength: size_t = CCCryptorGetOutputLength(cryptorRef, kCCBlockSizeAES128, false)

        for i in stride(from: 0, to: buffer.count, by: 16) {
            let end = (i + 16) > buffer.count ? buffer.count : i + 16

            current = buffer.subdata(in: i..<(end))

            xor(&current, top)

            var crypted = Data(count: dataLength)

            current.withUnsafeBytes { bytes in
                var data = [UInt8](repeating: 0, count: dataLength)

                status = CCCryptorUpdate(
                    cryptorRef,
                    bytes.baseAddress,
                    current.count,
                    &data,
                    dataLength,
                    nil
                )

                crypted.replaceSubrange(0..<(dataLength), with: data)
            }

            if status != kCCSuccess {
                throw AESIGEError.decryptionError
            }

            xor(&crypted, bottom)

            result.replaceSubrange(i..<(end), with: crypted)

            top = crypted
            bottom = buffer.subdata(in: i..<(end))
        }

        return result
    }
}
