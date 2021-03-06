import Darwin.C.math

/// A note in a twelve-tone equal temperament scale. https://en.wikipedia.org/wiki/Equal_temperament
enum ScaleNote: CaseIterable {
    case C, CSharp_DFlat, D, DSharp_EFlat, E, F, FSharp_GFlat, G, GSharp_AFlat, A, ASharp_BFlat, B

    /// A note match given an input frequency.
    struct Match {
        /// The matched note.
        let note: ScaleNote
        /// The octave of the matched note.
        let octave: Int
        /// The distance between the input frequency and the matched note's defined frequency.
        let distance: Distance

        /// The frequency of the matched note, adjusted by octave.
        var frequency: Frequency { note.frequency.shifted(byOctaves: octave) }
    }

    /// The distance between notes in cents: https://en.wikipedia.org/wiki/Cent_%28music%29
    struct Distance: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
        /// Underlying float value. Between -50 and +50.
        let cents: Float

        /// Humans can distinguish a difference in pitch of about 5–6 cents:
        /// https://en.wikipedia.org/wiki/Cent_%28music%29#Human_perception
        var isWithinTolerance: Bool { fabsf(cents) < 5 }

        init(cents: Float) {
            self.cents = cents
        }

        init(floatLiteral value: Float) {
            cents = value
        }

        init(integerLiteral value: Int) {
            cents = Float(value)
        }
    }

    /// Calculate distance to closest note.
    private func distance(to frequency: Frequency) -> Distance {
        return Distance(cents: 1200 * log2f(Float(frequency.measurement.value / self.frequency.measurement.value)))
    }

    /// Find the closest note to the specified frequency.
    ///
    /// - parameter frequency: The frequency to match against.
    ///
    /// - returns: The closest note match.
    static func closestNote(to frequency: Frequency) -> Match {
        // Shift frequency octave to be within range of scale note frequencies.
        var octaveShiftedFrequency = frequency

        while octaveShiftedFrequency > allCases.last!.frequency {
            octaveShiftedFrequency.shift(byOctaves: -1)
        }

        while octaveShiftedFrequency < allCases.first!.frequency {
            octaveShiftedFrequency.shift(byOctaves: 1)
        }

        // Find closest note
        let closestNote = allCases.min(by: { note1, note2 in
            fabsf(note1.distance(to: octaveShiftedFrequency).cents) <
                fabsf(note2.distance(to: octaveShiftedFrequency).cents)
        })!

        return Match(
            note: closestNote,
            octave: max(octaveShiftedFrequency.distanceInOctaves(to: frequency), 0),
            distance: closestNote.distance(to: octaveShiftedFrequency)
        )
    }

    /// The names for this note.
    var names: [String] {
        switch self {
        case .C:
            return ["C"]
        case .CSharp_DFlat:
            return ["C♯", "D♭"]
        case .D:
            return ["D"]
        case .DSharp_EFlat:
            return ["D♯", "E♭"]
        case .E:
            return ["E"]
        case .F:
            return ["F"]
        case .FSharp_GFlat:
            return ["F♯", "G♭"]
        case .G:
            return ["G"]
        case .GSharp_AFlat:
            return ["G♯", "A♭"]
        case .A:
            return ["A"]
        case .ASharp_BFlat:
            return ["A♯", "B♭"]
        case .B:
            return ["B"]
        }
    }

    /// The frequency for this note at the 0th octave in standard pitch: https://en.wikipedia.org/wiki/Standard_pitch
    var frequency: Frequency {
        switch self {
        case .C:
            return 16.352
        case .CSharp_DFlat:
            return 17.324
        case .D:
            return 18.354
        case .DSharp_EFlat:
            return 19.445
        case .E:
            return 20.602
        case .F:
            return 21.827
        case .FSharp_GFlat:
            return 23.125
        case .G:
            return 24.5
        case .GSharp_AFlat:
            return 25.957
        case .A:
            return 27.5
        case .ASharp_BFlat:
            return 29.135
        case .B:
            return 30.868
        }
    }
}
