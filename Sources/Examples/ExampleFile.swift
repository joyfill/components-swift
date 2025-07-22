import Foundation
import JoyfillFormulas
import JoyfillModel

/// Examples class that provides sample formulas for testing and demonstration
public struct Examples {
    
    /// A collection of example formula strings
    public static let sampleFormulas = [
        "Basic Arithmetic": "1 + 2 * 3",
        "String Concatenation": "\"Hello \" + \"World\"",
        "Conditional": "IF(10 > 5, \"Yes\", \"No\")",
        "Sum Function": "SUM(1, 2, 3, 4, 5)",
        "Complex Formula": "IF(CONTAINS(\"Hello World\", \"World\"), UPPER(\"found it\"), \"not found\")"
    ]
    
    /// Provides documentation about the Examples module
    public static func getDescription() -> String {
        return """
        The Examples module provides sample formulas and test data 
        for the JoyfillFormulas system.
        """
    }
} 