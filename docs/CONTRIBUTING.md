# Guía de Contribución

## Formato de Código

- Dart: `dart format`
- Análisis: `dart analyze`

## Estructura de Commits

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore
```

Ejemplo:
```
feat(player): add shuffle mode
fix(editor): handle null metadata
docs: update API documentation
```

## Branches

- `main` - Producción
- `develop` - Desarrollo
- `feature/*` - Nuevas features
- `fix/*` - Correcciones

## Pull Requests

1. Crear branch desde `develop`
2. Hacer cambios
3. Tests pasando
4. PR con descripción clara
5. Review aprobado

## Tests

```bash
# Ejecutar todos los tests
flutter test

# Con cobertura
flutter test --coverage
```

## Documentación

- Documentar funciones públicas
- Actualizar README si es necesario
- Agregar CHANGELOG entries
