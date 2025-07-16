//
//  JoyfillSchemaManager.swift
//  Joyfill
//
//  Created by Vishnu Dutt on 16/07/25.
//
import JoyfillModel
import JSONSchema
import Foundation

class JoyfillSchemaManager {

    public func validateSchema(document: JoyDoc) -> Result<JoyDoc, SchemaValidationError> {
        guard let schemaData = joyfillSchema.data(using: .utf8),
              let schemaDict = try? JSONSerialization.jsonObject(with: schemaData, options: []) as? [String: Any] else {
            Log("Failed to parse embedded schema", type: .error)
            return .failure(SchemaValidationError(
                code: "ERROR_SCHEMA_VALIDATION",
                message: "Unable to load embedded schema",
                error: nil,
                details: .init(schemaVersion: "embedded", sdkVersion: "1.0.0")
            ))
        }
        do {
            let validationResult = try JSONSchema.validate(document.dictionary, schema: schemaDict)
            if validationResult.valid {
                return .failure(SchemaValidationError(
                    code: "SUCCESS",
                    message: "Schema validation succeeded",
                    error: nil,
                    details: .init(
                        schemaVersion: "",
                        sdkVersion: "1.0.0"
                    )
                ))
            } else {
                return .failure(SchemaValidationError(
                    code: "ERROR_SCHEMA_VALIDATION",
                    message: "Error detected during schema validation",
                    error: validationResult.errors,
                    details: .init(
                        schemaVersion: "",
                        sdkVersion: "1.0.0"
                    ))
                )
            }
        } catch {
            return .failure(SchemaValidationError(
                code: "ERROR_SCHEMA_VALIDATION",
                message: "Error detected during schema validation: \(error.localizedDescription)",
                error: nil,
                details: .init(
                    schemaVersion: "unknown",
                    sdkVersion: "1.0.0"
                )
            ))
        }
    }
}
