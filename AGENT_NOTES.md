# Agent Development Notes

This document contains a running list of lessons learned to ensure continuous improvement and adherence to project standards. Review these notes before starting any new task.

## Key Learnings & Reminders

1.  **Test-Driven Development (TDD) is a Priority:**
    *   **Rule:** Write tests *first*, before the implementation. Ensure they cover all execution paths, not just the happy path.
    *   **Mistake:** Implementation was created before the tests were finalized, leading to rework.
    *   **Correction:** Always follow the TDD workflow: Red, Green, Refactor.

2.  **Isolate Dependencies for Testability:**
    *   **Rule:** Wrap third-party libraries (especially those interacting with hardware or external services) in a simple interface. This is a core tenet of the Coding Guidelines in `AGENTS.md`.
    *   **Mistake:** The `geolocator` dependency was used directly, making the `LocationEditor` difficult to test.
    *   **Correction:** Abstracted the dependency behind a `LocationProvider` interface, enabling easy mocking and robust testing.

3.  **Mocks Belong in Their Own Files:**
    *   **Rule:** For clarity and organization, complex or reusable mock classes should be defined in their own files within the `test/` directory.
    *   **Mistake:** `MockGeolocatorPlatform` was initially defined inside the test file that used it.
    *   **Correction:** Moved the mock to its own file, `test/providers/mock_geolocator_platform.dart`, improving test code organization.

4.  **Documentation is Comprehensive and Multi-Level:**
    *   **Rule:** Documentation must be thorough at all levels: for classes, for public method signatures, and for the internal logic within method bodies, especially where the logic or testing strategy is complex.
    *   **Mistake:** Initial documentation was sparse and focused only on the public API, neglecting internal comments.
    *   **Correction:** Added detailed comments inside methods to explain the *why* behind the code and the testing approach.

5.  **Use `const` Constructors Where Possible:**
    *   **Rule:** If a class is intended to be used as a default value in a `const` constructor, it must also have a `const` constructor.
    *   **Mistake:** `GeolocatorLocationProvider` was missing a `const` constructor, causing a compile error in `LocationEditor`.
    *   **Correction:** Added the `const` keyword to the constructor.

## Pre-Task Checklist

Before writing any code, confirm you have reviewed and understood:
1.  `AGENTS.md` (Your role, priorities, and rules)
2.  `README.md` (Project-specific coding guidelines)
3.  `AGENT_NOTES.md` (These learnings to avoid repeating mistakes)

## Changelog

*   **2025-12-26:** Second major exercise completed.
    *   Learned to always write tests first.
    *   Learned the importance of `const` constructors for default values.
    *   Reinforced the need for high-level documentation and separating mocks into their own files.

*   **2025-12-26:** Initial creation of `AGENT_NOTES.md`.
    *   Learned to provide comprehensive documentation for all new code.
    *   Learned to write unit tests that cover error conditions, not just the "happy path."
    *   Learned to refactor complex logic out of UI callbacks into separate, well-documented methods.
