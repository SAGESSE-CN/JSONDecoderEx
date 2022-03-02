//
//  File.swift
//  
//
//  Created by SAGESSE on 2021/10/20.
//

import XCTest
@testable import JSONDecoderEx


struct Demo: Decodable {
    struct A: Decodable {
        var a: Bool
        var b: Int
        var c: Float
        var d: Double
        var e: UInt
        var f: Date
        var g: Data
        var h: String
        var i: [String]
        var j: [String: String]
        var k: [Date]
        var l: Bool
        var m: CGFloat
        var n: URL?
    }
    struct B: Decodable, Unknownable {
        static var unknown: Self {
            return .init()
        }
        var o = "i2"
        var k = 2
    }
    var a1: Bool
    var b0: Int
    var b1: Int8
    var b2: Int16
    var b3: Int32
    var b4: Int64
    var b5: UInt
    var b6: UInt8
    var b7: UInt16
    var b8: UInt32
    var b9: UInt64
    var c0: Float
    var c1: Double
    var c2: CGFloat
    var c3: TimeInterval
    var d0: CGSize
    var d1: CGPoint
    var d2: CGRect
    var d3: Decimal
    var e0: String
    var e1: String?
    var e2: String
    var e3: String
    var f0: Date
    var f1: Data
    var f2: URL?
    var y0: Float
    var y1: [Float]
    var y2: [String: Float]
    var y3: [Int: Float]
    var y4: [String: Float]
    var y5: [Decimal: Date]
    var z0: A
    var z1: [A]
    var z2: B
    var z3: Float
    var z4: Decimal
    //var z5: SIMD<Int>
}

class JSONDecoderTests: XCTestCase {
    
    let def = JSONDecoderEx()
    let null = NSNull()
    
    
    func testInvaidJSON() {
        XCTAssertThrowsError(try def.decode(Int.self, from: "{".data(using: .utf8)!))
        XCTAssertThrowsError(try def.decode(Int.self, from: NSObject()))
    }
    func testVaidJSON() {
        XCTAssertNoThrow(try def.decode([String: Int].self, from: "{}".data(using: .utf8)!))
        XCTAssertNoThrow(try def.decode([String].self, from: "[]".data(using: .utf8)!))
        XCTAssertNoThrow(try def.decode([String: Int].self, from: [:]))
        XCTAssertNoThrow(try def.decode([String].self, from: []))
        XCTAssertNoThrow(try def.decode(Int.self, from: "0"))
    }
    
    func testMismathObject() {
        XCTAssertThrowsError(try def.decode([Int].self, from: "0"))
        XCTAssertThrowsError(try def.decode([String: Int].self, from: "0"))
        XCTAssertNoThrow(try def.decode([Int].self, from: [:])) // convert to key-value pairs.
        XCTAssertThrowsError(try def.decode([String: Int].self, from: []))
        XCTAssertThrowsError(try def.decode(Int.self, from: [:]))
        XCTAssertThrowsError(try def.decode(Int.self, from: []))
        XCTAssertNoThrow(try def.decode(CGRect.self, from: []))
    }
    
    func testMemberOptionalObject() {
        struct E<T: Codable & Equatable>: Codable, Equatable {
            let w: T?
        }
        let d = [String: Any]()
        XCTAssertEqual(try def.decode(E<Int>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Int8>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Int16>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Int32>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Int64>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<UInt>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<UInt8>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<UInt16>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<UInt32>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<UInt64>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Float>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Double>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Decimal>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<CGFloat>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<CGRect>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<TimeInterval>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<String>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Date>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<Data>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<[Int]>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<[String: Int]>.self, from: d).w, nil)
        XCTAssertEqual(try def.decode(E<E<Int>>.self, from: d).w, nil)
    }
    func testMemberEmpyObject() {
        struct E<T: Codable>: Codable {
            let w: T
        }
        let d = [String: Any]()
        XCTAssertEqual(try def.decode(E<Int>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Int8>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Int16>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Int32>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Int64>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<UInt>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<UInt8>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<UInt16>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<UInt32>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<UInt64>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Float>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Double>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<Decimal>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<CGFloat>.self, from: d).w, 0)
        XCTAssertEqual(try def.decode(E<CGRect>.self, from: d).w, .zero)
        XCTAssertEqual(try def.decode(E<TimeInterval>.self, from: d).w, .zero)
        XCTAssertEqual(try def.decode(E<String>.self, from: d).w, "")
        XCTAssertEqual(try def.decode(E<Date>.self, from: d).w, .init(timeIntervalSinceReferenceDate: 0))
        XCTAssertEqual(try def.decode(E<Data>.self, from: d).w, .init())
        XCTAssertEqual(try def.decode(E<[Int]>.self, from: d).w, [])
        XCTAssertEqual(try def.decode(E<[String: Int]>.self, from: d).w, [:])
        XCTAssertEqual(try def.decode(E<E<Int>>.self, from: d).w.w, 0)
    }
    
