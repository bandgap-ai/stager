# [Title] - [Date]

## Status
(Draft / In Review / Approved / Under Revision / Implemented)

## Context & Background
Describe the problem being solved and the motivation for this design. Reference any relevant issues or previous discussions.

## Goals
List the primary objectives of this design.
* Goal 1
* Goal 2

## Exclusions
List what this design is NOT intended to solve.
* Exclusion 1

## Proposed Design
Detailed description of the architecture, data models, and key components. Include diagrams if necessary.

## Alternatives Considered
Describe other approaches that were explored and why they were rejected (e.g., complexity, performance, lack of support).

## Reviews & Audits
Document feedback from peers and stakeholders. Summarize audit findings for shortcomings and likely failures.

## Implementation Details
Break down the tasks and technical specifics. Mention specific files to be created or modified.

## Testing Plan
Describe the strategy for verification.
* **Unit Tests**: Logic and data models.
* **Widget Tests**: UI components and interaction.
* **Integration Tests**: End-to-end functionality.

## Short Example
Provide a concise code example demonstrating the usage of the new feature or component.

## Open Questions
Document any unresolved items or areas requiring further investigation.

## Tickets

Generate tickets from the above content, then place those tickets in a separate CSV file following
the GitLab format. Finally, once a human creates those tickets in GitLab, they will place the URLs
back in here with standard Markdown link formatting.

The available ticket labels are currently:
* Bug - Bugs are issues that describe unexpected and unintended behavior... like getting a bug in the vacuum tubes of your brand new Harvard Mark II.
* Enhancement - These issues are intended to improve the functionality of the product.
* Feature - This label indicates that this is a new feature for the project. A feature label is different than an enhancement label because enhancements may satisfy nonfunctional requirements whereas features always satisfy functional requirements.
* Full AI - Any AI tools may be used on this task. This label usually indicates that the task is for new or simple code, or things that can be easily performed, such as test and documentation updates.
* Limited AI - AI tools should be limited because the affected code is more mature and stable. AI code-completion, etc., are fine, but full Gemini CLI type editing that can rewrite the whole file is not.
* Mapping - This label indicates the ticket supports the Mapping features in the Stager Platform.
* No AI - This label indicates that, for some reason or other, no AI tools should be used on this task. Tasks with this label could include those that affect customer code with certain license restrictions, old or brittle code where AI will do more harm than good, and things that AI just can't do and, thus, shouldn't try.
* Restricted AI - Tasks with this label have restrictions on how AI may be used on the project. This could be as simple as legal restrictions and managing IP risks, or as complicated as dealing with specific customer requirements on AI use.
* Testing - This label indicates the activity improves or supports testing in the project.