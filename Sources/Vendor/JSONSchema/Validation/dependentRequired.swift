func dependentRequired(context: Context, dependentRequired: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let instance = instance as? [String: Any] else {
    return AnySequence(EmptyCollection())
  }

  guard let dependentRequired = dependentRequired as? [String: [String]] else {
    return AnySequence(EmptyCollection())
  }

  return try AnySequence(dependentRequired.compactMap({ (key, requiredKeys) -> AnySequence<ValidationError> in
    if instance.keys.contains(key) {
      return try required(context: context, required: requiredKeys, instance: instance, schema: schema)
    }

    return AnySequence(EmptyCollection())
  }).joined())
}
