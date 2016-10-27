//
// Stream_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 21/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

public class Stream_Tests: XCTestCase {

	func testStreams () {
		let (writer,reader) = streams()

		writer.write("one")
		XCTAssertEqual(reader.readSome(), "one")

		writer.writeln()
		writer.writeln("two")
		XCTAssertEqual(reader.readSome(), "\ntwo\n")

		writer.write("three")
		writer.close()
		XCTAssertEqual(reader.read(), "three")
	}

	func testReadableStreamRun () {
		let (writer,reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.run("cat"), "one")
	}

	func testReadableStreamRunAsync () {
		let (writer,reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.runAsync("cat").stdout.read(), "one")
	}

	func testPrintStream () {
		let (writer,reader) = streams()
		writer.write("one")
		writer.close()

		var string = ""
		print(reader, to: &string)
		
		XCTAssertEqual(string, "one\n")
	}

	func testPrintToStream () {
		var (writer,reader) = streams()

		print("one", to: &writer)

		XCTAssertEqual(reader.readSome(), "one\n")
	}

#if os(macOS)
	func testOnOutput () {
		let (writer,reader) = streams()

		let expectoutput = expectation(description: "onOutput will be called when output is available")
		reader.onOutput { stream in
			if stream.readSome() != nil {
				expectoutput.fulfill()
			}
		}
		writer.writeln()
		waitForExpectations(timeout: 0.5, handler: nil)
	}

	func testOnStringOutput () {
		let (writer,reader) = streams()

		let expectoutput = expectation(description: "onOutput will be called when output is available")
		reader.onStringOutput { string in
			XCTAssertEqual(string, "hi")
			expectoutput.fulfill()
		}
		writer.write("hi")
		waitForExpectations(timeout: 0.5, handler: nil)
	}

	func testFoundationWriteabilityHandlerBeingCalledWhenNoInputIsAskedFor () {
		let process = Process()
		let inputpipe = Pipe()
		var i = 0
		inputpipe.fileHandleForWriting.writeabilityHandler = { filehandle in
			i += 1
			print("writeabilityHandler called",i,"times.")
		}
		process.standardInput = inputpipe

		let outputpipe = Pipe()
		process.standardOutput = outputpipe

		process.launchPath = "/bin/echo"
		process.arguments = ["hi"]

		process.launch()
		process.waitUntilExit()

		XCTAssertEqual(outputpipe.fileHandleForReading.read(), "hi\n")
		XCTAssertEqual(i, 0)
	}

	func testOnInput () {
		var context = ShellContext()
		let (writer,reader) = streams()
		context.stdin = reader

		let expectoutput = expectation(description: "onInput will be called when input is available")
		writer.onInput { writer in
			writer.writeln("onInput is working")
			writer.onInput(handler: nil)
			expectoutput.fulfill()
		}
		let command = context.runAsync(bash: "read answer; echo \"$answer\"")
		XCTAssertEqual(command.stdout.read(), "onInput is working\n")
		waitForExpectations(timeout: 0.5, handler: nil)
	}
#endif
}

extension Stream_Tests {
	public static var allTests = [
		("testStreams", testStreams),
		("testReadableStreamRun", testReadableStreamRun),
		("testReadableStreamRunAsync", testReadableStreamRunAsync),
		("testPrintStream", testPrintStream),
		("testPrintToStream", testPrintToStream),
		//("testOnOutput", testOnOutput),
		//("testOnStringOutput", testOnStringOutput),
		]
}
