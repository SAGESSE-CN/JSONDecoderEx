# JSONDecoderEx
A enhanced JSON decoder.

### Usage
```swift
struct User: Codable {
    struct Role: OptionSet, Codable, CustomStringConvertible {
        let rawValue: Int
        static let vip = Self(rawValue: 1 << 0)
        static let manageer = Self(rawValue: 1 << 1)
        var description: String {
            var bg = [String]()
            if self.contains(.vip) { bg.append("vip") }
            if self.contains(.manageer) { bg.append("manager") }
            return "\"\(bg.joined(separator: "|"))\""
        }
    }
    enum Gender: Int, Codable {
        case unknown = 0
        case male
        case woman
    }
    let uid: String
    let nickname: String?
    let role: Role
    let gender: Gender
}

let json = """
         {"uid":"coder","nickname":"coder","role":"3"}
         """
         
let value = try JSONDecoderEx().decode(User.self, from: json.data(using: .utf8)!)
print(value) 
// User(uid: "coder", nickname: Optional("coder"), role: "vip|manager", gender: User.Gender.unknown)
```

### More Compatibility
```swift
extension User.Gender : Unknownable {}

let json = """
         {"uid":1,"nickname":"coder","gender":"3"}
         """
         
let value = try JSONDecoderEx().decode(User.self, from: json.data(using: .utf8)!)
print(value) 
// User(uid: "1", nickname: Optional("coder"), role: "", gender: User.Gender.unknown)
```

```swift
/// some case decoding required a existing decoder
@propertyWrapper struct UsingCustomCoder<T: NSObject> : Codable {
    
    let wrappedValue: T
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    init(from decoder: Decoder) throws {
        let value = try JSONDecoderEx.JSONValue(from: decoder)
        // direct key-value access
        let mode = value["mode"].rawValue as? String
        // bridge to third-party library decoding model
        if (mode == "yymodel") {
            self.wrappedValue = T.yy_model(value.rawValue as? [String: Any])
        } else {
            ...
        }
    }
    
    func encode(to encoder: Encoder) throws {
        ...
    }
}

struct Live {
    ... 
    @UsingCustomCoder var other: OCModel
}

let json = """
         {"other":{"mode":"yymodel","sec":{"keys":["x"]}}}
         """
         
let value = try JSONDecoderEx().decode(Live.self, from: json.data(using: .utf8)!)
print(value.other) 
// <OCModel>{keys: ["x"]}
```