    func testInitEmptyObject() {
        let d = null
        XCTAssertEqual(try def.decode(Int.self, from: d), 0)
        XCTAssertEqual(try def.decode(Int8.self, from: d), 0)
        XCTAssertEqual(try def.decode(Int16.self, from: d), 0)
        XCTAssertEqual(try def.decode(Int32.self, from: d), 0)
        XCTAssertEqual(try def.decode(Int64.self, from: d), 0)
        XCTAssertEqual(try def.decode(UInt.self, from: d), 0)
        XCTAssertEqual(try def.decode(UInt8.self, from: d), 0)
        XCTAssertEqual(try def.decode(UInt16.self, from: d), 0)
        XCTAssertEqual(try def.decode(UInt32.self, from: d), 0)
        XCTAssertEqual(try def.decode(UInt64.self, from: d), 0)
        XCTAssertEqual(try def.decode(Float.self, from: d), 0)
        XCTAssertEqual(try def.decode(Double.self, from: d), 0)
        XCTAssertEqual(try def.decode(Decimal.self, from: d), 0)
        XCTAssertEqual(try def.decode(CGFloat.self, from: d), 0)
        XCTAssertEqual(try def.decode(CGRect.self, from: d), .zero)
        XCTAssertEqual(try def.decode(TimeInterval.self, from: d), .zero)
        XCTAssertEqual(try def.decode(String.self, from: d), "")
        XCTAssertEqual(try def.decode(Date.self, from: d), .init(timeIntervalSinceReferenceDate: 0))
        XCTAssertEqual(try def.decode(Data.self, from: d), .init())
        XCTAssertEqual(try def.decode([Int].self, from: d), [])
        XCTAssertEqual(try def.decode([String: Int].self, from: d), [:])
    }

    func testStringToNumber() {
        let d = "3.141592653589793238462643383279502884197169399375105820974944592307816406286"
        XCTAssertEqual(try def.decode(Int.self, from: d), 3)
        XCTAssertEqual(try def.decode(Int8.self, from: d), 3)
        XCTAssertEqual(try def.decode(Int16.self, from: d), 3)
        XCTAssertEqual(try def.decode(Int32.self, from: d), 3)
        XCTAssertEqual(try def.decode(Int64.self, from: d), 3)
        XCTAssertEqual(try def.decode(UInt.self, from: d), 3)
        XCTAssertEqual(try def.decode(UInt8.self, from: d), 3)
        XCTAssertEqual(try def.decode(UInt16.self, from: d), 3)
        XCTAssertEqual(try def.decode(UInt32.self, from: d), 3)
        XCTAssertEqual(try def.decode(UInt64.self, from: d), 3)
        XCTAssertEqual(try def.decode(Float.self, from: d), 3.1415927)
        XCTAssertEqual(try def.decode(Double.self, from: d), 3.141592653589793)
        XCTAssertEqual(try def.decode(Decimal.self, from: d).description, "3.14159265358979323846264338327950288419")
        XCTAssertEqual(try def.decode(CGFloat.self, from: d), 3.141592653589793)
        XCTAssertThrowsError(try def.decode(CGRect.self, from: d))
        XCTAssertEqual(try def.decode(TimeInterval.self, from: d), 3.141592653589793)
        XCTAssertEqual(try def.decode(String.self, from: d), d)
        XCTAssertEqual(try def.decode(Date.self, from: d), .init(timeIntervalSinceReferenceDate: 3.141592653589793))
        XCTAssertThrowsError(try def.decode(Data.self, from: d))
        XCTAssertEqual(try def.decode([Int].self, from: [d]), [3])
        XCTAssertThrowsError(try def.decode([String: Int].self, from: d))
    }
    func testStringToNumber2() {
        let d = "-3.141592653589793238462643383279502884197169399375105820974944592307816406286"
        XCTAssertEqual(try def.decode(Int.self, from: d), -3)
        XCTAssertEqual(try def.decode(Int8.self, from: d), -3)
        XCTAssertEqual(try def.decode(Int16.self, from: d), -3)
        XCTAssertEqual(try def.decode(Int32.self, from: d), -3)
        XCTAssertEqual(try def.decode(Int64.self, from: d), -3)
        XCTAssertEqual(try def.decode(UInt.self, from: d), .max - 2)
        XCTAssertEqual(try def.decode(UInt8.self, from: d), .max - 2)
        XCTAssertEqual(try def.decode(UInt16.self, from: d), .max - 2)
        XCTAssertEqual(try def.decode(UInt32.self, from: d), .max - 2)
        XCTAssertEqual(try def.decode(UInt64.self, from: d), .max - 2)
        XCTAssertEqual(try def.decode(Float.self, from: d), -3.1415927)
        XCTAssertEqual(try def.decode(Double.self, from: d), -3.141592653589793)
        XCTAssertEqual(try def.decode(Decimal.self, from: d).description, "-3.14159265358979323846264338327950288419")
        XCTAssertEqual(try def.decode(CGFloat.self, from: d), -3.141592653589793)
        XCTAssertThrowsError(try def.decode(CGRect.self, from: d))
        XCTAssertEqual(try def.decode(TimeInterval.self, from: d), -3.141592653589793)
        XCTAssertEqual(try def.decode(String.self, from: d), d)
        XCTAssertEqual(try def.decode(Date.self, from: d), .init(timeIntervalSinceReferenceDate: -3.141592653589793))
        XCTAssertThrowsError(try def.decode(Data.self, from: d))
        XCTAssertEqual(try def.decode([Int].self, from: [d]), [-3])
        XCTAssertThrowsError(try def.decode([String: Int].self, from: d))
    }

