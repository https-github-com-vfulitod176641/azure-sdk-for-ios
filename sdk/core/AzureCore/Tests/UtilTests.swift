// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

@testable import AzureCore
import XCTest

class UtilTests: XCTestCase {
    func test_RegexUtil_WithMatchingString_ReturnsMatch() {
        let regex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
        let goodString = "application/json"

        // test a good string
        let result = regex.firstMatch(in: goodString)
        XCTAssertTrue(regex.hasMatch(in: goodString))
        XCTAssertEqual(result, goodString)
    }

    func test_RegexUtil_WithNonMatchingString_ReturnsNil() {
        let regex = NSRegularExpression("^(application|text)/([0-9a-z+.]+)?json$")
        let badString = "application/xml"

        // test a bad string
        XCTAssertFalse(regex.hasMatch(in: badString))
        XCTAssertNil(regex.firstMatch(in: badString))
    }

    func test_DateUtil_WithRFC1123String_ConvertsToDate() {
        let rfc1123String = "Thu, 02 Jan 2020 07:12:34 GMT"
        let date = Date(rfc1123String, format: .rfc1123)

        // ensure date string can be round-tripped
        XCTAssertNotNil(date)
        XCTAssertEqual(String(describing: date!, format: .rfc1123), rfc1123String)

        // setup calendar
        let units = Set<Calendar.Component>([.day, .month, .year, .hour, .minute, .second, .timeZone])
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT")!

        // verify parses to correct components
        let dateComponents = calendar.dateComponents(units, from: date!)
        XCTAssertEqual(dateComponents.month, 1)
        XCTAssertEqual(dateComponents.day, 2)
        XCTAssertEqual(dateComponents.year, 2020)
        XCTAssertEqual(dateComponents.hour, 7)
        XCTAssertEqual(dateComponents.minute, 12)
        XCTAssertEqual(dateComponents.second, 34)
        XCTAssertEqual(dateComponents.timeZone, TimeZone(abbreviation: "GMT"))
    }

    func test_StringUtil_WithBoolString_OutputsBool() {
        let headers: HTTPHeaders = [
            "string": "test",
            "bool": "true"
        ]
        XCTAssertEqual(Bool(headers["bool"]), true)
    }

    func test_StringUtil_WithNonBoolString_OutputsNil() {
        let headers: HTTPHeaders = [
            "string": "test",
            "bool": "true"
        ]
        XCTAssertNil(Bool(headers["string"]))
    }

    func test_StringUtil_WithIntString_OutputsInt() {
        let headers: HTTPHeaders = [
            "bool": "true",
            "int": "22"
        ]
        XCTAssertEqual(Int(headers["int"]), 22)
    }

    func test_StringUtil_WithNonIntString_OutputsNil() {
        let headers: HTTPHeaders = [
            "bool": "true",
            "int": "22"
        ]
        XCTAssertNil(Int(headers["bool"]))
    }

    func test_StringUtil_WithEnumString_OutputsEnum() {
        let headers: HTTPHeaders = [
            "int": "22",
            "enum": "Accept"
        ]
        XCTAssertEqual(HTTPHeader(rawValue: headers["enum"]), HTTPHeader.accept)
    }

    func test_StringUtil_WithNonEnumString_OutputsNil() {
        let headers: HTTPHeaders = [
            "int": "22",
            "enum": "Accept"
        ]
        XCTAssertNil(HTTPHeader(rawValue: headers["int"]))
    }

    func test_StringUtil_WithRFC1123DateString_OutputsCorrectDate() {
        let dateString = "Thu, 02 Jan 2020 07:12:34 GMT"
        let date = DateComponents(
            calendar: Calendar(identifier: .iso8601),
            timeZone: TimeZone(abbreviation: "GMT"),
            year: 2020, month: 1, day: 2,
            hour: 7, minute: 12, second: 34
        ).date!

        let headers: HTTPHeaders = [
            "bool": "true",
            "date": dateString
        ]
        XCTAssertEqual(Date(headers["date"], format: .rfc1123), date)
    }

    func test_StringUtil_WithNonRFC1123DateString_OutputsNil() {
        let dateString = "Jan, 02 2020 07:12:34 GMT"
        let headers: HTTPHeaders = [
            "bool": "true",
            "date": dateString
        ]
        XCTAssertNil(Date(headers["bool"], format: .rfc1123))
    }
}
