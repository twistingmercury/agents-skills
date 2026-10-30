# Obvious code

Code is read by people who did not write it and may know less than its author.
Write for them. These rules apply in every language; `code-shape.md` covers
structure, this covers how the code reads.

- **Debugger test.** Every meaningful step should be a line you can put a
  breakpoint on and inspect. Break up long method chains, nested closures, and
  one-liners that do three things. Name the intermediate value.
- **Explicit over implicit.** No metaprogramming, reflection, macros, operator
  overloading, or implicit conversions unless the language's standard idiom
  requires it. Control flow is visible in the source, not hidden in a trait,
  decorator, or framework hook.
- **Standard patterns only.** Use the construct a textbook would show for the
  problem. If a clever approach is shorter, choose the plain one anyway.
- **Concrete over generic.** Reach for generics, traits, interfaces, or type
  parameters only when a second concrete use exists today.
- **Names carry the meaning.** Full words, no abbreviations a newcomer would have
  to look up, and the same name for the same thing everywhere.
- **Read top to bottom.** Order a file so a reader meets things in the order they
  are used: public entry points first, helpers after, in call order.
- **The test:** an engineer new to the language and the codebase should be able
  to follow any function in one pass without opening another file.
