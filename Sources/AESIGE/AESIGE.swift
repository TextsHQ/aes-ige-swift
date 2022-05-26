import Foundation
import CommonCrypto

public final class AESIGE {
    private var iv: Data
    private var key: Data

    public init(key: Data, iv: Data) throws {
        self.key = key
        self.iv = iv
    }

    private enum Operation {
        case decrypt
        case encrypt
    }
}

extension AESIGE {
    public func decrypt(buffer: Data) throws -> Data {
        try run(operation: .decrypt, buffer: buffer)
    }

    public func encrypt(buffer: Data) throws -> Data {
        try run(operation: .encrypt, buffer: buffer)
    }

    private func run(operation: Operation, buffer: Data) throws -> Data {
        var cryptorRef: CCCryptorRef?
        var status: CCCryptorStatus = -1

        key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                status = CCCryptorCreate(
                    CCOperation(operation == .decrypt ? kCCDecrypt : kCCEncrypt),
                    CCAlgorithm(kCCAlgorithmAES),
                    CCOptions(kCCOptionECBMode),
                    keyBytes.baseAddress,
                    key.count,
                    ivBytes.baseAddress,
                    &cryptorRef
                )
            }
        }

        defer { CCCryptorRelease(cryptorRef) }

        if status != kCCSuccess {
            throw AESIGEError.initializationError
        }

        var top: Data
        var bottom: Data
        if operation == .decrypt {
            top = iv.subdata(in: 16..<32)
            bottom = iv.subdata(in: 0..<16)
        } else {
            top = iv.subdata(in: 0..<16)
            bottom = iv.subdata(in: 16..<32)
        }

        var result = Data(count: buffer.count)
        var current: Data

        let dataLength: size_t = CCCryptorGetOutputLength(cryptorRef, kCCBlockSizeAES128, false)

        for i in stride(from: 0, to: buffer.count, by: 16) {
            let end = (i + 16) > buffer.count ? buffer.count : i + 16

            current = buffer.subdata(in: i..<(end))

            xor(&current, top)

            var crypted = Data(count: dataLength)

            current.withUnsafeBytes { currentBytes in
                crypted.withUnsafeMutableBytes { cryptedBytes in
                    status = CCCryptorUpdate(
                        cryptorRef,
                        currentBytes.baseAddress,
                        current.count,
                        cryptedBytes.baseAddress,
                        dataLength,
                        nil
                    )
                }
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
