# Swift AMF Encoder/Decoder, using Codable.

This is an incomplete/WIP Swift implementation of Action Message Format Encoding and Decoding. Originally built for use in a Swift RTMP implementation in the video broadcast space.

Making AMF parse into Swift Codable objects/structs is quite limiting, inside the confines of the Swift type system and how custom Codable Encoder/Decoders needs to be written to work. It is almost impossible not to loose information/order when encoding in and out of AMF.

A good example of Decoding working (for AMF0) is found in the `testAMFObject()` test inside the `AMF0DecodingTests`, which uses [real AMF0](https://en.wikipedia.org/wiki/Action_Message_Format) in an RTMP situation. Round trip tests demonstrate encoding too.

This implementation will get more battled/performance tested once deployed with an RTMP implementation.

Currently running at an _OK_ >60% coverage

##TODO:

### Both
- [ ] Refactor away side effecty `lazy var`s to bubble up `throws` a bit better
- [ ] Remove some boilerplate with types not easily represented in AMF, but are in Swift

### AMF0
- [ ] Better tested reference decoding
- [ ] Reference encoding implementation
- [ ] XML Document Type
- [ ] More unit tests in general

### AMF3
- [ ] Reference decoding
- [ ] Reference encoding
- [ ] Typed, Dynamic, Externalizable Objects (currently only Anonymous is supported)
- [ ] XML Type
- [ ] ByteArray Type
- [ ] Vector Types
- [ ] Dictionary Type
- [ ] Sparse ECMA (to be parsed into a dictionary) of the Array Type
- [ ] Keying by types other than strings
- [ ] RTMP based tests
- [ ] More tests

#THANKS!
Massive thanks to [@mattt](https://twitter.com/mattt) for his [Flight School Guide to Swift Codable](https://gumroad.com/l/codable), specifically his [MessagePack implementation](https://github.com/Flight-School/MessagePack) and [DIY Codable Encoder / Decoder Kit](https://github.com/Flight-School/Codable-DIY-Kit) both of which were invaluable in understanding how to write a custom Codable Encoder/Decoder and to the existing (but rather dated) [CocoaAMF](https://github.com/nesium/cocoa-amf) for getting my head around AMF (especially AMF3 - which is totally nutty - with it's proprietary Unsigned29Int that itself is bit shifted all over the place).
