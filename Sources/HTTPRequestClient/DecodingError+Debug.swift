import Foundation

extension DecodingError {
  public func debugDescription<T>(for type: T.Type) -> String {
    switch self {
    case .dataCorrupted(let context):
      return
        "\(context.debugDescription) Path: \(context.codingPath.map(\.stringValue).joined(separator: "."))"

    case .keyNotFound(let key, let context):
      let path = context.codingPath.map(\.stringValue) + [key.stringValue]
      return
        "Value required for '\(String(describing: type)).\(path.joined(separator: "."))' but it was missing."

    case .typeMismatch(let type, let context):
      return "Type mismatch: \(type) required for key \(context.codingPath.description)."

    case .valueNotFound(let type, let context):
      return "Value Required: \(type) required for key \(context.codingPath.description)."

    default:
      return localizedDescription
    }
  }
}
