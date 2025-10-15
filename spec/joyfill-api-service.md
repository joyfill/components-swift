# JoyfillAPIService Module Specification

Source: `components-swift/Sources/JoyfillAPIService`

## Responsibilities
- Encapsulate network I/O with the Joyfill REST API using `URLSession`.
- Provide typed fetch/update helpers that map responses to `JoyfillModel` entities.
- Handle authentication headers with bearer tokens supplied at initialisation.

## Structure
- `JoyfillAPI` enum (`JoyfillAPIService.swift`) centralises endpoint construction for:
  - `documents` (list or by template identifier)
  - `templates`
  - `submissiondocuments` (single document fetch)
  - `groups` and `users`
  - `saveChangelog`, `saveDocument`
  - `convertPDFToPNGs` (currently points to documents listing)
- `APIService` class initialised with `accessToken` and `baseURL`.
  - `urlRequest(type:method:httpBody:)` builds requests with JSON `Content-Type` and bearer token.
  - `makeAPICall(with:completionHandler:)` executes an async data task.

## Public API
- `fetchDocuments(identifier:page:limit:completion:)`
- `fetchDocumentSubmissions(identifier:completion:)`
- `fetchTemplates(page:limit:completion:)`
- `fetchJoyDoc(identifier:completion:)` – returns raw `Data` to allow manual decoding.
- `loadImage(from:completion:)` – Handles base64 strings, local file URLs, or network URLs.
- `fetchGroups(completion:)`, `retrieveGroup(identifier:completion:)`
- `fetchListAllUsers(completion:)`, `retrieveUser(identifier:completion:)`
- `createDocumentSubmission(identifier:completion:)` – loads JoyDoc JSON first, then delegates to `createDocument`.
- `createDocument(joyDocJSON:identifier:completion:)` – strips non-persisted keys, forces type to `"document"`, sets `template`/`source`, and POSTs to `/documents`.
- `updateDocument(identifier:changeLogs:completion:)` – POSTs changelog payload to `/documents/{id}/changelogs`.
- `updateDocument(identifier:document:completion:)` – POSTs minimal payload with `files` and `fields` collections.

## Dependencies & Data Models
- Uses `JoyfillModel` types (`Document`, `DocumentListResponse`, `GroupResponse`, `RetrieveGroup`, `ListAllUsersResponse`, `JoyDoc`) for JSON decoding/encoding.
- `APIError` enum exposes `.invalidURL` and `.unknownError` for consumer handling.

## Behaviour Notes
- All completion handlers return on background threads except `fetchJoyDoc`, which dispatches to `main` before invoking the completion.
- No retry or pagination helpers are built in; callers manage pagination via `page`/`limit` parameters.
- `createDocument` currently force unwraps intermediate conversions (`try!`)—callers must ensure server responses conform or wrap with additional error handling upstream.
