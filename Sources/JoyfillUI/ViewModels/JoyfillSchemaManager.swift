//
//  JoyfillSchemaManager.swift
//  Joyfill
//
//  Created by Vishnu Dutt on 16/07/25.
//
import JoyfillModel
import JSONSchema
import Foundation

public class JoyfillSchemaManager {
    
    public init() {}

    // MARK: - Public API
    
    /// Validates JoyDoc schema and version compatibility
    /// - Parameter document: The JoyDoc to validate
    /// - Returns: nil if validation passes, error object if validation fails
    public func validateSchema(document: JoyDoc) -> SchemaValidationError? {
        // Phase 2: Version Validation (check first to prevent processing unsupported versions)
        if let versionError = validateVersion(document: document) {
            return SchemaValidationError(
                code: "ERROR_SCHEMA_VERSION",
                message: versionError.message,
                error: nil,
                details: .init(
                    schemaVersion: versionError.details.schemaVersion,
                    sdkVersion: versionError.details.sdkVersion
                )
            )
        }
        
        // Phase 1: JSON Schema Validation
        return performJSONSchemaValidation(document: document)
    }
    
    /// Internal validation that returns Result type for SDK use
    internal func validateSchemaInternal(document: JoyDoc) -> Result<JoyDoc, JoyfillError> {
        if let error = validateSchema(document: document) {
            return .failure(.schemaValidationError(error: error))
        }
        return .success(document)
    }
    
    // MARK: - Version Validation (Phase 2)
    
    private func validateVersion(document: JoyDoc) -> SchemaValidationError? {
        let documentVersion = document.version
        let detectedVersion = documentVersion ?? "1.0.0" // Undefined version = v1.x.x
        
        // Parse major version from version string
        guard let majorVersion = extractMajorVersion(from: detectedVersion), let supportedMajorVersion = extractMajorVersion(from: currentSchemaVersion())  else {
            return SchemaValidationError(
                code: "ERROR_SCHEMA_VERSION",
                message: "Error detected with targeted schema version", error: nil,
                details: .init(
                    schemaVersion: currentSchemaVersion(),
                    sdkVersion: sdkVersion
                )
            )
        }
        
        // Check if major version is supported
        if majorVersion > supportedMajorVersion {
            return SchemaValidationError(
                code: "ERROR_SCHEMA_VERSION",
                message: "Unsupported JoyDoc version detected. This SDK supports v\(supportedMajorVersion).x.x, but document version is v\(detectedVersion)", error: nil,
                details: .init(
                    schemaVersion: currentSchemaVersion(),
                    sdkVersion: sdkVersion
                )
            )
        }
        
        return nil
    }
    
    private func extractMajorVersion(from versionString: String) -> Int? {
        // Handle version strings like "1.2.3" or "2.0.0"
        let components = versionString.components(separatedBy: ".")
        guard let firstComponent = components.first, 
              let majorVersion = Int(firstComponent) else {
            // If we can't parse, assume v1 for backward compatibility
            return nil
        }
        return majorVersion
    }
    
    // MARK: - JSON Schema Validation (Phase 1)
    
    private func performJSONSchemaValidation(document: JoyDoc) -> SchemaValidationError? {
        guard let schemaData = getCurrentSchema().data(using: .utf8),
              let schemaDict = try? JSONSerialization.jsonObject(with: schemaData, options: []) as? [String: Any] else {
            Log("Failed to parse embedded schema", type: .error)
            return SchemaValidationError(
                code: "ERROR_SCHEMA_VALIDATION",
                message: "Unable to load embedded schema",
                error: nil,
                details: .init(schemaVersion: currentSchemaVersion(), sdkVersion: sdkVersion)
            )
        }
        
        do {
            let validationResult = try JSONSchema.validate(document.dictionary, schema: schemaDict)
            if validationResult.valid {
                // Validation succeeded - return nil (no error)
                return nil
            } else {
                // Validation failed - return error
                return SchemaValidationError(
                    code: "ERROR_SCHEMA_VALIDATION",
                    message: "Error detected during schema validation",
                    error: validationResult.errors,
                    details: .init(
                        schemaVersion: getSchemaVersion(from: schemaDict),
                        sdkVersion: sdkVersion
                    )
                )
            }
        } catch {
            return SchemaValidationError(
                code: "ERROR_SCHEMA_VALIDATION",
                message: "Error detected during schema validation: \(error.localizedDescription)",
                error: nil,
                details: .init(
                    schemaVersion: currentSchemaVersion(),
                    sdkVersion: sdkVersion
                )
            )
        }
    }
    
    private func getSchemaVersion(from schemaDict: [String: Any]) -> String {
        return schemaDict["$joyfillSchemaVersion"] as? String ?? "Null"
    }

    private func currentSchemaVersion() -> String {
        guard let data = getCurrentSchema().data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return "Null"
        }
        return getSchemaVersion(from: dict)
    }
}
