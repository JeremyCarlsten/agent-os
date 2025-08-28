# Jest Test Style Guide

## Structure Rules
- Use **2 spaces** for indentation
- **No semicolons**
- ES modules everywhere (`import`/`export`)
- Each test file targets a single module or clearly scoped behavior
- Tests must be **pure and deterministic**—no hidden global state

## File & Suite Organization
- Test file names: `*.test.ts` or `*.test.tsx`
- Mirror source paths: `src/utils/slugify.ts` → `src/utils/slugify.test.ts`
- One top-level `describe` per unit under test; nested `describe` for facets
- Prefer multiple small `it` blocks over omnibus tests
- Arrange ➝ Act ➝ Assert implicitly within each test

## Naming Conventions
- `describe('moduleOrFunction', ...)`
- `it('does the thing under condition', ...)` (present tense, outcome first)
- Shared builders in `__fixtures__` as `makeX`/`buildX`

## Matchers & Assertions
- `toEqual` for deep equality, `toStrictEqual` when structure matters
- `toThrow`/`rejects.toThrow` for error cases
- Use intent-revealing matchers like `toHaveLength`, `toContain`, `toMatchObject`
- One expectation per behavioral outcome

## Types & Imports
- Always type inputs/outputs; never use `any`
- Import narrowly; avoid wildcard imports
- Mock only the boundaries you control (I/O, time, randomness, network)

## Mocks, Time, Randomness
- Prefer dependency injection over `jest.mock`
- Pin time with `jest.useFakeTimers()`/`jest.setSystemTime()` when needed
- Abstract RNG behind an injectable function; seed in tests

## Async Tests
- Use `async/await`
- Prefer `await expect(promise).rejects.toThrow()` over `try/catch`
- For timers, use `jest.runAllTimers()` or `jest.advanceTimersByTime(ms)`

## Setup & Teardown
- Use `beforeEach` for isolated shared setup
- Reset mocks with `jest.resetAllMocks()`
- Avoid global `beforeAll` unless necessary

## Snapshots
- Use sparingly for stable, value-like outputs
- Prefer inline snapshots for small shapes
- Never snapshot large or volatile structures

## Coverage & Quality Gates
- Enforce thresholds at the package level
- Require tests for bug fixes and new public APIs
- Prohibit `console.log` in tests

## Example: Source Under Test

```ts
export type Numeric = number

export const isEven = (n: Numeric): boolean =>
  Number.isFinite(n) && n % 2 === 0

export const doubleIf = (predicate: (n: Numeric) => boolean) =>
  (n: Numeric): Numeric =>
    predicate(n) ? n * 2 : n

export const doubleIfEven = (n: Numeric): Numeric =>
  doubleIf(isEven)(n)
```

## Example: Jest Tests

```ts
import { isEven, doubleIfEven } from './module'

describe('isEven', () => {
  it('returns true for even integers', () => {
    expect(isEven(0)).toBe(true)
    expect(isEven(2)).toBe(true)
    expect(isEven(42)).toBe(true)
  })

  it('returns false for odd integers', () => {
    expect(isEven(1)).toBe(false)
    expect(isEven(3)).toBe(false)
    expect(isEven(41)).toBe(false)
  })

  it('returns false for non-finite numbers', () => {
    expect(isEven(Number.NaN)).toBe(false)
    expect(isEven(Number.POSITIVE_INFINITY)).toBe(false)
  })
})

describe('doubleIfEven', () => {
  it('doubles even numbers', () => {
    expect(doubleIfEven(2)).toBe(4)
    expect(doubleIfEven(100)).toBe(200)
  })

  it('returns original for odd numbers', () => {
    expect(doubleIfEven(3)).toBe(3)
    expect(doubleIfEven(101)).toBe(101)
  })
})
```
