// CGVectorExtensions.swift - Copyright 2023 SwifterSwift

#if canImport(CoreGraphics)
import CoreGraphics
import simd

// MARK: - Properties

nonisolated public extension CGVector {
    /// SwifterSwift: The angle of rotation (in radians) of the vector. The range of the angle is -π to π; an angle of 0
    /// points to the right.
    ///
    /// https://en.wikipedia.org/wiki/Atan2
    var angleSigned: CGFloat {
        return atan2(dy, dx)
    }

    /// SwifterSwift: The magnitude (or length) of the vector.
    ///
    /// https://en.wikipedia.org/wiki/Euclidean_vector#Length
    var magnitude: CGFloat {
        return sqrt((dx * dx) + (dy * dy))
    }
    
    var normalized: CGVector {
        .init(dx: dx / magnitude, dy: dy / magnitude)
    }
}

// MARK: - Initializers

public extension CGVector {
    /// SwifterSwift: Creates a vector with the given magnitude and angle.
    ///
    ///     let vector = CGVector(angle: .pi, magnitude: 1)
    ///
    /// - Parameters:
    ///     - angle: The angle of rotation (in radians) counterclockwise from the positive x-axis.
    ///     - magnitude: The length of the vector.
    ///
    init(angleSigned: CGFloat, magnitude: CGFloat) {
        // https://www.grc.nasa.gov/WWW/K-12/airplane/vectpart.html
        self.init(dx: magnitude * cos(angleSigned), dy: magnitude * sin(angleSigned))
    }
    
    init(start: CGPoint, end: CGPoint) {
        let diff = end - start
        self.init(dx: diff.x, dy: diff.y)
    }
}

// MARK: - Operators

public extension CGVector {
    /// SwifterSwift: Multiplies a scalar and a vector (commutative).
    ///
    ///     let vector = CGVector(dx: 1, dy: 1)
    ///     let largerVector = vector * 2
    ///
    /// - Parameters:
    ///   - vector: The vector to be multiplied.
    ///   - scalar: The scale by which the vector will be multiplied.
    /// - Returns: The vector with its magnitude scaled.
    static func * (vector: CGVector, scalar: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
    }

    /// SwifterSwift: Multiplies a scalar and a vector (commutative).
    ///
    ///     let vector = CGVector(dx: 1, dy: 1)
    ///     let largerVector = 2 * vector
    ///
    /// - Parameters:
    ///   - scalar: The scalar by which the vector will be multiplied.
    ///   - vector: The vector to be multiplied.
    /// - Returns: The vector with its magnitude scaled.
    static func * (scalar: CGFloat, vector: CGVector) -> CGVector {
        return CGVector(dx: scalar * vector.dx, dy: scalar * vector.dy)
    }

    /// SwifterSwift: Compound assignment operator for vector-scalar multiplication.
    ///
    ///     var vector = CGVector(dx: 1, dy: 1)
    ///     vector *= 2
    ///
    /// - Parameters:
    ///   - vector: The vector to be multiplied.
    ///   - scalar: The scale by which the vector will be multiplied.
    static func *= (vector: inout CGVector, scalar: CGFloat) {
        vector.dx *= scalar
        vector.dy *= scalar
    }

    /// SwifterSwift: Negates the vector. The direction is reversed, but magnitude remains the same.
    ///
    ///     let vector = CGVector(dx: 1, dy: 1)
    ///     let reversedVector = -vector
    ///
    /// - Parameter vector: The vector to be negated.
    /// - Returns: The negated vector.
    static prefix func - (vector: CGVector) -> CGVector {
        return CGVector(dx: -vector.dx, dy: -vector.dy)
    }
    
    
    //positive value - for counterclockwise rotation from vector1 to vector2
    static func angleSigned(vector1: CGVector, vector2: CGVector) -> CGFloat {
        if (vector1.magnitude == 0 || vector2.magnitude == 0) {
            return 0
        }
        
        let dot = vector1.dx * vector2.dx + vector1.dy * vector2.dy
        let angle = acos(dot / (vector1.magnitude * vector2.magnitude))
        
        //rotation direction
        let crossProduct = simd_cross(float3(Float(vector1.dx), Float(vector1.dy), 0),
            float3(Float(vector2.dx), Float(vector2.dy), 0))
        let rotationDirection = crossProduct.z > 0 ? 1.0 : -1.0
        
        return angle * rotationDirection
    }
    
    //collinear means that angle = 0 or 180
    static func collinear(vector1: CGVector, vector2: CGVector, angleEpsilon: CGFloat) -> Bool {
        let angle = CGVector.angleSigned(vector1: vector1, vector2: vector2)
        if (abs(angle) <= angleEpsilon || abs(abs(angle) - Double.pi) <= angleEpsilon ) {
            return true
        }
        return false
    }
}

#endif
