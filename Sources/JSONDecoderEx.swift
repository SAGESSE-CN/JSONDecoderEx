//
//  JSONDecoderEx.swift
//  JSONDecoderEx
//
//  Created by SAGESSE on 2019/6/11.
//  Copyright © 2019-2021 SAGESSE. All rights reserved.
//
//  Reference by https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/JSONDecoder.swift
//

import Foundation


/// `JSONDecoderEx` facilitates the decoding of JSON into semantic `Decodable` types.
open class JSONDecoderEx {
    
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate
        
        /// Decode the `Date` as a UNIX timestamp from a JSON number.
        case secondsSince1970
        
        /// Decode the `Date` as UNIX millisecond timestamp from a JSON number.
        case millisecondsSince1970
        
        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
        
        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)
    }
    
    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData
        
        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64
        
        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)
    }
    
    /// The strategy to use for non-JSON-conforming number values (IEEE 754 infinity and NaN).
    public enum NonConformingNumberDecodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`
        
        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
        
        /// Decode the values from the given representation strings.
        case custom((_ decoder: Decoder) throws -> NSNumber)
    }
    
    /// The strategy to use in decoding non-optional type for not found key or value. Defaults to `.automatically`.
    public enum NonOptionalDecodingStrategy {
        /// Throw upon encountering non-optional values.
        case `throw`
        
        /// Decode the non-optional object with a filling decoder. This is the default strategy.
        case automatically
    }
    
    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys
        
        /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
        ///
        /// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
        ///
        /// Converting from snake case to camel case:
        /// 1. Capitalizes the word starting after each `_`
        /// 2. Removes all `_`
        /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
        /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
        ///
        /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
        case convertFromSnakeCase
        
        /// Provide a custom conversion from the key in the encoded JSON to the keys specified by the decoded types.
        /// The full path to the current decoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before decoding.
        /// If the result of the conversion is a duplicate key, then only one value will be present in the container for the type to decode from.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)
    }
    
    /// Generate a custom key for reading the decoder.
    public struct JSONKey: CodingKey, ExpressibleByStringLiteral {
        
        /// The value to use in an integer-indexed collection (e.g. an int-keyed
        /// dictionary).
        public var intValue: Int?
        /// The string to use in a named collection (e.g. a string-keyed dictionary).
        public var stringValue: String
        
        /// Creates a new instance from the given string.
        public init(stringValue: String) {
            self.stringValue = stringValue
        }
        public init(stringLiteral value: String) {
            self.init(stringValue: value)
        }
        /// Creates a new instance from the specified integer.
        public init(intValue: Int) {
            self.stringValue = "Index \(intValue)"
            self.intValue = intValue
        }
    }
    
    /// Generate a custom value for reading the decoder.
    public struct JSONValue: Decodable, Equatable {
        
        fileprivate let value: _CustomJSONValue
        fileprivate init(from value: _CustomJSONValue) {
            self.value = value
        }
        
        public init(_ value: Any) {
            self.value = .init(value)
        }
        
        public init(from decoder: Decoder) throws {
            guard let impl = decoder as? _CustomJSONValueDecoderImpl else {
                throw DecodingError.typeMismatch(JSONValue.self, .init(codingPath: decoder.codingPath, debugDescription: "\(JSONValue.self) only support of \(JSONDecoderEx.self)", underlyingError: nil))
            }
            self.value = impl.value
        }
        
        /// Get a null JSON value.
        public static var null = JSONValue(from: .null)
        
        /// Gets a blank JSON value.
        public static var blank = JSONValue(from: .blank)
        
        /// A type that can be compared for JSON value equality.
        public static func == (lhs: JSONDecoderEx.JSONValue, rhs: JSONDecoderEx.JSONValue) -> Bool {
            switch (lhs.value, rhs.value) {
            case (.null, .null), (.blank, .blank):
                return true
                
            case (.number, .number), (.string, .string), (.array, .array), (.dictionary, .dictionary):
                let lhsRawValue = lhs.rawValue as AnyObject
                let rhsRawValue = rhs.rawValue as AnyObject
                return lhsRawValue.isEqual(rhsRawValue)
                
            default:
                return false
            }
        }
        
        /// Retrieves the value of array safely with a given key, return a blank value if are not an array.
        public subscript(_ key: Int) -> JSONValue {
            return .init(from: value.value(forKey: key) ?? .blank)
        }
        
        /// Retrieves the value of dictionary safely with a given key, return a blank value if are not an dictionary.
        public subscript(_ key: String) -> JSONValue {
            return .init(from: value.value(forKey: key) ?? .blank)
        }
                
        /// Retrieves the value of array or dictionary safely with a given key, return a blank value if are not an array or dictionary.
        public subscript(_ key: CodingKey) -> JSONValue {
            if let index = key.intValue {
                return self[index]
            }
            return self[key.stringValue]
        }

        
        /// Gets raw JSON data from decoder.
        public var rawValue: Any? {
            return value.rawValue
        }
    }
    
    
    /// The strategy to use in decoding dates. Defaults to `.deferredToDate`.
    open var dateDecodingStrategy: DateDecodingStrategy = .deferredToDate
    
    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64
    
    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingNumberDecodingStrategy: NonConformingNumberDecodingStrategy = .throw
    
    /// The strategy to use in decoding non-optional type for not found key or value. Defaults to `.automatically`.
    open var nonOptionalDecodingStrategy: NonOptionalDecodingStrategy = .automatically
    
    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys
    
    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    /// Set to `true` to allow parsing of JSON5. Defaults to `false`.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    open lazy var allowsJSON5: Bool = false
    
    /// Set to `true` to assume the data is a top level Dictionary (no surrounding "{ }" required). Defaults to `false`. Compatible with both JSON5 and non-JSON5 mode.
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    open lazy var assumesTopLevelDictionary: Bool = false
    
    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    fileprivate struct Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingNumberDecodingStrategy: NonConformingNumberDecodingStrategy
        let nonOptionalDecodingStrategy: NonOptionalDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }
    
    /// The options set on the top-level decoder.
    fileprivate var options: Options {
        return Options(dateDecodingStrategy: dateDecodingStrategy,
                       dataDecodingStrategy: dataDecodingStrategy,
                       nonConformingNumberDecodingStrategy: nonConformingNumberDecodingStrategy,
                       nonOptionalDecodingStrategy: nonOptionalDecodingStrategy,
                       keyDecodingStrategy: keyDecodingStrategy,
                       userInfo: userInfo)
    }
    
    fileprivate var readingOptions: JSONSerialization.ReadingOptions {
        var options = JSONSerialization.ReadingOptions()
        options.insert(.fragmentsAllowed)
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            if allowsJSON5 {
                // NSJSONReadingJSON5Allowed API_AVAILABLE(macos(12.0), ios(15.0), watchos(8.0), tvos(15.0)) = (1UL << 3),
                options.insert(.init(rawValue: 1 << 3))
            }
            if assumesTopLevelDictionary {
                // NSJSONReadingTopLevelDictionaryAssumed API_AVAILABLE(macos(12.0), ios(15.0), watchos(8.0), tvos(15.0)) = (1UL << 4),
                options.remove(.fragmentsAllowed)
                options.insert(.init(rawValue: 1 << 4))
            }
        }
        return options
    }
    
    /// Initializes `self` with default strategies.
    public init() {}
    
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder: _CustomJSONValueDecoderImpl
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: readingOptions)
            decoder = _CustomJSONValueDecoderImpl(self, from: object)
        } catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
        }
        return try decoder.decode(type)
    }
    
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter object: The json object to decode from.
    /// - returns: A value of the requested type.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T: Decodable>(_ type: T.Type, from object: Any) throws -> T {
        // The object must is a vaild the JSON object.
        guard JSONSerialization.isValidJSONObject([object]) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: nil))
        }
        let decoder = _CustomJSONValueDecoderImpl(self, from: object)
        return try decoder.decode(type)
    }
}


// MARK: -


/// If a type conform the Unknownable protocol, will automatically call when key/value not found.
public protocol Unknownable {
    static var unknown: Self { get }
}

extension RawRepresentable where Self: Decodable, Self: Unknownable {
    
    public init(from decoder: Decoder) throws where RawValue == Int {
        let rawValue = try RawValue.init(from: decoder)
        self = Self(rawValue: rawValue) ?? Self.unknown
    }
    
    public init(from decoder: Decoder) throws where RawValue == String {
        let rawValue = try RawValue.init(from: decoder)
        self = Self(rawValue: rawValue) ?? Self.unknown
    }
}


// MARK: -


/// If a type conform the DecodingCustomizable protocol, it can be manual decoding value for key.
public protocol DecodingCustomizable {
    
    /// Manual decoding JSON value for key.
    ///
    /// - parameter container: The JSON container for type.
    /// - parameter key: The member coding key for type.
    /// - returns: A value of the requested coding key, if return a nil, using default rule to decoding value for coding key.
    /// - throws: An error if any value throws an error during decoding.
    static func customizable(_ container: JSONDecoderEx.JSONValue, forKey key: CodingKey) throws -> JSONDecoderEx.JSONValue?
}


// MARK: -


fileprivate enum _CustomJSONValue {
    
    /// An blank value, a.k.a data fill mode.
    case blank
    
    case null
    case number(NSNumber)
    case string(String)
    case array([Any])
    case dictionary([String: Any])
    
    /// Create a JSON value from any object.
    init(_ value: Any) {
        switch value {
        case let value as String: self = .string(value)
        case let value as NSNumber: self = .number(value)
        case let value as [Any]: self = .array(value)
        case let value as [String: Any]: self = .dictionary(value)
        default: self = .null
        }
    }
    
    var description: String {
        switch self {
        case .dictionary: return "dictionary"
        case .array: return "array"
        case .number: return "number"
        case .string: return "string"
        case .null: return "null"
        case .blank: return "blank"
        }
    }
    
    var rawValue: Any? {
        switch self {
        case .dictionary(let value): return value
        case .array(let value): return value
        case .number(let value): return value
        case .string(let value): return value
        case .null: return NSNull()
        case .blank: return nil
        }
    }
    
    var isNull: Bool {
        switch self {
        case .null, .blank:
            return true
            
        default:
            return false
        }
    }
    
    var count: Int {
        switch self {
        case .array(let value):
            return value.count
            
        case .dictionary(let value):
            return value.count
            
        default:
            return 0
        }
    }
    
    var allKeys: [String] {
        guard case .dictionary(let value) = self else {
            return []
        }
        return .init(value.keys)
    }
    
    func contains(_ key: String) -> Bool {
        guard case .dictionary(let value) = self, let _ = value[key] else {
            return false
        }
        return true
    }
    
    func value(forKey key: Int) -> _CustomJSONValue? {
        switch self {
        case .array(let value):
            // An array value, try get a vaild element value.
            if key < value.count {
                return .init(value[key])
            }
            return nil
            
        case .blank:
            // An blank value, the self and element value is samed.
            return self
            
        default:
            return nil
        }
    }
    
    func value(forKey key: String) -> _CustomJSONValue? {
        switch self {
        case .dictionary(let value):
            // An dictionary value, try get a vaild element value.
            if let value = value[key] {
                return _CustomJSONValue(value)
            }
            return nil
            
        case .blank:
            // An blank value, the self and element value is samed.
            return self
            
        default:
            return nil
        }
    }
}


// MARK: -


fileprivate struct _CustomJSONValueDecoderImpl: Decoder {
    
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    let value: _CustomJSONValue
    let options: JSONDecoderEx.Options
    
    var customizable: DecodingCustomizable.Type?
    
    init(_ decoder: JSONDecoderEx, from value: Any) {
        self.userInfo = decoder.userInfo
        self.codingPath = []
        self.options = decoder.options
        self.value = _CustomJSONValue(value)
    }
    init(userInfo: [CodingUserInfoKey: Any], from value: _CustomJSONValue, codingPath: [CodingKey], options: JSONDecoderEx.Options) {
        self.userInfo = userInfo
        self.codingPath = codingPath
        self.value = value
        self.options = options
    }
    
    @usableFromInline func container<Key>(keyedBy key: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        guard let rawValue = dictionaryValue() else {
            throw createTypeMismatch([String: Any].self, from: value)
        }
        return KeyedDecodingContainer(_CustomJSONValueDecoderKeyedContainer<Key>(impl: self, from: rawValue, codingPath: codingPath))
    }
    
    @usableFromInline func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let rawValue = arrayValue() else {
            throw createTypeMismatch([Any].self, from: value)
        }
        return _CustomJSONValueDecoderUnkeyedContainer(impl: self, from: rawValue, codingPath: codingPath)
    }
    
    @usableFromInline func singleValueContainer() throws -> SingleValueDecodingContainer {
        return _CustomJSONValueDecoderSingleContainer(impl: self, codingPath: codingPath)
    }
    
    
    @inline(__always) func nestedDecoder(_ value: _CustomJSONValue, forKey key: CodingKey) -> _CustomJSONValueDecoderImpl {
        return _CustomJSONValueDecoderImpl(userInfo: userInfo, from: value, codingPath: codingPath + key, options: options)
    }
}

fileprivate extension _CustomJSONValueDecoderImpl {
    
    /// Convert the current value to a dictionrary value.
    func dictionaryValue() -> _CustomJSONValue? {
        switch value {
        case .dictionary(let value):
            // An dictionary value, maybe needs more convert required.
            switch options.keyDecodingStrategy {
            case .convertFromSnakeCase:
                // Convert the snake case keys in the container to camel case.
                // If we hit a duplicate key after conversion, then we'll use the first one we saw.
                // Effectively an undefined behavior with JSON dictionaries.
                var converted = [String: Any]()
                converted.reserveCapacity(value.count)
                value.forEach { key, value in
                    converted[keyFromSnakeCase(key)] = value
                }
                return .dictionary(converted)
                
            case .custom(let converter):
                // Convert the keys in container for user custom.
                var converted = [String: Any]()
                converted.reserveCapacity(value.count)
                value.forEach { key, value in
                    let key = JSONDecoderEx.JSONKey(stringValue: key)
                    converted[converter(codingPath + key).stringValue] = value
                }
                return .dictionary(converted)
                
            case .useDefaultKeys:
                // No convert required.
                return .dictionary(value)
            }
            
        case .blank:
            // An blank value, blank values can convert to any value.
            return value
            
        case .null where options.nonOptionalDecodingStrategy == .automatically:
            // An null value, but user wants convert to blank value.
            return .blank

        default:
            return nil
        }
    }
    /// Convert the current value to a array value.
    func arrayValue() -> _CustomJSONValue? {
        switch value {
        case .dictionary(let value):
            // An dictionary value, in some cases need convert to key-value pairs values.
            let pairs = value.flatMap { [$0, $1] }
            return .array(pairs)
            
        case .array, .blank:
            // An array or blank value, blank values can convert to any value.
            return value
            
        case .null where options.nonOptionalDecodingStrategy == .automatically:
            // An null value, but user wants convert to blank value.
            return .blank
            
        default:
            return nil
        }
    }
    /// Convert the specified value to string value.
    func stringValue<T>(_ typp: T.Type, from value: _CustomJSONValue, forKey key: CodingKey? = nil) throws -> String? {
        switch value {
        case .string(let value):
            // An string value already.
            return value
            
        case .number(let value):
            // An number value, convert number to string.
            return value.stringValue
            
        case .blank, .null:
            // An null or blank value, always return empty.
            return ""
            
        default:
            return nil
        }
    }
    /// Convert the specified value to number value.
    func numberValue<T>(_ type: T.Type, from value: _CustomJSONValue, forKey key: CodingKey? = nil) throws -> NSNumber? {
        switch value {
        case .number(let value):
            // An number value already, maybe needs more fixed width type validation.
            guard compatible(value, to: type) else {
                throw DecodingError.dataCorrupted(.init(codingPath: codingPath + key, debugDescription: "Parsed JSON number <\(value)> does not fit in \(type)."))
            }
            return value
            
        case .string(let value):
            // An string value
            // Try convert to inf/-inf/nan number.
            if case .convertFromString(let posInf, let negInf, let nan) = options.nonConformingNumberDecodingStrategy {
                if value == posInf {
                    return NSNumber(value: +Double.infinity)
                }
                if value == negInf {
                    return NSNumber(value: -Double.infinity)
                }
                if value == nan {
                    return NSNumber(value: Double.nan)
                }
            }
            // Provide a special version of the paraser for decimal.
            if let type = type as? Decimal.Type, let value = type.init(string: value) {
                return NSDecimalNumber(decimal: value)
            }
            // Convert the "±0/±0.0" to NSNumber.
            if let value = _numberFormatter.number(from: value) {
                return value
            }
            // Convert the "true/false" to number.
            if let value = Bool(value) {
                return NSNumber(value: value)
            }
            // Try conver to custom number.
            if case .custom(let converter) = options.nonConformingNumberDecodingStrategy {
                let decoder = _CustomJSONValueDecoderImpl(userInfo: userInfo, from: .string(value), codingPath: codingPath + key, options: options)
                return try converter(decoder)
            }
            throw DecodingError.dataCorrupted(.init(
                codingPath: codingPath + key,
                debugDescription: "Parsed JSON number <\(value)> does not fit in \(type)."))
            
        case .blank, .null:
            // An null or blank value, always return zero.
            return 0
            
        default:
            return nil
        }
    }
    
    /// Verify the number is convertable to fixed width type.
    @inline(__always) func compatible<T>(_ number: NSNumber, to type: T.Type) -> Bool {
        return true
    }
    
    /// Convert from "snake_case_keys" to "camelCaseKeys".
    /// REF: https://forums.swift.org/t/jsonencoder-key-strategies/6958/12
    @inline(__always) func keyFromSnakeCase(_ stringKey: String) -> String {
        // Find the first non-underscore character
        guard let firstNonUnderscore = stringKey.firstIndex(where: { $0 != "_" }) else {
            // Reached the end without finding an _
            return stringKey
        }

        // Find the last non-underscore character
        var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
        while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
            stringKey.formIndex(before: &lastNonUnderscore)
        }

        let keyRange = firstNonUnderscore ... lastNonUnderscore
        let leadingUnderscoreRange = stringKey.startIndex ..< firstNonUnderscore
        let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore) ..< stringKey.endIndex

        let components = stringKey[keyRange].split(separator: "_")
        let joinedString: String
        if components.count == 1 {
            // No underscores in key, leave the word as is - maybe already camel cased
            joinedString = String(stringKey[keyRange])
        } else {
            joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
        }

        // Do a cheap isEmpty check before creating and appending potentially empty strings
        let result: String
        if (leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty) {
            result = joinedString
        } else if (!leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty) {
            // Both leading and trailing underscores
            result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
        } else if (!leadingUnderscoreRange.isEmpty) {
            // Just leading
            result = String(stringKey[leadingUnderscoreRange]) + joinedString
        } else {
            // Just trailing
            result = joinedString + String(stringKey[trailingUnderscoreRange])
        }
        return result
    }
    
    
    @inline(__always) func createTypeMismatch<T>(_ type: T.Type, from value: _CustomJSONValue, forKey key: CodingKey? = nil) -> DecodingError {
        let description = "Expected to decode \(type) but found \(value.description) instead."
        return .typeMismatch(type, .init(codingPath: codingPath + key, debugDescription: description))
    }
    
    @inline(__always) func careteKeyNotFound(_ key: CodingKey, debugDescription: String? = nil) -> DecodingError {
        let description = debugDescription ?? "No value associated with key \(key)."
        return DecodingError.keyNotFound(key, .init(codingPath: codingPath + key, debugDescription: description))
    }
    
    @inline(__always) func createValueNotFound<T>(_ type: T.Type, forKey key: CodingKey, debugDescription: String) -> DecodingError {
        return DecodingError.valueNotFound(type, .init(codingPath: codingPath + key, debugDescription: debugDescription))
    }
}

fileprivate extension _CustomJSONValueDecoderImpl {
    
    @inline(__always) func decode<T: Decodable>(_ type: T.Type) throws -> T {
        // Decode the built-in type.
        if let value = try decodeValue(type) {
            return value
        }
        var impl = self
        impl.customizable = type as? DecodingCustomizable.Type
        return try type.init(from: impl)
    }
    
    @inline(__always) private func decodeValue<T: Decodable>(_ type: T.Type) throws -> T? {
        // When value is a null value, preferred to using custom constructor provider.
        if value.isNull, let value = decodeUnknownValue(type) {
            return value
        }
        // Decode the built-in type.
        switch type {
        case is Date.Type:
            return try decodeDateValue() as? T
            
        case is Data.Type:
            return try decodeDataValue() as? T
            
        case is URL.Type:
            return try decodeURLValue() as? T
            
        case is Decimal.Type:
            return try decodeDecimalValue() as? T
            
        default:
            return nil
        }
    }
    
    @inline(__always) private func decodeUnknownValue<T: Decodable>(_ type: T.Type) -> T? {
        switch type {
        case let type as Unknownable.Type:
            return type.unknown as? T
            
        case let type as ExpressibleByNilLiteral.Type:
            return type.init(nilLiteral: ()) as? T
            
        default:
            return nil
        }
    }
    @inline(__always) private func decodeDateValue() throws -> Date {
        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            return try Date(from: self)
            
        case .secondsSince1970:
            let container = try singleValueContainer()
            let double = try container.decode(Double.self)
            return Date(timeIntervalSince1970: double)
            
        case .millisecondsSince1970:
            let container = try singleValueContainer()
            let double = try container.decode(Double.self)
            return Date(timeIntervalSince1970: double / 1000.0)
            
        case .iso8601:
            guard #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            let container = try singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = _iso8601Formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
            }
            return date
            
        case .formatted(let formatter):
            let container = try singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            return date
            
        case .custom(let closure):
            return try closure(self)
        }
    }
    @inline(__always) private func decodeDataValue() throws -> Data {
        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            return try Data(from: self)
            
        case .base64:
            let container = try singleValueContainer()
            let string = try container.decode(String.self)
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            return data
            
        case .custom(let closure):
            return try closure(self)
        }
    }
    @inline(__always) private func decodeURLValue() throws -> URL {
        let container = try singleValueContainer()
        let string = try container.decode(String.self)
        guard let url = URL(string: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Invalid URL string."))
        }
        return url
    }
    @inline(__always) private func decodeDecimalValue() throws -> Decimal {
        guard let value = try numberValue(Decimal.self, from: value) else {
            throw createTypeMismatch(Decimal.self, from: value)
        }
        return value.decimalValue
    }
    
}


// MARK: -

fileprivate struct _CustomJSONValueDecoderSingleContainer: SingleValueDecodingContainer {
    
    let impl: _CustomJSONValueDecoderImpl
    let value: _CustomJSONValue
    let codingPath: [CodingKey]
    
    init(impl: _CustomJSONValueDecoderImpl, codingPath: [CodingKey]) {
        self.impl = impl
        self.value = impl.value
        self.codingPath = codingPath
    }
    
    
    func decodeNil() -> Bool {
        value.isNull
    }
    
    func decode(_ type: String.Type) throws -> String {
        try decodeString(type)
    }
    func decode(_ type: Bool.Type) throws -> Bool {
        try decodeNumber(type).boolValue
    }
    func decode(_ type: Double.Type) throws -> Double {
        try decodeNumber(type).doubleValue
    }
    func decode(_ type: Float.Type) throws -> Float {
        try decodeNumber(type).floatValue
    }
    func decode(_ type: Int.Type) throws -> Int {
        try decodeNumber(type).intValue
    }
    func decode(_ type: Int8.Type) throws -> Int8 {
        try decodeNumber(type).int8Value
    }
    func decode(_ type: Int16.Type) throws -> Int16 {
        try decodeNumber(type).int16Value
    }
    func decode(_ type: Int32.Type) throws -> Int32 {
        try decodeNumber(type).int32Value
    }
    func decode(_ type: Int64.Type) throws -> Int64 {
        try decodeNumber(type).int64Value
    }
    func decode(_ type: UInt.Type) throws -> UInt {
        try decodeNumber(type).uintValue
    }
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decodeNumber(type).uint8Value
    }
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decodeNumber(type).uint16Value
    }
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decodeNumber(type).uint32Value
    }
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decodeNumber(type).uint64Value
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        try impl.decode(T.self)
    }
    
    
    @inline(__always) private func decodeNumber<T>(_ type: T.Type) throws -> NSNumber {
        guard let numberValue = try impl.numberValue(type, from: value) else {
            throw impl.createTypeMismatch(type, from: value)
        }
        return numberValue
    }
    @inline(__always) private func decodeString<T>(_ type: T.Type) throws -> String {
        guard let stringValue = try impl.stringValue(type, from: value) else {
            throw impl.createTypeMismatch(type, from: value)
        }
        return stringValue
    }
}

fileprivate struct _CustomJSONValueDecoderKeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    let impl: _CustomJSONValueDecoderImpl
    let value: _CustomJSONValue
    let codingPath: [CodingKey]
    
    init(impl: _CustomJSONValueDecoderImpl, from value: _CustomJSONValue, codingPath: [CodingKey]) {
        self.impl = impl
        self.value = value
        self.codingPath = codingPath
    }
    
    
    var allKeys: [Key] {
        value.allKeys.compactMap {
            Key(stringValue: $0)
        }
    }
    
    func contains(_ key: Key) -> Bool {
        value.contains(key.stringValue)
    }
    
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try value(Never.self, forKey: key).isNull
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try decodeString(type, forKey: key)
    }
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try decodeNumber(type, forKey: key).boolValue
    }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try decodeNumber(type, forKey: key).doubleValue
    }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try decodeNumber(type, forKey: key).floatValue
    }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try decodeNumber(type, forKey: key).intValue
    }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try decodeNumber(type, forKey: key).int8Value
    }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try decodeNumber(type, forKey: key).int16Value
    }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try decodeNumber(type, forKey: key).int32Value
    }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try decodeNumber(type, forKey: key).int64Value
    }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try decodeNumber(type, forKey: key).uintValue
    }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try decodeNumber(type, forKey: key).uint8Value
    }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try decodeNumber(type, forKey: key).uint16Value
    }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try decodeNumber(type, forKey: key).uint32Value
    }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try decodeNumber(type, forKey: key).uint64Value
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        try decoder(forKey: key).decode(type)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try decoder(forKey: key).container(keyedBy: type)
    }
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try decoder(forKey: key).unkeyedContainer()
    }
    
    func superDecoder() throws -> Decoder {
        try decoder(forKey: JSONDecoderEx.JSONKey(stringValue: "super"))
    }
    func superDecoder(forKey key: Key) throws -> Decoder {
        try decoder(forKey: key)
    }
    
    @inline(__always) private func resolvedValue(_ key: CodingKey) throws -> _CustomJSONValue? {
        // call manual decoding
        if let resolvedValue = try impl.customizable?.customizable(.init(from: value), forKey: key)?.value {
            return resolvedValue
        }
        return value.value(forKey: key.stringValue)
    }

    @inline(__always) private func value<T>(_ type: T.Type, forKey key: CodingKey) throws -> _CustomJSONValue {
        guard let rawValue = try resolvedValue(key) else {
            if case .automatically = impl.options.nonOptionalDecodingStrategy {
                return .blank
            }
            throw impl.careteKeyNotFound(key)
        }
        return rawValue
    }
    @inline(__always) private func decodeNumber<T>(_ type: T.Type, forKey key: Key) throws -> NSNumber {
        let rawValue = try value(type, forKey: key)
        guard let numberValue = try impl.numberValue(type, from: rawValue, forKey: key) else {
            throw impl.createTypeMismatch(type, from: rawValue, forKey: key)
        }
        return numberValue
    }
    @inline(__always) private func decodeString(_ type: String.Type, forKey key: Key) throws -> String {
        let rawValue = try value(type, forKey: key)
        guard let stringValue = try impl.stringValue(type, from: rawValue, forKey: key) else {
            throw impl.createTypeMismatch(type, from: rawValue, forKey: key)
        }
        return stringValue
    }
    
    @inline(__always) private func decoder(forKey key: CodingKey) throws -> _CustomJSONValueDecoderImpl {
        let rawValue = try value(Decoder.self, forKey: key)
        return impl.nestedDecoder(rawValue, forKey: key)
    }
}

fileprivate struct _CustomJSONValueDecoderUnkeyedContainer: UnkeyedDecodingContainer {
    
    let impl: _CustomJSONValueDecoderImpl
    let value: _CustomJSONValue
    let codingPath: [CodingKey]
    
    var count: Int? { value.count }
    var isAtEnd: Bool { currentIndex >= (count ?? 0) }
    var currentIndex = 0
    
    init(impl: _CustomJSONValueDecoderImpl, from value: _CustomJSONValue, codingPath: [CodingKey]) {
        self.impl = impl
        self.value = value
        self.codingPath = codingPath
    }
    
    mutating func decodeNil() throws -> Bool {
        // If the value is not null, does not increment currentIndex.
        guard try nextValue(Never.self).isNull else {
            return false
        }
        self.currentIndex += 1
        return true
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        try decodeString(type)
    }
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        try decodeNumber(type).boolValue
    }
    mutating func decode(_ type: Double.Type) throws -> Double {
        try decodeNumber(type).doubleValue
    }
    mutating func decode(_ type: Float.Type) throws -> Float {
        try decodeNumber(type).floatValue
    }
    mutating func decode(_ type: Int.Type) throws -> Int {
        try decodeNumber(type).intValue
    }
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try decodeNumber(type).int8Value
    }
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try decodeNumber(type).int16Value
    }
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try decodeNumber(type).int32Value
    }
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try decodeNumber(type).int64Value
    }
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try decodeNumber(type).uintValue
    }
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decodeNumber(type).uint8Value
    }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decodeNumber(type).uint16Value
    }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decodeNumber(type).uint32Value
    }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decodeNumber(type).uint64Value
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let decoder = try nestedDecoder(as: T.self)
        let result = try decoder.decode(T.self)
        
        // Because of the requirement that the index not be incremented unless
        // decoding the desired result type succeeds, it can not be a tail call.
        // Hopefully the compiler still optimizes well enough that the result
        // doesn't get copied around.
        self.currentIndex += 1
        return result
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        let decoder = try nestedDecoder(as: KeyedDecodingContainer<NestedKey>.self)
        let container = try decoder.container(keyedBy: type)
        self.currentIndex += 1
        return container
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let decoder = try nestedDecoder(as: UnkeyedDecodingContainer.self)
        let container = try decoder.unkeyedContainer()
        self.currentIndex += 1
        return container
    }
    
    mutating func superDecoder() throws -> Decoder {
        let decoder = try nestedDecoder(as: Decoder.self)
        self.currentIndex += 1
        return decoder
    }
    
    
    @inline(__always) private var currentIndexKey: JSONDecoderEx.JSONKey {
        return .init(intValue: currentIndex)
    }
    
    @inline(__always) private mutating func nextValue<T>(_ type: T.Type) throws -> _CustomJSONValue {
        guard let rawValue = value.value(forKey: currentIndex) else {
            if case .automatically = impl.options.nonOptionalDecodingStrategy {
                return .blank
            }
            var message = "Unkeyed container is at end."
            if T.self == UnkeyedDecodingContainer.self {
                message = "Cannot get nested unkeyed container -- unkeyed container is at end."
            }
            if T.self == Decoder.self {
                message = "Cannot get superDecoder() -- unkeyed container is at end."
            }
            throw impl.createValueNotFound(type, forKey: currentIndexKey, debugDescription: message)
        }
        return rawValue
    }
    @inline(__always) private mutating func decodeNumber<T>(_ type: T.Type) throws -> NSNumber {
        let value = try nextValue(type)
        guard let numberValue = try impl.numberValue(type, from: value, forKey: currentIndexKey) else {
            throw impl.createTypeMismatch(type, from: value, forKey: currentIndexKey)
        }
        self.currentIndex += 1
        return numberValue
    }
    @inline(__always) private mutating func decodeString<T>(_ type: T.Type) throws -> String {
        let value = try nextValue(type)
        guard let stringValue = try impl.stringValue(type, from: value, forKey: currentIndexKey) else {
            throw impl.createTypeMismatch(type, from: value, forKey: currentIndexKey)
        }
        self.currentIndex += 1
        return stringValue
    }
    
    @inline(__always) private mutating func nestedDecoder<T>(as type: T) throws -> _CustomJSONValueDecoderImpl {
        let value = try nextValue(T.self)
        return impl.nestedDecoder(value, forKey: currentIndexKey)
    }
}


// MARK: -


fileprivate extension Array {
    static func +(lhs: [Element], rhs: Element?) -> [Element] where Element == CodingKey {
        guard let rhs = rhs else {
            return lhs
        }
        var results = lhs
        results.append(rhs)
        return results
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
fileprivate var _iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = .withInternetDateTime
    return formatter
}()

fileprivate var _numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    return formatter
}()

