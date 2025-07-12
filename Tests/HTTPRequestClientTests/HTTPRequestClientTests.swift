import Testing
import Foundation
import Dependencies

@testable import HTTPRequestClient

struct HTTPRequestClientTests {
  struct TestResponse: Codable {
    let id: Int
    let name: String
  }

  struct TestError: Error, Codable {
    let message: String
  }

  @Test func testResponseSuccess() async throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!
    let requestID = UUID()
    let testData = TestResponse(id: 1, name: "Test")

    let result = Response<TestResponse, TestError>(
      value: testData,
      response: response,
      requestID: requestID
    )

    #expect(result.value?.id == 1)
    #expect(result.value?.name == "Test")
    #expect(result.error == nil)
    #expect(result.requestID == requestID)
  }

  @Test func testResponseError() async throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 400,
      httpVersion: nil,
      headerFields: nil
    )!
    let requestID = UUID()
    let testError = TestError(message: "Bad request")

    let result = Response<TestResponse, TestError>(
      error: testError,
      response: response,
      requestID: requestID
    )

    #expect(result.value == nil)
    #expect(result.error?.message == "Bad request")
    #expect(result.requestID == requestID)
  }

  @Test func testSuccessResponse() async throws {
    let response = HTTPURLResponse(
      url: URL(string: "https://example.com")!,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil
    )!
    let requestID = UUID()
    let testData = TestResponse(id: 42, name: "Success")

    let result = SuccessResponse<TestResponse>(
      value: testData,
      response: response,
      requestID: requestID
    )

    #expect(result.value.id == 42)
    #expect(result.value.name == "Success")
    #expect(result.requestID == requestID)
  }

  @Test func testEmptyResponse() async throws {
    let emptyResponse = EmptyResponse()
    #expect(type(of: emptyResponse) == EmptyResponse.self)
  }

  @Test func testHTTPRequestClientErrors() async throws {
    let requestID = UUID()
    
    let invalidResponse = HTTPRequestClient.Error.invalidHTTPResponse(requestID)
    let badResponse = HTTPRequestClient.Error.badResponse(requestID, 404, "Not found")
    _ = HTTPRequestClient.Error.decodingError(
      requestID, 
      DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test"))
    )
    _ = HTTPRequestClient.Error.other(requestID, NSError(domain: "test", code: 1))

    switch invalidResponse {
    case .invalidHTTPResponse(let id):
      #expect(id == requestID)
    default:
      #expect(Bool(false), "Should be invalidHTTPResponse")
    }
    
    switch badResponse {
    case .badResponse(let id, let statusCode, let message):
      #expect(id == requestID)
      #expect(statusCode == 404)
      #expect(message == "Not found")
    default:
      #expect(Bool(false), "Should be badResponse")
    }
  }

  @Test func testDependencyConfiguration() async throws {
    try await withDependencies {
      $0.httpRequestClient = .previewValue
    } operation: {
      @Dependency(\.httpRequestClient) var client
      let (data, _, requestID) = try await client.send(
        URLRequest(url: URL(string: "https://example.com")!),
        URLSession.shared
      )
      
      #expect(data.isEmpty)
      #expect(requestID != UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }
  }
}
