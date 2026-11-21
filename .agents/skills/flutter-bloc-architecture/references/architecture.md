# Bloc architecture reference

This local note distills the upstream Bloc architecture guidance for the architecture skill.

## Layer responsibilities

- **Presentation** renders state and handles user input and lifecycle events.
- **Business logic** responds to input with new states and depends on repositories.
- **Data** contains repositories and data providers. Providers expose raw data; repositories coordinate providers and transform data for business logic.

## Coupling boundary

A Bloc should receive information through events and injected repositories. Avoid sibling Bloc-to-Bloc dependencies because they create tight coupling. If one Bloc must affect another, connect them in presentation with a listener, or share a reactive repository in the domain/data boundary.

## Upstream source

- [Bloc architecture documentation](https://github.com/felangel/bloc/blob/master/docs/src/content/docs/architecture.mdx)