    func testNumberToString() {
        XCTAssertEqual(try def.decode(String.self, from: NSNumber(value: true)), "1")
        XCTAssertEqual(try def.decode(String.self, from: NSNumber(value: 2)), "2")
        XCTAssertEqual(try def.decode(String.self, from: NSNumber(value: 2.23)), "2.23")
        XCTAssertEqual(try def.decode(String.self, from: NSNumber(value: -2.23)), "-2.23")
    }
    
    func testCustomInitial() {
        struct E<T: Codable>: Codable {
            let w: T
        }
        struct I: Codable, Unknownable {
            static let unknown = I()
            var w: Int = 233
        }
        XCTAssertEqual(try def.decode(E<I>.self, from: [:]).w.w, 233)
    }
    
    func testSuperDecoder() {
        struct K: Codable {
            var d: [String: Int]
            init(from decoder: Decoder) throws {
                let lc = try decoder.container(keyedBy: JSONDecoderEx.JSONKey.self)
                let a = try Int(from: try lc.superDecoder(forKey: "a"))
                let b = try Int(from: try lc.superDecoder(forKey: "b"))
                let c = try Int(from: try lc.superDecoder(forKey: "c"))
                self.d = ["a":a,"b":b,"c":c]
            }
        }
        struct C: Codable {
            var d: [Int]
            init(from decoder: Decoder) throws {
                var lc = try decoder.unkeyedContainer()
                let p1 = try Int(from: try lc.superDecoder())
                let p2 = try Int(from: try lc.superDecoder())
                let p3 = try Int(from: try lc.superDecoder())
                self.d = [p1,p2,p3]
            }
        }
        struct S<T: Codable>: Codable {
            let t: T
        }
        XCTAssertEqual(try def.decode(C.self, from: "[1,2,3]".data(using: .utf8)!).d, [1,2,3])
        XCTAssertEqual(try def.decode(S<C>.self, from: "{\"t\":[1,2,3]}".data(using: .utf8)!).t.d, [1,2,3])
        
        XCTAssertEqual(try def.decode(K.self, from: "{\"a\":1,\"b\":2,\"c\":3}".data(using: .utf8)!).d, ["a":1,"b":2,"c":3])
        XCTAssertEqual(try def.decode(S<K>.self, from: "{\"t\":{\"a\":1,\"b\":2,\"c\":3},\"q\":9}".data(using: .utf8)!).t.d, ["a":1,"b":2,"c":3])
    }
    
