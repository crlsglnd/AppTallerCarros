# 🔧 AppTallerCarros

Aplicación móvil y de escritorio para la gestión integral de talleres mecánicos. Permite administrar clientes, vehículos, órdenes de trabajo e inventario de repuestos desde cualquier dispositivo, con sincronización en tiempo real.

---

## ✨ Funcionalidades

- **Clientes** — Registro y consulta de clientes con historial completo
- **Vehículos** — Asociación de vehículos a clientes (marca, modelo, placa, año)
- **Órdenes de trabajo** — Creación, seguimiento y cierre de reparaciones
- **Inventario de repuestos** — Control de stock con alertas de bajo inventario
- **Sincronización en tiempo real** — Los datos se actualizan en todos los dispositivos al instante

---

## 🛠️ Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend / Mobile | Flutter (Dart) |
| Backend / Base de datos | Supabase (PostgreSQL) |
| Autenticación | Supabase Auth |
| Plataformas | Android, iOS, Windows |

---

## 📁 Estructura del proyecto

```
AppTallerCarros/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   └── supabase_client.dart
│   ├── models/
│   │   ├── cliente.dart
│   │   ├── vehiculo.dart
│   │   ├── orden_trabajo.dart
│   │   └── repuesto.dart
│   ├── screens/
│   │   ├── clientes/
│   │   ├── vehiculos/
│   │   ├── ordenes/
│   │   └── inventario/
│   └── widgets/
├── supabase/
│   └── schema.sql
├── assets/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Cómo correr el proyecto

### Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0.0
- Cuenta en [Supabase](https://supabase.com) (gratuita)
- Android Studio o VS Code con extensión Flutter

### Instalación

1. Clona el repositorio
```bash
git clone https://github.com/TU_USUARIO/AppTallerCarros.git
cd AppTallerCarros
```

2. Instala las dependencias
```bash
flutter pub get
```

3. Configura las variables de entorno — crea un archivo `.env` en la raíz:
```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
```

4. Corre el proyecto
```bash
# En móvil / emulador
flutter run

# En Windows (escritorio)
flutter run -d windows
```

### Generar instalador para Windows

```bash
flutter build windows
```
El instalador queda en `build/windows/runner/Release/`.

---

## 🗄️ Base de datos

El esquema SQL está en `supabase/schema.sql`. Para aplicarlo, ve a tu proyecto en Supabase → SQL Editor y ejecuta el archivo.

Tablas principales:
- `clientes`
- `vehiculos`
- `ordenes_trabajo`
- `repuestos`
- `orden_repuestos` (tabla intermedia)

---

## 📸 Capturas

> *Próximamente*

---

## 📄 Licencia

MIT © 2025 — [Tu Nombre](https://github.com/TU_USUARIO)
