func not(context: JSONSchemaContext, not: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  // Use fast mode: we only need to know whether the subschema matches, not why.
  let saved = context.collectAllErrors
  context.collectAllErrors = false
  defer { context.collectAllErrors = saved }

  guard try context.descend(instance: instance, subschema: not).isValid else {
    return AnySequence(EmptyCollection())
  }

  return AnySequence([
    ValidationError(
      "'\(instance)' does not match 'not' validation.",
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}
