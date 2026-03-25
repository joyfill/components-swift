func properties(context: Context, properties: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let instance = instance as? [String: Any] else {
    return AnySequence(EmptyCollection())
  }

  guard let properties = properties as? [String: Any] else {
    return AnySequence(EmptyCollection())
  }

  // Fast path: stop at first failing property (used during anyOf / not probes).
  if !context.collectAllErrors {
    for (key, value) in instance {
      guard let propSchema = properties[key] else { continue }
      context.instanceLocation.push(key)
      let result = try context.descend(instance: value, subschema: propSchema)
      context.instanceLocation.pop()
      if !result.isValid {
        return result
      }
    }
    return AnySequence(EmptyCollection())
  }

  return try AnySequence(instance.map { (key, value) throws -> AnySequence<ValidationError> in
    if let schema = properties[key] {
      context.instanceLocation.push(key)
      defer { context.instanceLocation.pop() }
      return try context.descend(instance: value, subschema: schema)
    }

    return AnySequence(EmptyCollection())
  }.joined())
}
