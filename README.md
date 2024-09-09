# HTTPRequestClient

A dependency client that handles HTTP requests in apps using the Swift Composable Architecture (TCA).

## Usage

The library provides a `HTTPRequestClient` that has several helpers methods to handle sending requests and decoding the response.

```swift
public func send(
  _ request: URLRequest,
  urlSession: URLSession = .shared
) async throws -> (Data, HTTPURLResponse, UUID)

public func send<Success, Failure>(
    _ request: URLRequest,
    decoder: JSONDecoder = .init(),
    urlSession: URLSession = .shared
) async throws -> Result<Success, Failure> where Success: Decodable, Failure: Decodable

public func send<T>(
    _ request: URLRequest,
    decoder: JSONDecoder = .init(),
    urlSession: URLSession = .shared
) async throws -> T where T: Decodable
```

The above methods also have variants that support sending a `Request` type instance from the [HTTPRequestBuilder](https://github.com/4rays/http-request-builder) library.
For example:

```swift
public func send(
    _ request: Request,
    baseURL: String,
    urlSession: URLSession = .shared,
    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
    timeoutInterval: TimeInterval = 60
) async throws -> (Data, HTTPURLResponse, UUID)
```
