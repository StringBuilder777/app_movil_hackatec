# Prompt para Stitch — App Móvil ROCEEL (Panel Operativo Flutter)

> Copia el contenido de la sección **"PROMPT PARA STITCH"** (más abajo) y pégalo
> directamente en Stitch (`stitch.withgoogle.com`) para generar las pantallas.
> Genera las pantallas en el orden listado — Stitch mantiene mejor coherencia visual
> cuando se genera secuencialmente con un design system establecido.

---

## Contexto de marca (referencia: roceel.com)

**ROCEEL Servicios Especializados** — Empresa B2B de reparación y mantenimiento
de maquinaria industrial (motores, servomotores, husillos, encoders, equipos
electrónicos) con sede en Ramos Arizpe, Coahuila.

**Personalidad de marca:** Profesional · Técnica · Industrial · Confiable · Precisa

**Tono visual:** Corporativo-industrial. Limpio, robusto, técnico — pensado para
ser usado por técnicos en planta, con visibilidad clara incluso bajo luz fuerte
o con manos sucias.

---

## Paleta de colores (basada en roceel.com)

```
PRIMARIO (azul marino industrial)
  --color-primary-900:   #0A1929   (fondo oscuro principal)
  --color-primary-800:   #102A43   (headers, cards oscuras)
  --color-primary-700:   #1B3A5C   (botones primarios hover)
  --color-primary-600:   #234E7D   (botones primarios)
  --color-primary-500:   #3B6CA8   (links, énfasis)

ACENTO (naranja industrial — alerta/acción)
  --color-accent-700:    #C2410C
  --color-accent-600:    #EA580C   (botones de acción crítica, check-in)
  --color-accent-500:    #F97316   (badges hora extra, alertas)
  --color-accent-400:    #FB923C   (highlights suaves)

NEUTROS
  --color-neutral-50:    #F8FAFC   (background app)
  --color-neutral-100:   #F1F5F9   (background secundario)
  --color-neutral-200:   #E2E8F0   (bordes, dividers)
  --color-neutral-300:   #CBD5E1   (bordes activos)
  --color-neutral-500:   #64748B   (texto secundario)
  --color-neutral-700:   #334155   (texto primario sobre claro)
  --color-neutral-900:   #0F172A   (texto fuerte / títulos)

SEMÁNTICOS
  --color-success:       #16A34A   (verde — en zona, jornada activa)
  --color-warning:       #EAB308   (amarillo — fuera de zona, advertencia)
  --color-danger:        #DC2626   (rojo — error, sin check-in)
  --color-info:          #0284C7   (azul info — tránsito)

BLANCO / NEGRO
  --color-white:         #FFFFFF
  --color-black:         #000000
```

### Aplicación de color

