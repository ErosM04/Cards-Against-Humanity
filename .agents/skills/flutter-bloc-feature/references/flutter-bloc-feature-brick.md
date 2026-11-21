# `flutter_bloc_feature` brick reference

The upstream Bloc brick generates a feature directory with a business-logic directory, feature barrel, and view files. Its documented variables are:

| Variable | Values | Meaning |
| --- | --- | --- |
| `name` | string | Feature name, such as `counter`. |
| `type` | `bloc`, `cubit`, `hydrated_bloc`, `hydrated_cubit`, `replay_bloc`, `replay_cubit` | Business-logic type. |
| `style` | `basic`, `equatable`, `freezed` | State/event modeling style. |

The upstream README shows Mason usage (`mason make flutter_bloc_feature --name counter --type bloc --style basic`). Treat that as an optional generation path: first check whether Mason and the brick are available. If they are unavailable, provide the equivalent file plan and do not report generation as completed.

## Upstream source

- [Bloc `flutter_bloc_feature` brick](https://github.com/felangel/bloc/tree/master/bricks/flutter_bloc_feature)
