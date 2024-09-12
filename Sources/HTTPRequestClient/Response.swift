import Foundation

public struct Response<Value, ServerError>
where Value: Decodable, ServerError: Swift.Error & Decodable {
  public let requestID: UUID
  public let body: Result<Value, ServerError>
  public let response: HTTPURLResponse

  public init(
    value: Value,
    response: HTTPURLResponse,
    requestID: UUID
  ) {
    self.body = .success(value)
    self.response = response
    self.requestID = requestID
  }

  public init(
    error: ServerError,
    response: HTTPURLResponse,
    requestID: UUID
  ) {
    self.body = .failure(error)
    self.response = response
    self.requestID = requestID
  }

  public var value: Value? {
    guard case let .success(value) = body else { return nil }
    return value
  }

  public var error: ServerError? {
    guard case let .failure(error) = body else { return nil }
    return error
  }
}

public struct SuccessResponse<Value> where Value: Decodable {
  public let requestID: UUID
  public let value: Value
  public let response: HTTPURLResponse

  public init(
    value: Value,
    response: HTTPURLResponse,
    requestID: UUID
  ) {
    self.value = value
    self.response = response
    self.requestID = requestID
  }
}
