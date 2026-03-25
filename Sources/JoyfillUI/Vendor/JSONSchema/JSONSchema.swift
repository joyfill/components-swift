import Foundation


public enum Type: Swift.String {
  case object = "object"
  case array = "array"
  case string = "string"
  case integer = "integer"
  case number = "number"
  case boolean = "boolean"
  case null = "null"
}


extension String {
  func stringByRemovingPrefix(_ prefix: String) -> String? {
    if hasPrefix(prefix) {
      let index = self.index(startIndex, offsetBy: prefix.count)
      return String(self[index...])
    }

    return nil
  }
}


public struct JSONSchemaDefinition {
  public let title: String?
  public let description: String?

  public let type: [Type]?

  let schema: [String: Any]

  public init(_ schema: [String: Any]) {
    title = schema["title"] as? String
    description = schema["description"] as? String

    if let type = schema["type"] as? String {
      if let type = Type(rawValue: type) {
        self.type = [type]
      } else {
        self.type = []
      }
    } else if let types = schema["type"] as? [String] {
      self.type = types.map { Type(rawValue: $0) }.filter { $0 != nil }.map { $0! }
    } else {
      self.type = []
    }

    self.schema = schema
  }

  public func validate(_ data: Any) throws -> ValidationResult {
    let validator = try validator(for: schema)
    return try validator.validate(instance: data)
  }

  public func validate(_ data: Any) throws -> AnySequence<ValidationError> {
    let validator = try validator(for: schema)
    return try validator.validate(instance: data)
  }
}

// Module-level validator cache keyed by a lightweight fingerprint.
// The JoyFill SDK always validates the same schema structure, so rebuilding
// the validator (which re-parses all $defs and metaschemas) on every call
// is pure overhead.
private var _cachedValidatorFingerprint: (Int, String, Int)? = nil
private var _cachedValidator: (any Validator)? = nil

func validator(for schema: [String: Any]) throws -> any Validator {
  // Fingerprint: (key count, $schema URI, $defs count).
  // Cheap to compute and unique enough for the JoyFill use-case.
  let uri = schema["$schema"] as? String ?? ""
  let defCount = (schema["$defs"] as? [String: Any])?.count ?? 0
  let fingerprint = (schema.count, uri, defCount)

  if let cachedFP = _cachedValidatorFingerprint,
     let cached = _cachedValidator,
     cachedFP == fingerprint {
    return cached
  }

  let result: any Validator

  guard schema.keys.contains("$schema") else {
    result = Draft202012Validator(schema: schema)
    _cachedValidatorFingerprint = fingerprint
    _cachedValidator = result
    return result
  }

  guard let schemaURI = schema["$schema"] as? String else {
    throw ReferenceError.notFound
  }

  if let id = DRAFT_2020_12_META_SCHEMA["$id"] as? String, urlEqual(schemaURI, id) {
    result = Draft202012Validator(schema: schema)
  } else if let id = DRAFT_2019_09_META_SCHEMA["$id"] as? String, urlEqual(schemaURI, id) {
    result = Draft201909Validator(schema: schema)
  } else if let id = DRAFT_07_META_SCHEMA["$id"] as? String, urlEqual(schemaURI, id) {
    result = Draft7Validator(schema: schema)
  } else if let id = DRAFT_06_META_SCHEMA["$id"] as? String, urlEqual(schemaURI, id) {
    result = Draft6Validator(schema: schema)
  } else if let id = DRAFT_04_META_SCHEMA["id"] as? String, urlEqual(schemaURI, id) {
    result = Draft4Validator(schema: schema)
  } else {
    throw ReferenceError.notFound
  }

  _cachedValidatorFingerprint = fingerprint
  _cachedValidator = result
  return result
}


public func validate(_ value: Any, schema: [String: Any]) throws -> ValidationResult {
  return try validator(for: schema).validate(instance: value)
}


public func validate(_ value: Any, schema: Bool) throws -> ValidationResult {
  let validator = Draft4Validator(schema: schema)
  return try validator.validate(instance: value)
}
