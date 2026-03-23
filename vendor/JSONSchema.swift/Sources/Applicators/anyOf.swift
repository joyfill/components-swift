func anyOf(context: Context, anyOf: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let anyOf = anyOf as? [Any] else {
    return AnySequence(EmptyCollection())
  }

  // Use fast mode: we only need the first error per alternative to know it's invalid.
  let saved = context.collectAllErrors
  context.collectAllErrors = false
  defer { context.collectAllErrors = saved }

  if try !anyOf.contains(where: { try context.descend(instance: instance, subschema: $0).isValid }) {
    return AnySequence([
      ValidationError(
        "\(instance) does not meet anyOf validation rules.",
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      ),
    ])
  }

  return AnySequence(EmptyCollection())
}
