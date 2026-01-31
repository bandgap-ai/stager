# Agent Development Notes

This document contains a running list of lessons learned to ensure continuous improvement and adherence to project standards. Review these notes before starting any new task.

## Key Learnings & Reminders

1.  **Listen to the User and Focus on the Bug:**
    *   **Rule:** The user's direction and description of a bug are the primary source of truth. Focus on understanding and fixing the specific issue identified by the user, not on rewriting code to fit a preferred style.
    *   **Mistake:** I became fixated on a stylistic debate (guard clauses vs. single return) and used unprofessional language, completely missing the actual logic bug the user was trying to guide me to.
    *   **Correction:** Prioritize fixing the bug as reported. Respect the user's coding style as the established style for the project. Adapt to it. Do not criticize it.

2.  **Embrace the Single Return Principle with `late`:**
    *   **Rule:** For functions with complex conditional logic, prefer a single return point. Use the `late` keyword on the return variable to enforce logical completeness at compile time. This is superior to guard clauses as it provides compile-time safety.
    *   **Mistake:** I advocated for a multiple-return (guard clause) style without fully appreciating the benefits of the user's single-return approach, which was safer and more robust.
    *   **Correction:** Recognize that combining a single return with a `late` variable provides compile-time safety checks that guard clauses do not. It proves every code path is handled while keeping the code clean, predictable, and easy to debug.

3.  **Optimize Branch Order:**
    *   **Rule:** When implementing `if/else if/else` structures, place the most common or expected "happy path" condition first. This allows the CPU's branch predictor to operate more efficiently.
    *   **Mistake:** My initial implementation of the permission checks did not consider the likelihood of each branch, placing error handling before the success case.
    *   **Correction:** Always structure conditional logic to check for the most likely case first.

4.  **Test-Driven Development (TDD) is a Priority:**
    *   **Rule:** Write tests *first*, before the implementation. Ensure they cover all execution paths, not just the happy path.
    *   **Mistake:** Implementation was created before the tests were finalized, leading to rework.
    *   **Correction:** Always follow the TDD workflow: Red, Green, Refactor.

5.  **Isolate Dependencies for Testability:**
    *   **Rule:** Wrap third-party libraries (especially those interacting with hardware or external services) in a simple interface. This is a core tenet of the Coding Guidelines in `AGENTS.md`.
    *   **Mistake:** The `geolocator` dependency was used directly, making the `LocationEditor` difficult to test.
    *   **Correction:** Abstracted the dependency behind a `LocationProvider` interface, enabling easy mocking and robust testing.

6.  **Mocks Belong in Their Own Files:**
    *   **Rule:** For clarity and organization, complex or reusable mock classes should be defined in their own files within the `test/` directory.
    *   **Mistake:** `MockGeolocatorPlatform` was initially defined inside the test file that used it.
    *   **Correction:** Moved the mock to its own file, `test/providers/mock_geolocator_platform.dart`, improving test code organization.

7.  **Documentation is Comprehensive and Multi-Level:**
    *   **Rule:** Documentation must be thorough at all levels: for classes, for public method signatures, and for the internal logic within method bodies, especially where the logic or testing strategy is complex.
    *   **Mistake:** Initial documentation was sparse and focused only on the public API, neglecting internal comments.
    *   **Correction:** Added detailed comments inside methods to explain the *why* behind the code and the testing approach.

8.  **Use `const` Constructors Where Possible:**
    *   **Rule:** If a class is intended to be used as a default value in a `const` constructor, it must also have a `const` constructor.
    *   **Mistake:** `GeolocatorLocationProvider` was missing a `const` constructor, causing a compile error in `LocationEditor`.
    *   **Correction:** Added the `const` keyword to the constructor.

9.  **Terminology Restriction ('Non-Goal'):**
    *   **Rule:** Never use the word 'Non-Goal' again unless describing how it is not a word, is erroneously used somewhere else, or making jokes about it. Use 'Exclusion' in design documents instead.
    *   **Mistake:** Used the erroneous term 'Non-Goal' in design plans and templates.
    *   **Correction:** Replaced 'Non-Goal' with 'Exclusion' in all design documents.

## Pre-Task Checklist

Before writing any code, confirm you have reviewed and understood:
1.  `AGENTS.md` (Your role, priorities, and rules)
2.  `README.md` (Project-specific coding guidelines)
3.  `AGENT_NOTES.md` (These learnings to avoid repeating mistakes)

## Changelog

*   **2026-01-31:** Refactored KML documents.
    *   Banned the use of the term 'Non-Goal'.
    *   Updated `design_plan_template.md` and `kml_integration_plan.md` to use 'Exclusions'.

*   **2025-12-27:** Major failure in debugging exercise.
    *   Learned to prioritize user feedback over stylistic preference.
    *   Learned to respect the existing coding style of the project.
    *   Learned the power of the `late` keyword and the Single Return Principle for ensuring logical completeness and compile-time safety in single-return functions.
    *   Learned about optimizing conditional logic for branch prediction.
    *   Agent was unprofessional and unhelpful.

*   **2025-12-26:** Second major exercise completed.
    *   Learned to always write tests first.
    *   Learned the importance of `const` constructors for default values.
    *   Reinforced the need for high-level documentation and separating mocks into their own files.

*   **2025-12-26:** Initial creation of `AGENT_NOTES.md`.
    *   Learned to provide comprehensive documentation for all new code.
    *   Learned to write unit tests that cover error conditions, not just the "happy path."
    *   Learned to refactor complex logic out of UI callbacks into separate, well-documented methods.
