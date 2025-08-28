# JavaScript Style Guide (ES2024+/TypeScript)

## Structure Rules
- Use **2 spaces** for indentation
- **No semicolons**
- Prefer **`const`**; use `let` only when reassignment is unavoidable; never use `var`
- One module per file with focused responsibilities
- Keep lines ≤ 100 characters where practical
- Always include a copyright header in source and test files

## Language & Types
- Write modern **ES modules** only (`import`/`export`)
- Default to **TypeScript**; enable strict mode; never use `any`
- Prefer `unknown` over `any` at boundaries; narrow with type guards
- Use `type` aliases for data shapes; use `interface` only for public OO contracts
- Prefer readonly data: `readonly T[]`, `Readonly<Record<K, V>>`, `as const` where appropriate
- Use the `satisfies` operator to enforce literal shapes without widening

## Naming Conventions
- **camelCase** for variables and functions
- **PascalCase** for classes, components, and types
- **UPPER_CASE** for constants intended as globals or configuration keys
- Files and folders in **kebab-case**; test files mirror source paths (`*.test.ts`/`*.test.tsx`)

## Functional Principles
- Small, single-purpose, **pure** functions
- Avoid local mutations; prefer expressions over statements
- Extract non-trivial predicates and lambda bodies into named functions
- Compose behavior through function calls; avoid deep nesting
- Use data-first utilities and pipeline-friendly shapes

## Imports & Exports
- Order imports: Node built-ins → external packages → internal modules
- Group and alphabetize within each section
- Prefer **named exports**; avoid default exports
- No circular dependencies; isolate shared types in dedicated modules

## Data & Collections
- Prefer `map`, `filter`, `flatMap`, `reduce` to explicit loops
- Use `Set`/`Map` for membership and keyed collections
- Use new immutable helpers: `toSorted`, `toReversed`, `toSpliced`, `with`
- Build objects via `Object.fromEntries` and `Object.groupBy` when suitable
- Enforce immutability at boundaries and in return values

## Strings & Templates
- Use template literals exclusively
- Prefer tagged templates or small formatter functions for complex interpolation

## Control Flow & Errors
- Prefer expressions (`cond ? a : b`) and early returns over nested blocks
- Throw `Error` subclasses for exceptional paths; never return sentinel values
- For recoverable flows, return explicit sum types (e.g., `Result`-style)

## Async & I/O
- Use `async/await`; avoid mixing with `.then()` chains
- Model time, randomness, and I/O behind injectable functions for testability
- Do not log to console in libraries; return values or throw

## React/React Native Specifics
- Components as pure functions; keep them small
- Derive state; avoid duplicating props in state
- Extract event handlers and heavy logic outside JSX
- Use `useMemo`/`useCallback` only for measurable wins, not as decoration
- Co-locate component-specific hooks and types with the component

## Example JavaScript/TypeScript Structure

```ts
import { readFile } from 'node:fs/promises'

export type Numeric = number

const isFiniteNumber = (n: unknown): n is number =>
  typeof n === 'number' && Number.isFinite(n)

export const isEven = (n: Numeric): boolean =>
  isFiniteNumber(n) && n % 2 === 0

export const doubleIf = <T extends Numeric>(predicate: (n: T) => boolean) =>
  (n: T): T | Numeric =>
    predicate(n) ? (n * 2) as Numeric : n

export const doubleIfEven = (n: Numeric): Numeric =>
  doubleIf(isEven)(n)

export const uniqueSorted = (xs: readonly Numeric[]): readonly Numeric[] =>
  Array.from(new Set(xs)).toSorted((a, b) => a - b)

export const groupByParity = (xs: readonly Numeric[]) =>
  Object.groupBy(xs, x => (isEven(x) ? 'even' : 'odd'))
```
