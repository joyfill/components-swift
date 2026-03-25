func allOf(context: JSONSchemaContext, allOf: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let allOf = allOf as? [Any] else {
    return AnySequence(EmptyCollection())
  }

  // Fast path: stop at first failing subschema.
  if !context.collectAllErrors {
    for subschema in allOf {
      let result = try context.descend(instance: instance, subschema: subschema)
      if !result.isValid { return result }
    }
    return AnySequence(EmptyCollection())
  }

  return try AnySequence(allOf.map({
    try context.descend(instance: instance, subschema: $0)
  }).joined())
}
