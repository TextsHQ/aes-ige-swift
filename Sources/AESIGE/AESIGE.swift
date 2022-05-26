import Foundation
import CryptoSwift

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
        var aes = try AES(key: key.bytes, blockMode: ECB())
            .makeDecryptor()

        var top = iv.subdata(in: 16..<32)
        var bottom = iv.subdata(in: 0..<16)

        var result = Data(count: buffer.count)
        var current: Data

        for i in stride(from: 0, to: buffer.count, by: 16) {
            let end = (i + 16) > buffer.count ? buffer.count : i + 16

            current = buffer.subdata(in: i..<(end))

            xor(&current, top)

            var crypted = Data(try aes.update(withBytes: current.bytes))

            xor(&crypted, bottom)

            result.replaceSubrange(i..<(end), with: crypted)

            top = crypted
            bottom = buffer.subdata(in: i..<(end))
        }

        return result
    }
}
