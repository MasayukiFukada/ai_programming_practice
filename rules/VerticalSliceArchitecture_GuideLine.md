# Vertical Slice Architecture (VSA) Development Guidelines

You are developing under the **Vertical Slice Architecture (VSA)** design pattern with a **Feature-First** philosophy. Always follow these rules strictly when modifying or creating code.

## 1. Directory Structure Rule
All domain features MUST be placed inside the `src/features/` directory as independent slices.
Group by user action/domain, NOT by technical roles.

- ⭕ Good: `src/features/create-user/`, `src/features/download-invoice/`
- ❌ Bad: `src/controllers/`, `src/services/`, `src/models/`

## 2. Feature Slice Independence Rule (CRITICAL)
- **NO DIRECT CROSS-SLICE IMPORTS:** A feature slice inside `src/features/A` MUST NEVER import anything from `src/features/B`.
- If two slices need shared logic, move that logic to `src/shared/`.
- If communication is needed between slices, use domain events or a parent orchestrator slice.

## 3. Colocation Rule
Keep all feature-specific files together within its slice folder:
- Handler / Implementation (`<feature-name>.ts`)
- Validation Schema (`<feature-name>.schema.ts`)
- Unit/Integration Tests (`<feature-name>.test.ts`)

DO NOT put tests or schemas in separate root directories like `tests/` or `schemas/`.

## 4. DTO & Type Isolation
- Never export or share request/response DTOs or schemas between feature slices.
- Each slice MUST own its input/output shapes.

## 5. Simplicity First (YAGNI)
- Do NOT create unnecessary interfaces, repositories, or abstract classes for simple CRUD slices.
- Write direct, transparent code in a single handler file unless business complexity strictly requires domain isolation.