- **Fondo principal de la app:** `--color-neutral-50` (#F8FAFC)
- **Cards y superficies:** `#FFFFFF` con sombra suave y borde `--color-neutral-200`
- **AppBar / Bottom Nav:** `--color-primary-900` (#0A1929) con texto/íconos blancos
- **Botón primario (Check-In):** `--color-accent-600` (#EA580C) con texto blanco
- **Botón secundario:** outline `--color-primary-700` con texto `--color-primary-700`
- **Estado "en zona":** verde `--color-success`
- **Estado "hora extra":** badge naranja `--color-accent-500`
- **Estado "sin check-in" (alerta):** rojo `--color-danger`

---

## Tipografía

- **Familia:** `Inter` (o `Roboto` como fallback) — sans-serif, geométrica
- **Escala:**
  - Display: 32px / bold
  - H1: 24px / semibold
  - H2: 20px / semibold
  - Título: 18px / semibold
  - Cuerpo: 16px / regular
  - Caption: 14px / regular
  - Micro: 12px / medium

---

## Reglas generales de UI

- **Border radius:** 12px en cards, 8px en inputs/botones, 999px en chips/badges
- **Sombras:** suaves, máximo 2 capas (`0 1px 2px rgba(0,0,0,0.04)` + `0 1px 6px rgba(0,0,0,0.08)`)
- **Spacing system:** múltiplos de 4px (4, 8, 12, 16, 20, 24, 32, 48)
- **Hit areas:** mínimo 48x48dp para todos los botones (uso con guantes/dedos sucios)
- **Iconos:** Material Symbols (rounded), 24dp por defecto
- **Densidad:** cómoda — pensada para uso outdoor / planta
- **Idioma:** **todo en español de México** (fechas, copys, etiquetas)
- **Modo:** Light primero; dark mode opcional

---

# 🎨 PROMPT PARA STITCH

> Copia desde aquí ↓ hasta el final del bloque y pégalo en Stitch.

---

**App:** ROCEEL Operativo — App móvil Flutter para técnicos industriales en campo.

**Propósito:** Permitir a técnicos de mantenimiento industrial hacer check-in
geolocalizado, registrar actividades del día y subir un reporte de texto con
lo realizado desde plantas de clientes.

**Usuarios:** Técnicos electromecánicos (25-55 años) que trabajan en planta,
usando el celular con guantes, bajo iluminación industrial.

**Plataforma:** Mobile (iOS + Android), construido en Flutter. Diseño 390x844px
como base (iPhone 14). Todo en **español de México**.

---

## Sistema de diseño

**Paleta de colores:**
- Primario (azul marino industrial): `#0A1929` (oscuro), `#234E7D` (medio), `#3B6CA8` (claro)
- Acento (naranja industrial — botones de acción crítica): `#EA580C`
- Fondo app: `#F8FAFC`
- Cards: `#FFFFFF` con sombra muy suave
- Texto primario: `#0F172A`
- Texto secundario: `#64748B`
- Bordes: `#E2E8F0`
- Éxito (en zona, jornada activa): `#16A34A` verde
- Advertencia (fuera de zona): `#EAB308` amarillo
- Peligro (sin check-in): `#DC2626` rojo
- Info (tránsito): `#0284C7` azul cielo
- Badge "HORA EXTRA": fondo `#F97316` naranja vivo con texto blanco

**Tipografía:** Inter (sans-serif).
- Títulos en bold/semibold
- Cuerpo en regular 16px
- Captions 14px

**Estilo visual:**
- Corporativo-industrial: limpio, robusto, técnico
- Border-radius 12px en cards, 8px en botones, 999px en badges/chips
- Sombras suaves
- Iconos Material Symbols Rounded
- Spacing generoso (uso con guantes)
- Botones altos (mínimo 56dp para acciones primarias)
- Mucho contraste — la app se usa en planta con luz fuerte

**Personalidad:** Profesional, confiable, técnico. NO playful. NO gradients
exagerados. NO ilustraciones cartoon. Sí: fotografía industrial real cuando
se necesite (técnicos trabajando, maquinaria).

---

## Pantallas a generar — EN ESTE ORDEN

### Pantalla 1 — Splash
- Logo ROCEEL centrado sobre fondo `#0A1929` (azul marino)
- Texto bajo el logo: "Panel Operativo"
- Pequeño spinner naranja `#EA580C` en la parte inferior
- Versión de app en el footer en gris claro

### Pantalla 2 — Login
- Fondo claro `#F8FAFC`
- Logo ROCEEL en el top
- Título: "Iniciar sesión"
- Subtítulo: "Accede con tu número de empleado"
- Campo "Número de empleado" (input con ícono badge)
- Campo "Contraseña" (input con ícono lock + toggle de ojo)
- Link en azul "¿Olvidaste tu contraseña?"
- Botón primario grande naranja `#EA580C` "Ingresar"
- Footer: "ROCEEL Servicios Especializados v1.0.0"

### Pantalla 3 — Permisos (onboarding)
- 2 cards verticales explicando permisos requeridos:
  1. Ubicación (siempre) — ícono pin, "Necesario para validar tu asistencia"
  2. Notificaciones — ícono campana, "Recordatorios y alertas"
- Cada card con un checkbox/toggle del estado
- Botón abajo "Continuar" (deshabilitado hasta otorgar ubicación)

### Pantalla 4 — Inicio / Dashboard del día (sin check-in)
- AppBar oscuro `#0A1929` con avatar circular del técnico + saludo "Hola, [Juan]"
- Hora actual grande, en verde si es horario laboral
- **Banner ROJO grande** `#DC2626`: "⚠️ Aún no has hecho check-in hoy"
  con botón "Hacer check-in ahora" en blanco
- Card "Tu ubicación actual" con mini-mapa y dirección
- Card "Zonas asignadas hoy" lista de 3 ubicaciones con distancia
- Bottom nav con 5 tabs: Inicio · Jornada · Actividades · Reporte · Perfil

### Pantalla 5 — Inicio / Dashboard del día (CON check-in activo)
- AppBar oscuro con avatar + saludo
- Card prominente verde claro con borde `#16A34A`:
  - Ícono check verde
  - "Jornada activa desde 08:14"
  - Nombre de ubicación actual: "Taller Ramos Arizpe"
  - Tiempo acumulado: "2h 35m"
- Si pasa las 18:00 → Badge naranja **"HORA EXTRA"** visible
- Card "Resumen del día":
  - Horas normales: 2h 35m
  - Horas extra: 0h 0m
  - Actividades completadas: 3
- Botón "Ver mapa de mi jornada"
- Botón secundario "Hacer check-out" abajo

### Pantalla 6 — Check-In (validación geográfica)
- AppBar con back arrow + título "Check-In"
- **Mapa grande** ocupando 60% superior:
  - Marcador azul del técnico (su ubicación actual)
  - Círculos de zonas válidas asignadas (verde si dentro, gris si fuera)
- Card inferior con estado:
  - Si está EN zona: card verde "✓ Dentro de zona válida — Taller Ramos Arizpe"
  - Si está FUERA: card amarillo "Estás a 245m de Taller Ramos Arizpe"
- Indicador de precisión GPS: "±8m"
- Indicador de horario: "08:14 — Horario laboral" (verde) o "18:32 — Hora extra" (naranja)
- Botón grande naranja `#EA580C` "Confirmar check-in" (deshabilitado si está fuera de zona)

### Pantalla 7 — Alerta horario fuera de base (al hacer check-in 19:00+)
- Modal/Dialog centrado
- Ícono naranja de advertencia
- Título: "Estás fuera del horario base"
- Texto: "El horario laboral es de 08:00 a 18:00. Si haces check-in ahora, el tiempo se registrará como **HORA EXTRA**."
- Botón secundario "Cancelar"
- Botón primario naranja "Continuar (hora extra)"

### Pantalla 8 — Jornada en curso (timeline)
- AppBar "Mi jornada de hoy"
- Header con totales: Normal 4h 12m · Extra 0h · Tránsito 18m
- **Timeline vertical** con segmentos como cards:
  - 08:14 — 10:45 · Taller Ramos Arizpe · trabajo · 2h 31m (verde)
  - 10:45 — 11:03 · EN TRÁNSITO · 18m (azul info)
  - 11:03 — ahora · Planta GM · trabajo · 1h 41m (verde, activo, pulso)
- Cada segmento con ícono semántico y barra lateral del color del tipo
- Botón flotante "+ Registrar actividad"

### Pantalla 9 — Lista de actividades del día
- AppBar "Actividades de hoy"
- Filtro chips arriba: Todas · En progreso · Completadas · Pausadas
- Lista de cards de actividad:
  - Cada card: nombre actividad, cliente, hora inicio, duración
  - Badge del estado (verde completada, naranja en progreso, amarillo pausada)
  - Categoría como chip pequeño (ensamble/desensamble/testing)
- Empty state si no hay: ilustración simple + "Aún no has registrado actividades hoy"
- FAB naranja "+ Nueva actividad"

### Pantalla 10 — Nueva actividad (formulario)
- AppBar con back + título "Nueva actividad"
- Section "Detalles":
  - Dropdown "Cliente" (search habilitado)
  - Dropdown "Actividad" (search, con categorías agrupadas)
  - Dropdown "Orden de trabajo" (opcional, con folio ROC-2026-0001)
- Section "Notas":
  - TextArea multilínea grande "Notas (opcional)"
- Info card gris: "Esta actividad se vinculará a tu ubicación actual: **Planta GM**"
- Botón primario naranja "Iniciar actividad"

### Pantalla 11 — Actividad en progreso (cronómetro)
- Fondo claro
- Header con nombre actividad + cliente
- **Cronómetro grande centrado** 00:23:45 (mono, semibold, 48pt)
- Tiempo estimado debajo: "Estimado: 45 min" (con barra de progreso)
- 3 botones grandes en fila:
  - "Pausar" (secundario amarillo)
  - "Agregar reporte" (secundario azul, ícono documento/edit)
  - "Completar" (primario verde)
- Section abajo: "Reporte de la actividad" — preview corto del texto guardado (si existe)

### Pantalla 12 — Reporte de actividad
- AppBar con back + título "Reporte de actividad"
- Subtítulo con nombre de actividad + cliente
- Card info gris (read-only) con metadatos automáticos:
  - Timestamp
  - Ubicación GPS actual
  - Vinculado a actividad: "[nombre actividad]"
- TextArea grande **"¿Qué se hizo?"** (multilínea, alto cómodo, ~6-8 líneas visibles)
- Contador de caracteres "0 / 1000"
- Botón secundario "Cancelar" + Botón primario naranja "Guardar reporte"

### Pantalla 13 — Reportes del día
- AppBar "Mis reportes"
- Filtros: Hoy · Esta semana · Por cliente · Por actividad
- Lista de cards (no grid de fotos):
  - Cada card con nombre de actividad, cliente, hora y un extracto del reporte
  - Badge de estado: "Sincronizado" verde o "Pendiente" amarillo
- Tap → detalle del reporte (texto completo + metadatos)

### Pantalla 14 — Check-out (resumen del día)
- AppBar "Cerrar jornada"
- Card verde con check grande
- Título "Resumen de tu jornada"
- Lista visual:
  - 🟢 Horas normales: **6h 12m**
  - 🟠 Horas extra: **1h 25m**
  - 🔵 Tránsito: **0h 18m**
  - 🟡 Fuera de zona: **0h 5m**
- Total: **7h 55m**
- Actividades completadas: 5
- Ubicaciones visitadas: 2
- Reportes capturados: 5
- Botón secundario "Ver detalle"
- Botón primario naranja "Confirmar check-out"

### Pantalla 15 — Sin conexión
- Banner persistente arriba en `#EAB308` amarillo: "Sin conexión — tus cambios se sincronizarán automáticamente"
- Contador: "3 cambios pendientes"
- El resto de la pantalla sigue funcional con datos en caché

### Pantalla 16 — Perfil del técnico
- AppBar "Mi perfil"
- Header con avatar grande + nombre + número de empleado + rol
- Card "Mis ubicaciones asignadas" (lista)
- Card "Configuración": notificaciones, calidad GPS, idioma
- Card "Seguridad": cambiar contraseña
- Card "Acerca de": versión, términos, privacidad
- Botón outline rojo "Cerrar sesión"

### Pantalla 17 — Notificaciones / Alertas
- Lista de notificaciones tipo card:
  - "Saliste de Taller Ramos Arizpe a las 10:45"
  - "Llevas más de 30 min en tránsito"
  - "Has entrado en horario de hora extra"
- Cada una con timestamp relativo + ícono semántico

---

## Constraints importantes

1. **Usar solo la paleta definida arriba.** No introducir otros colores.
2. **Todo en español de México.** Fechas formato `DD/MM/AAAA`, horas formato 24h.
3. **Botones de acción primaria SIEMPRE naranjas** `#EA580C` (check-in, confirmar).
4. **El badge "HORA EXTRA"** debe ser visualmente prominente cuando aparezca.
5. **Iconografía consistente** — Material Symbols Rounded en todas las pantallas.
6. **Sin gradientes ni efectos glassmorphism.** Diseño plano + sombras sutiles.
7. **Hit areas grandes** — esta app se usa con guantes industriales.
8. **Los mapas** deben mostrar marcadores y círculos de geofence claramente.
9. **Estados vacíos** simples, sin ilustraciones infantiles.
10. **Contraste AA mínimo** en todos los textos.

---

> Fin del prompt para Stitch.

---

## Notas para iterar en Stitch

Si Stitch no captura algo a la primera, itera con prompts cortos como:
- "Make the primary buttons larger, minimum 56dp height"
- "Add the orange HORA EXTRA badge to screen 5 next to the time"
- "Make the geofence circles on the map more visible — use 30% opacity green fill"
- "Tighten the spacing on the timeline screen — reduce vertical gaps"
- "Move the bottom action bar higher above the system gesture bar"

## Después de generar

1. Exportar pantallas como PNG / Figma
2. Extraer tokens de color y tipografía para `lib/core/theme/`
3. Implementar widgets reutilizables (ver sección 1.3 de `DISEÑO_APP_MOVIL_FLUTTER.md`)
4. Validar contraste con técnico real antes de entregar

---

**Última actualización:** 2026-05-22
