# Reglas de Oro

## 1. Versión y Tags

- `VERSION` archivo en la raíz es la fuente de verdad.
- Cada commit debe tener un tag anotado `v{VERSION}`.
- Al hacer cambios: incrementar `VERSION` → `pubspec.yaml` → commit → tag → `git push --tags`.

## 2. Instalar en Móvil sin Borrar

- Usar `adb install -r build/app/outputs/flutter-apk/app-debug.apk` para **reemplazar** la app sin desinstalarla.
- Esto conserva los permisos ya otorgados y evita tener que autorizar cada vez.
- Compilar primero con `flutter build apk --debug`.
