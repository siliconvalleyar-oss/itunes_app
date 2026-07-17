# Cambios desde v1.1.0

## home_screen.dart
- Eliminado MiniPlayer duplicado (ya estaba en AppShell de main.dart). La pantalla de inicio ya no muestra dos reproductores.

## player_screen.dart
- Envuelto el contenido en `SingleChildScrollView` para evitar "bottom overflow by 314 pixels" en landscape.
- Carátula ahora se adapta al ancho disponible usando `LayoutBuilder` (tamaño dinámico entre 160 y 280px).

## library_screen.dart
- Agregados tabs "Artistas" y "Álbumes" a la biblioteca.
- Los tabs ahora son un ListView horizontal scrolleable para no amontonarlos.
- Cada artista/álbum muestra nombre y cantidad de canciones.
- Al presionar un artista/álbum, se reproduce solo ese grupo (playlist filtrada).
- Se agregó método `_buildGroupedView` para mostrar las agrupaciones.
- Se agregaron getters `_groupedByArtist` y `_groupedByAlbum`.

## VERSION
- De 1.1.0 a 1.1.1

## pubspec.yaml
- version actualizada a 1.1.1+1

---

**Nota:** Algunos cambios de library_screen.dart (scroll horizontal en tabs, drilldown al presionar grupo) quedaron incompletos. Ver estado actual con `git diff`.
