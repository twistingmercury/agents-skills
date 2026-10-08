---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# React and TypeScript

## Style

- TypeScript strict mode. Avoid `any`; use `unknown` and narrow it.
- Function components with hooks. `interface` for props, `type` for unions and utilities.
- Destructure props in the function signature.
- Colocate a component with its styles, tests, and types. New projects use named exports for shared components.
- Greenfield projects use Tailwind CSS for styling and design tokens.

## Components

- Keep components small, with one responsibility. Extract custom hooks for reusable stateful logic.
- Compose instead of drilling props; use context sparingly.
- Prefer controlled inputs for forms.
- Add `useMemo` and `useCallback` only when profiling or referential stability justifies them.
- Use `React.lazy` and `Suspense` when route or bundle size warrants it. Add error boundaries for graceful failure.

## State and data

- Start with local state (`useState`, `useReducer`), lift only as high as needed, and put shareable UI state in the URL. Reach for Zustand or Jotai only when truly needed.
- Server state: TanStack Query by default, unless the project already standardizes on another library. Don't mirror server state in component state without a clear reason.
- Keep API request code and payload translation in modules outside components. Colocate query keys with their feature.
- Routing: React Router. Route modules compose features and set page layout. Greenfield apps start with a small, extendable route tree.

## Security

- Treat external data as untrusted: validate and normalize API data at the boundary, before it reaches UI code.
- Avoid unsafe rendering such as `dangerouslySetInnerHTML`; handle HTML injection deliberately.
- Keep secrets out of client code.
- Add dependencies deliberately, favoring well-maintained packages.

## Accessibility

- Use semantic elements (`button`, `nav`, `main`, `section`) and label every interactive element.
- Every interaction works from the keyboard, with sufficient color contrast.
- Check with axe-core and a screen reader.

## Tests

- Vitest runner, React Testing Library for components. Test behavior, not implementation; query by role, label, or text before test IDs.
- Integration tests cover user flows. Playwright covers E2E browser flows.
- Cover security-sensitive behavior: auth flows, permission gating, input validation, unsafe rendering.

## Checks

After any change, run the project's scripts with its package manager. A new Vite project defines `typecheck`, `lint`, `format:check`, `test`, and `build`. Run the E2E suite too when Playwright is configured or browser flows changed. Fix everything before calling the work done.

## Layout

Follow the layout the project already uses. Where neither the project nor an architecture plan sets one, organize by vertical slice inside clean architecture:

```text
src/
├── app/                 # App shell, providers, router setup (composition root)
├── routes/              # Route-level screens that compose features
├── features/
│   └── patterns/        # subdomain
│       ├── domain/      # core: types, validation, pure business rules
│       ├── create/      # slice: components, hooks (the use case), slice-only ports
│       ├── search/
│       └── api/         # adapter: fetch clients, query functions, payload translation
├── shared/
│   ├── ui/              # Shared primitives
│   ├── hooks/           # Shared custom hooks
│   └── lib/             # Utilities, constants, pure helpers
├── styles/              # Global styles and Tailwind entrypoints
├── test/                # Shared test helpers and setup
└── types/               # App-wide TypeScript types
```

- Organize features by subdomain, then by use-case slice; collapse the slice level for small features.
- Components are the UI adapter and never call `fetch` or storage directly; they use hooks, which reach APIs and storage through the feature's adapter modules.
- Keep `domain/` and `shared/lib/` free of React imports.
- Slices never import each other; another feature uses only a feature's exported hooks and components.
- Enforce boundaries with `eslint-plugin-boundaries` or `dependency-cruiser` when the project uses them.
