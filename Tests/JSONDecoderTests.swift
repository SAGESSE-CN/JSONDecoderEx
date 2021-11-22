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
            static var unknown: Self {
                return .init()
            }
            var w: Int = 233
        }
        XCTAssertEqual(try def.decode(E<I>.self, from: [:]).w.w, 233)
    }
    
    func testCustomNumber() {
        let def = JSONDecoderEx()
        def.nonConformingNumberDecodingStrategy = .custom {
            let value = try String(from: $0)
            if value == "null" {
                return NSNumber(value: 233)
            }
            throw DecodingError.dataCorrupted(.init(codingPath: $0.codingPath, debugDescription: ""))
        }
        XCTAssertEqual(try def.decode(Int.self, from: "null"), 233)
        def.nonConformingNumberDecodingStrategy = .convertFromString(positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan")
        XCTAssertEqual(try def.decode(Double.self, from: "inf"), .infinity)
        XCTAssertEqual(try def.decode(Double.self, from: "-inf"), -.infinity)
        XCTAssertEqual(try def.decode(Double.self, from: "nan").description, "nan")
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
 
