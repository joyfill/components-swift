func required(context: Context, required: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let instance = instance as? [String: Any] else {
    return AnySequence(EmptyCollection())
  }

  guard let required = required as? [String] else {
    return AnySequence(EmptyCollection())
  }

  // Use O(1) dictionary lookup instead of O(N) `instance.keys.contains`.
  return AnySequence(required.compactMap { key -> ValidationError? in
    guard instance[key] == nil else { return nil }
    return ValidationError(
      "Required property '\(key)' is missing",
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  })
}