    func testNull() {
        struct R: Codable {
            let subjects: [S]
            struct S: Codable {
            }
        }
        XCTAssertEqual(try def.decode(R.self, from: "{\"subjects\":null}".data(using: .utf8)!).subjects.count, 0)
        XCTAssertEqual(try def.decode(R.self, from: "{\"subjects\":[null]}".data(using: .utf8)!).subjects.count, 1)
        XCTAssertEqual(try def.decode(R.self, from: null).subjects.count, 0)
        XCTAssertEqual(try def.decode([R].self, from: null).count, 0)
    }
    func testNullToOptional() {
        struct R: Codable {
            let subjects: [S]?
            struct S: Codable {
            }
        }
        XCTAssertNil(try def.decode(R.self, from: "{\"subjects\":null}".data(using: .utf8)!).subjects)
        XCTAssertNotNil(try def.decode(R.self, from: "{\"subjects\":[null]}".data(using: .utf8)!).subjects)
        XCTAssertNil(try def.decode(R.self, from: null).subjects)
        XCTAssertNil(try def.decode([R]?.self, from: null))
    }
    func testNullToUnknown() {
        struct R: Codable, Unknownable {
            let i: Int
            static let unknown = R(i: 999)
        }
        struct S: Codable {
            let r: R
        }
        XCTAssertEqual(try def.decode(R.self, from: null).i, 999)
        XCTAssertEqual(try def.decode([R].self, from: [null])[0].i, 999)
        XCTAssertEqual(try def.decode(S.self, from: null).r.i, 999)
        XCTAssertEqual(try def.decode(S.self, from: [:]).r.i, 999)
        XCTAssertEqual(try def.decode(S.self, from: ["r":null]).r.i, 999)
        XCTAssertEqual(try def.decode(S.self, from: ["r":[:]]).r.i, 0)
    }
    
