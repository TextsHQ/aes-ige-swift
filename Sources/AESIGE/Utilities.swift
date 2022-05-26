import Foundation

@inlinable
func xor(_ buffer: inout Data, _ xor: Data) {
  for i in 0..<(buffer.count) {
    buffer[i] = buffer[i] ^ xor[i]
  }
}
