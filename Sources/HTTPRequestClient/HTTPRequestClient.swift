import Dependencies
import DependenciesMacros
import Foundation
import HTTPRequestBuilder

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

@DependencyClient
public struct HTTPRequestClient: Sendable {
  public let send:
    @Sendable (
      URLRequest,
      URLSession
    ) async throws -> (Data, HTTPURLResponse, UUID)
}

extension HTTPRequestClient {
  public func send(
    _ request: URLRequest,
    urlSession: URLSession = .shared
  ) async throws -> (Data, HTTPURLResponse, UUID) {
    try await send(request, urlSession)
  }

  public func send(
    _ request: Request,
    baseURL: String,
    urlSession: URLSession = .shared,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
    timeoutInterval: TimeInterval = 60
  ) async throws -> (Data, HTTPURLResponse, UUID) {
    try await send(
      request.urlRequest(
        baseURL: baseURL,
        cachePolicy: cachePolicy,
        timeoutInterval: timeoutInterval
      ),
      urlSession
    )
  }

  public func send<Success, Failure>(
    _ request: URLRequest,
    decoder: JSONDecoder = .init(),
    urlSession: URLSession = .shared
  ) async throws -> Result<Success, Failure>
  where
    Success: Decodable,
    Failure: Decodable
  {
    let (data, response, requestID) = try await send(
      request,
      urlSession
    )

    var errorContainer = Error.invalidHTTPResponse(requestID)

    switch response.statusCode {
    case 200..<300:
      if Success.self is EmptyResponse.Type {
        return .success(EmptyResponse() as! Success)
      }

      do {
        return try .success(decoder.decode(Success.self, from: data))
      } catch let error as DecodingError {
        errorContainer = .decodingError(requestID, error)
        return .failure(try decoder.decode(Failure.self, from: data))
      } catch {
        switch errorContainer {
        case .decodingError: break
        default: errorContainer = .other(requestID, error)
        }

        throw errorContainer
      }

    default:
      errorContainer = .badResponse(
        requestID,
        response.statusCode,
        String(data: data, encoding: .utf8) ?? ""
      )

      throw errorContainer
    }
  }

  public func send<T>(
    _ request: URLRequest,
    decoder: JSONDecoder = .init(),
    urlSession: URLSession = .shared
  ) async throws -> T
  where T: Decodable {
    let (data, response, requestID) = try await send(
      request,
      urlSession
    )

    var errorContainer = Error.invalidHTTPResponse(requestID)

    switch response.statusCode {
    case 200..<300:
      if T.self is EmptyResponse.Type {
        return EmptyResponse() as! T
      }

      do {
        return try decoder.decode(T.self, from: data)
      } catch let error as DecodingError {
        errorContainer = .decodingError(requestID, error)
        throw errorContainer
      } catch {
        errorContainer = .other(requestID, error)
        throw errorContainer
      }

    default:
      errorContainer = .badResponse(
        requestID,
        response.statusCode,
        String(data: data, encoding: .utf8) ?? ""
      )

      throw errorContainer
    }
  }

  public func send<Success, Failure>(
    _ request: Request,
    baseURL: String,
    urlSession: URLSession = .shared,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
    timeoutInterval: TimeInterval = 60
  ) async throws -> Result<Success, Failure>
  where
    Success: Decodable,
    Failure: Decodable
  {
    try await send(
      request.urlRequest(
        baseURL: baseURL,
        cachePolicy: cachePolicy,
        timeoutInterval: timeoutInterval
      ),
      urlSession: urlSession
    )
  }

  public func send<T>(
    _ request: Request,
    baseURL: String,
    decoder: JSONDecoder = .init(),
    urlSession: URLSession = .shared,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
    timeoutInterval: TimeInterval = 60
  ) async throws -> T
  where T: Decodable {
    try await send(
      request.urlRequest(
        baseURL: baseURL,
        cachePolicy: cachePolicy,
        timeoutInterval: timeoutInterval
      ),
      decoder: decoder,
      urlSession: urlSession
    )
  }
}

extension DependencyValues {
  public var httpRequestClient: HTTPRequestClient {
    get { self[HTTPRequestClient.self] }
    set { self[HTTPRequestClient.self] = newValue }
  }
}

extension HTTPRequestClient: DependencyKey {
  public static let liveValue = Self(
    send: { request, session in
      let id = UUID()

      do {
        let (data, response) = try await session.data(for: request)

        guard
          let httpResponse = response as? HTTPURLResponse
        else {
          throw HTTPRequestClient.Error.invalidHTTPResponse(id)
        }

        return (data, httpResponse, id)
      } catch {
        throw Error.other(id, error)
      }
    }
  )
}

extension HTTPRequestClient: TestDependencyKey {
  public static let previewValue = Self(
    send: { _, _ in
      (Data(), HTTPURLResponse(), UUID())
    }
  )
}

extension HTTPRequestClient {
  public enum Error: Swift.Error {
    case invalidHTTPResponse(UUID)
    case badResponse(UUID, Int, String)
    case decodingError(UUID, DecodingError)
    case other(UUID, Swift.Error)
  }
}