    func testKeyPath() {
        struct R: Codable {
            let name: String
            let name2: String
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: JSONDecoderEx.JSONKey.self)
                let p = try container.nestedContainer(keyedBy: JSONDecoderEx.JSONKey.self, forKey: "p")
                name = try p.decode(String.self, forKey: "name") // p.name
                let pp = try p.nestedContainer(keyedBy: JSONDecoderEx.JSONKey.self, forKey: "pp")
                name2 = try pp.decode(String.self, forKey: "name") // p.pp.name
            }
        }
        XCTAssertEqual(try def.decode(R.self, from: "{\"p\":{\"name\":\"swift\"}}".data(using: .utf8)!).name, "swift")
        XCTAssertEqual(try def.decode(R.self, from: "{\"p\":{\"name\":\"swift\",\"pp\":{\"name\":5.2}}}".data(using: .utf8)!).name2, "5.2")
        XCTAssertEqual(try def.decode(R.self, from: "{}".data(using: .utf8)!).name, "")
        XCTAssertEqual(try def.decode(R.self, from: "{\"p\":null}".data(using: .utf8)!).name, "")
        XCTAssertThrowsError(try def.decode(R.self, from:  "{\"p\":[]}".data(using: .utf8)!))
        XCTAssertEqual(try def.decode(R.self, from: "{\"p\":{}}".data(using: .utf8)!).name, "")
        XCTAssertThrowsError(try def.decode(R.self, from: "{\"p\":\"123\"}".data(using: .utf8)!))
    }
    
    func testDic() {
        struct R: Codable {
            let name: String
        }
        XCTAssertEqual(try def.decode(R.self, from: "{\"p\":\"123\"}".data(using: .utf8)!).name, "")
    }

    func testKeyDecodingStrategy() {
        struct R: Decodable {
            let k: String
            init(from decoder: Decoder) throws {
                let c = try decoder.container(keyedBy: JSONDecoderEx.JSONKey.self)
                k = c.allKeys.first?.stringValue ?? ""
            }
        }
        let def = JSONDecoderEx()
        XCTAssertEqual(try def.decode(R.self, from: ["someNumberValue":0]).k, "someNumberValue")
        XCTAssertEqual(try def.decode(R.self, from: ["some_number_value":0]).k, "some_number_value")
        def.keyDecodingStrategy = .convertFromSnakeCase
        XCTAssertEqual(try def.decode(R.self, from: ["someNumberValue":0]).k, "someNumberValue")
        XCTAssertEqual(try def.decode(R.self, from: ["some_number_value":0]).k, "someNumberValue")
        let fromSnakeCaseTests = [
            ("", ""), // don't die on empty string
            ("a", "a"), // single character
            ("ALLCAPS", "ALLCAPS"), // If no underscores, we leave the word as-is
            ("ALL_CAPS", "allCaps"), // Conversion from screaming snake case
            ("single", "single"), // do not capitalize anything with no underscore
            ("snake_case", "snakeCase"), // capitalize a character
            ("one_two_three", "oneTwoThree"), // more than one word
            ("one_2_three", "one2Three"), // numerics
            ("one2_three", "one2Three"), // numerics, part 2
            ("snake_Ćase", "snakeĆase"), // do not further modify a capitalized diacritic
            ("snake_ćase", "snakeĆase"), // capitalize a diacritic
            ("alreadyCamelCase", "alreadyCamelCase"), // do not modify already camel case
            ("__this_and_that", "__thisAndThat"),
            ("_this_and_that", "_thisAndThat"),
            ("this__and__that", "thisAndThat"),
            ("this_and_that__", "thisAndThat__"),
            ("this_aNd_that", "thisAndThat"),
            ("_one_two_three", "_oneTwoThree"),
            ("one_two_three_", "oneTwoThree_"),
            ("__one_two_three", "__oneTwoThree"),
            ("one_two_three__", "oneTwoThree__"),
            ("_one_two_three_", "_oneTwoThree_"),
            ("__one_two_three", "__oneTwoThree"),
            ("__one_two_three__", "__oneTwoThree__"),
            ("_test", "_test"),
            ("_test_", "_test_"),
            ("__test", "__test"),
            ("test__", "test__"),
            ("_", "_"),
            ("__", "__"),
            ("___", "___"),
            ("m͉̟̹y̦̳G͍͚͎̳r̤͉̤͕ͅea̲͕t͇̥̼͖U͇̝̠R͙̻̥͓̣L̥̖͎͓̪̫ͅR̩͖̩eq͈͓u̞e̱s̙t̤̺ͅ", "m͉̟̹y̦̳G͍͚͎̳r̤͉̤͕ͅea̲͕t͇̥̼͖U͇̝̠R͙̻̥͓̣L̥̖͎͓̪̫ͅR̩͖̩eq͈͓u̞e̱s̙t̤̺ͅ"), // because Itai wanted to test this
            ("🐧_🐟", "🐧🐟") // fishy emoji example?
        ]
        for (lhs, rhs) in fromSnakeCaseTests {
            XCTAssertEqual(try def.decode(R.self, from: [lhs:0]).k, rhs)
        }
        def.keyDecodingStrategy = .custom {
            if $0.last?.stringValue == "hello" {
                return JSONDecoderEx.JSONKey(stringValue: "world")
            }
            return $0.last!
        }
        XCTAssertEqual(try def.decode(R.self, from: ["x":0]).k, "x")
        XCTAssertEqual(try def.decode(R.self, from: ["hello":0]).k, "world")
    }

    func testDateDecodingStrategy() {
        let def = JSONDecoderEx()
        def.dateDecodingStrategy = .deferredToDate
        XCTAssertEqual(try def.decode(Date.self, from: 1000), Date(timeIntervalSinceReferenceDate: 1000))
        XCTAssertEqual(try def.decode(Date.self, from: "1000"), Date(timeIntervalSinceReferenceDate: 1000))
        XCTAssertThrowsError(try def.decode(Date.self, from: "1970-01-01T00:00:01+00:00"))
        def.dateDecodingStrategy = .secondsSince1970
        XCTAssertEqual(try def.decode(Date.self, from: 1000), Date(timeIntervalSince1970: 1000))
        def.dateDecodingStrategy = .millisecondsSince1970
        XCTAssertEqual(try def.decode(Date.self, from: 1000), Date(timeIntervalSince1970: 1))
        if #available(macOS 10.12, iOS 10.0, watchOS 8.0, *) {
            def.dateDecodingStrategy = .iso8601
            XCTAssertThrowsError(try def.decode(Date.self, from: 1000))
            XCTAssertThrowsError(try def.decode(Date.self, from: "1000"))
            XCTAssertEqual(try def.decode(Date.self, from: "1970-01-01T00:00:01+00:00"), Date(timeIntervalSince1970: 1))
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        def.dateDecodingStrategy = .formatted(df)
        XCTAssertThrowsError(try def.decode(Date.self, from: 1000))
        XCTAssertThrowsError(try def.decode(Date.self, from: "1000"))
        XCTAssertEqual(try def.decode(Date.self, from: "1970-01-01 00:00:01"), Date(timeIntervalSince1970: 1))
        def.dateDecodingStrategy = .custom { coder in
            let value = try coder.singleValueContainer()
            return try Date(timeIntervalSince1970: value.decode(Double.self))
        }
        XCTAssertEqual(try def.decode(Date.self, from: 1000), Date(timeIntervalSince1970: 1000))
        XCTAssertEqual(try def.decode(Date.self, from: "1000"), Date(timeIntervalSince1970: 1000))
    }
    
    func testDataDecodingStrategy() {
        let v = "IzM=" // 23 33
        let def = JSONDecoderEx()
        def.dataDecodingStrategy = .deferredToData
        XCTAssertThrowsError(try def.decode(Data.self, from: "1000"))
        XCTAssertThrowsError(try def.decode(Data.self, from: 0x2333))
        XCTAssertEqual(try def.decode(Data.self, from: [0x23,0x33]).base64EncodedString(), v)
        def.dataDecodingStrategy = .base64
        XCTAssertEqual(try def.decode(Data.self, from: v).base64EncodedString(), v)
        XCTAssertThrowsError(try def.decode(Data.self, from: "{0}"))
        def.dataDecodingStrategy = .custom {
            let value = try $0.singleValueContainer()
            if try value.decode(Int.self) == 9 {
                return Data([0x23, 0x33])
            }
            return Data()
        }
        XCTAssertThrowsError(try def.decode(Data.self, from: "{0}"))
        XCTAssertEqual(try def.decode(Data.self, from: 9).base64EncodedString(), v)
        XCTAssertEqual(try def.decode(Data.self, from: 10).base64EncodedString(), "")
    }
    
    func testNonConformingNumberDecodingStrategy() {
        let def = JSONDecoderEx()
        XCTAssertThrowsError(try def.decode(Int.self, from: "0x1234"))
        def.nonConformingNumberDecodingStrategy = .custom {
            let value = try String(from: $0)
            if value == "null" {
                return NSNumber(value: 233)
            }
            throw DecodingError.dataCorrupted(.init(codingPath: $0.codingPath, debugDescription: ""))
        }
        XCTAssertEqual(try def.decode(Int.self, from: "null"), 233)
        XCTAssertThrowsError(try def.decode(Int.self, from: "0x1234"))
        def.nonConformingNumberDecodingStrategy = .convertFromString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan")
        XCTAssertEqual(try def.decode(Double.self, from: "inf"), .infinity)
        XCTAssertEqual(try def.decode(Double.self, from: "-inf"), -.infinity)
        XCTAssertEqual(try def.decode(Double.self, from: "nan").description, "nan")
        XCTAssertEqual(try def.decode(Double.self, from: "123.456"), 123.456)
        XCTAssertThrowsError(try def.decode(Int.self, from: "0x1234"))
    }
    
    func testUnkeyedContainer() {
        struct R: Decodable {
            var s: [String]
            init(from decoder: Decoder) throws {
                var c = try decoder.unkeyedContainer()
                if try c.decodeNil() || c.isAtEnd {
                    throw DecodingError.dataCorrupted(.init(codingPath: c.codingPath, debugDescription: "md"))
                }
                self.s = [
                    try c.decode(Int.self).description,
                    try c.decode(Int8.self).description,
                    try c.decode(Int16.self).description,
                    try c.decode(Int32.self).description,
                    try c.decode(Int64.self).description,
                    try c.decode(UInt.self).description,
                    try c.decode(UInt8.self).description,
                    try c.decode(UInt16.self).description,
                    try c.decode(UInt32.self).description,
                    try c.decode(UInt64.self).description,
                    try c.decode(Float.self).description,
                    try c.decode(Double.self).description,
                    try c.decode(Bool.self).description,
                    try c.decode(String.self)
                ]
            }
        }
        let av = NSNumber(value: Int64.max)
        let iv = NSNumber(value: Int64.min)
        
        XCTAssertEqual(try def.decode(R.self, from: [av,av,av,av,av,av,av,av,av,av,av,av,av,av]).s, ["9223372036854775807","-1","-1","-1","9223372036854775807", "9223372036854775807","255","65535","4294967295","9223372036854775807","9.223372e+18","9.223372036854776e+18","true","9223372036854775807"])
        XCTAssertEqual(try def.decode(R.self, from: [iv,iv,iv,iv,iv,iv,iv,iv,iv,iv,iv,iv,iv,iv]).s, ["-9223372036854775808","0","0","0","-9223372036854775808", "9223372036854775808","0","0","0","9223372036854775808","-9.223372e+18","-9.223372036854776e+18","true","-9223372036854775808"])
    }
    
    func testJSONOptoins() {
        struct R: Decodable {
            let z: Int
        }
        let def = JSONDecoderEx()
        XCTAssertEqual(try def.decode(Int.self, from: "1".data(using: .utf8)!), 1)
        guard #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) else {
            return
        }
        def.allowsJSON5 = true
        XCTAssertEqual(try def.decode(R.self, from: "{z:1}".data(using: .utf8)!).z, 1)
        XCTAssertEqual(try def.decode(R.self, from: "{\"z\":1}".data(using: .utf8)!).z, 1)
        def.assumesTopLevelDictionary = true
        XCTAssertThrowsError(try def.decode(Int.self, from: "1".data(using: .utf8)!))
    }
    
    func testDemo() {
        let j = """
                {
                "a1":1,"b0":true,"b1":"1","b2":1.2,"c0":1.99999999999999998123,"c1":1.99999999999999998123,"d2":[[1,2],[3,4]],"d3":"1.99999999999999998123",
                "e2":1,
                "e3":true,
                "f0":6,
                "f1":"Nwo=",
                "f2":"https://baidu.com",
                "y0":0.03500000000000000,
                "y3":{"1":2},
                "y4":{"1":2},
                "y5":{"1":2},
                "z1":[
                {"a":1,"b":"2","c":3,"d":true,"e":5.1,"f":"6","g":"Nwo=","h":8,"i":[9],"j":{"a":1},"k":[true,2,"3",4.0,-5.2],"l":"true"}
                ],
                }
                """
                //"z3": "infinity"
        let d = JSONDecoderEx()
        d.dateDecodingStrategy = .secondsSince1970
        //d.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "infinity", negativeInfinity: "-infinity", nan: "nan")
        //d.nonOptionalDecodingStrategy = .throw
        do {
            let o = try d.decode(Demo.self, from: j.data(using: .utf8)!)
            XCTAssertEqual(o.a1, true)
            XCTAssertEqual(o.b0, 1)
            XCTAssertEqual(o.b1, 1)
            XCTAssertEqual(o.b2, 1)
            XCTAssertEqual(o.b3, 0)
            XCTAssertEqual(o.b4, 0)
            XCTAssertEqual(o.b5, 0)
            XCTAssertEqual(o.b6, 0)
            XCTAssertEqual(o.b7, 0)
            XCTAssertEqual(o.b8, 0)
            XCTAssertEqual(o.b9, 0)
            XCTAssertEqual(o.c0, 2.0)
            XCTAssertEqual(o.c1, 2.0)
            XCTAssertEqual(o.c2, 0.0)
            XCTAssertEqual(o.c3, 0.0)
            XCTAssertEqual(o.d0, .zero)
            XCTAssertEqual(o.d1, .zero)
            XCTAssertEqual(o.d2, .init(x: 1, y: 2, width: 3, height: 4))
            XCTAssertEqual(o.d3.description, "1.99999999999999998123")
            XCTAssertEqual(o.e0, "")
            XCTAssertEqual(o.e1, nil)
            XCTAssertEqual(o.e2, "1")
            XCTAssertEqual(o.e3, "1")
            XCTAssertEqual(o.f0, .init(timeIntervalSince1970: 6))
            XCTAssertEqual((o.f1 as NSData).description, "{length = 2, bytes = 0x370a}")
            XCTAssertEqual(o.f2?.relativeString, "https://baidu.com")
            XCTAssertEqual(o.y0, 0.035)
            XCTAssertEqual(o.y1, [])
            XCTAssertEqual(o.y2, [:])
            XCTAssertEqual(o.y3, [1:2.0])
            XCTAssertEqual(o.y4, ["1":2.0])
            XCTAssertEqual(o.y5, [1:.init(timeIntervalSince1970: 2)])
            XCTAssertEqual(o.z2.o, "i2")
            XCTAssertEqual(o.z2.k, 2)
            XCTAssertEqual(o.z3, 0)
            XCTAssertEqual(o.z4, 0)
            //print("json:\n\(j)\nto:\n\(o)")
        } catch {
            XCTAssertTrue(false)
            //print(error)
        }
    }
}
 
