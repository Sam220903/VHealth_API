# VHealth_API

**VHealth_API** es el backend REST del sistema de pausas activas **VHealth**. Expone en JSON los datos de ejercicios y rutinas que consume el frontend [`kinetic`](https://github.com/Sam220903/kinetic) (incluyendo los `ai_parameters` que ese frontend usa para el reconocimiento de poses con MediaPipe).

Está escrito en **PHP puro** (sin framework, sin Composer) sobre **MySQL**, con arquitectura de tres capas (controlador → servicio → base de datos vía PDO).

> Este repositorio es solo el backend. Para probar el flujo completo (crear una sesión en vivo, ver rutinas reales) necesitas correrlo junto al frontend [`kinetic`](https://github.com/Sam220903/kinetic), apuntando su variable `VITE_API_URL` hacia esta API.

## Tabla de contenido

- [Arquitectura general](#arquitectura-general)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Partes más importantes](#partes-más-importantes)
  - [Enrutamiento (`index.php`)](#enrutamiento-indexphp)
  - [Capa de configuración](#capa-de-configuración)
  - [Controladores](#controladores)
  - [Servicios (acceso a datos)](#servicios-acceso-a-datos)
  - [Modelo `Exercise`](#modelo-exercise)
  - [`TypeCaster`](#typecaster)
  - [Base de datos](#base-de-datos)
- [Endpoints disponibles](#endpoints-disponibles)
- [Cómo ejecutarlo](#cómo-ejecutarlo)
  - [Opción A: Docker Compose (recomendada)](#opción-a-docker-compose-recomendada)
  - [Opción B: entorno LAMP/XAMPP manual](#opción-b-entorno-lampxampp-manual)
- [Estado del proyecto / limitaciones conocidas](#estado-del-proyecto--limitaciones-conocidas)

## Arquitectura general

```
┌───────────────────┐   HTTP (JSON)   ┌─────────────────────────────┐
│  Frontend kinetic  │ ──────────────▶ │  api/public/index.php        │
│  (Vite + JS)       │ ◀────────────── │  (front controller / router) │
└───────────────────┘                 └───────────┬──────────────────┘
                                                    │ instancia según ruta
                                        ┌───────────▼───────────┐
                                        │ ExerciseController /   │
                                        │ RoutineController       │  ← capa de presentación
                                        └───────────┬────────────┘
                                                    │
                                        ┌───────────▼────────────┐
                                        │ ExerciseService /       │
                                        │ RoutineService           │  ← capa de negocio/consultas
                                        └───────────┬────────────┘
                                                    │ PDO
                                        ┌───────────▼────────────┐
                                        │  MySQL (vh_db)           │
                                        │  vh_users, vh_exercises, │
                                        │  vh_routines,             │
                                        │  vh_routines_exercises    │
                                        └────────────────────────┘
```

Ideas clave:

- **No hay framework ni router de terceros**: todo el enrutamiento vive en `api/public/index.php`, que parsea manualmente la URL y despacha a un `switch` según el segmento de ruta (`exercises`, `routines`, `test`).
- **Autoload manual**: un `spl_autoload_register` busca cada clase por nombre en las carpetas `config/`, `controllers/`, `services/`, `models/`, `middleware/` y `helpers/` (no hay Composer/`autoload.php`).
- **Patrón de 3 capas por recurso**: Controlador (decide GET colección vs GET recurso) → Servicio (SQL vía PDO con prepared statements) → PDO/MySQL.
- **Sin autenticación implementada todavía**: la carpeta `middleware/` está prevista en el autoloader pero no existe ningún archivo dentro; no hay verificación de tokens en el router.

## Estructura del repositorio

```
VHealth_API/
├── Dockerfile                  # Imagen PHP 7.4-cli con pdo/pdo_mysql
├── docker-compose.yml           # Orquesta el contenedor de la API + MySQL
├── README.md                    # (vacío en el repo original)
├── db/
│   └── VH_DB_V1.sql              # Script de creación + datos semilla (ejercicios y rutinas)
└── api/
    ├── public/                   # Document root servido por Apache/PHP
    │   ├── .htaccess               # Reescribe cualquier ruta hacia index.php
    │   └── index.php               # Front controller: autoload + router + CORS
    └── src/
        ├── config/
        │   ├── config.php           # Credenciales de conexión a MySQL (por entorno)
        │   ├── Database.php         # Wrapper de PDO
        │   └── header.php           # Headers CORS y Content-Type JSON
        ├── controllers/
        │   ├── ExerciseController.php
        │   └── RoutineController.php
        ├── services/
        │   ├── ExerciseService.php   # Consultas SQL de ejercicios
        │   └── RoutineService.php    # Consultas SQL de rutinas (incluye CTE de zona corporal)
        ├── models/
        │   └── Exercise.php          # Entidad Exercise (getters/setters/toArray)
        └── helpers/
            └── TypeCaster.php        # Normaliza tipos numéricos en las filas de MySQL
```

## Partes más importantes

### Enrutamiento (`index.php`)

Es el punto de entrada único. Su lógica de parseo de ruta es la parte más particular del proyecto:

```php
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$parts = explode('/', trim($path, '/'));
$lastIndex = count($parts) - 1;
$route = $parts[$lastIndex - 1] ?? null;
$id = $parts[$lastIndex] ?? null;

if (!is_numeric($id)) {
    $route = $id;
    $id = null;
}
```

Es decir: **siempre toma los dos últimos segmentos de la URL**. Si el último segmento es numérico, lo trata como `id` de un recurso (`GET /exercises/5`); si no, asume que es el nombre de la colección (`GET /exercises`). Esto funciona sin importar cuántos subdirectorios haya antes (por ejemplo `/VHealth_API/api/public/exercises` en un LAMP local).

Después, un `switch($route)` decide qué controlador instanciar:

| Ruta | Controlador / Servicio |
|---|---|
| `test` | Responde `{"php_version": "..."}` — útil para verificar que el servidor PHP responde. |
| `exercises` | `ExerciseController` + `ExerciseService`. |
| `routines` | `RoutineController` + `RoutineService`. |

Cualquier excepción lanzada por el controlador se captura y responde con `400` y un JSON `{"error": "..."}`.

### Capa de configuración

- **`header.php`**: define CORS abierto (`Access-Control-Allow-Origin: *`), métodos permitidos (`GET, POST, PATCH, DELETE`) y fuerza `Content-Type: application/json`. El router además responde `200` inmediatamente a cualquier `OPTIONS` (preflight de CORS).
- **`config.php`**: define el arreglo `$connection` (host, usuario, contraseña, nombre de base de datos) usado para instanciar `Database`. Trae tres variantes comentadas/activas para distintos entornos (LAMP local, producción, contenedor Docker) — hay que descomentar la que corresponda a mano.
- **`Database.php`**: clase pequeña que arma el DSN de PDO (`mysql:host=...;dbname=...;charset=utf8mb4`) y expone `getConnection(): PDO`.

### Controladores

`ExerciseController` y `RoutineController` comparten el mismo patrón: reciben su `Service` por constructor y exponen `processRequest($method, $id)`, que decide entre:

- `processResourceRequest`: cuando viene un `$id` → responde el detalle de un solo recurso.
- `processCollectionRequest`: cuando no hay `$id` → responde la colección completa.

Por ahora **solo implementan el método `GET`** en ambos casos; los demás verbos (`POST`, `PATCH`, `DELETE`, ya anunciados en los headers CORS) caen en el `default: break;` y no hacen nada.

### Servicios (acceso a datos)

- **`ExerciseService`**: `getExercises()` (todos los ejercicios) y `getExercisePerID($id)`. Ambos usan `PDO::prepare` con parámetros ligados (protegidos contra inyección SQL).
- **`RoutineService`**: es el más elaborado.
  - `getRoutines()` arma, vía un **CTE (`WITH`)**, la "zona del cuerpo" de cada rutina: si todos sus ejercicios comparten la misma `body_zone` la devuelve tal cual; si hay varias, devuelve `"Mixto"`; si la rutina no tiene ejercicios asignados, devuelve `"Sin ejercicios"` (`COALESCE`).
  - `getRoutinePerID($id)` combina dos consultas privadas —`getRoutineDetails` (datos de la rutina) y `getRoutineExercises` (sus ejercicios ordenados por `sort_order`, con `name`, `repetitions`, `body_zone`, `ai_parameters` y `video_url`)— y devuelve un único objeto `{ routine_details, exercises }`. **Esta es la forma exacta que consume `live-session.js` del frontend** para saber qué ejercicios mostrar y con qué parámetros de IA medir cada uno.

### Modelo `Exercise`

Clase de entidad clásica (propiedades privadas tipadas, getters/setters, `toArray()`). Está definida pero **`ExerciseService` todavía no la usa**: hoy devuelve directamente arreglos asociativos de `PDO::FETCH_ASSOC` en vez de instanciar `Exercise`.

### `TypeCaster`

Ayudante usado por ambos controladores antes de serializar a JSON: recorre cada fila (o arreglo de filas) y convierte los valores que `PDO` devuelve como *string* pero que en realidad son numéricos (`"5"` → `5`, `"3.14"` → `3.14`), para que el frontend reciba tipos correctos en vez de todo como texto.

### Base de datos

`db/VH_DB_V1.sql` crea 4 tablas InnoDB y las puebla con datos semilla:

| Tabla | Propósito |
|---|---|
| `vh_users` | Usuarios (`name`, `email`, `password_hash`) — sin endpoints ni servicio implementados aún. |
| `vh_exercises` | Catálogo de ejercicios: `body_zone` (`ENUM`: Tren superior / Tren inferior / Zona media), `ai_parameters` (columna `JSON`) y `video_url`. |
| `vh_routines` | Rutinas, ligadas opcionalmente a un `user_id`. |
| `vh_routines_exercises` | Tabla puente rutina↔ejercicio, con `sort_order` y `repetitions` propios de esa combinación. |

El campo **`ai_parameters`** es el contrato entre esta API y el frontend: contiene los `key_points` (índices de landmarks de MediaPipe), el `joint` medido, los umbrales `threshold_start`/`threshold_contract` y el `logic_state` (`"ascending"`/`"descending"`) que `live-session.js` usa para calcular ángulos y contar repeticiones. El script semilla ya incluye 5 ejercicios reales (sentadillas, zancadas, elevación de rodilla, y dos de brazos) con estos parámetros calibrados.

## Endpoints disponibles

Todas las respuestas son JSON. Base path de ejemplo: `http://localhost/VHealth_API/api/public` (LAMP) o `http://localhost:8080` (Docker, ver limitaciones más abajo).

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/test` | Verifica que el servidor responde; devuelve la versión de PHP. |
| `GET` | `/exercises` | Lista todos los ejercicios. |
| `GET` | `/exercises/{id}` | Detalle de un ejercicio. |
| `GET` | `/routines` | Lista todas las rutinas, con su `body_zone` calculada. |
| `GET` | `/routines/{id}` | Detalle de una rutina: `{ routine_details, exercises: [...] }`. |

No hay endpoints de escritura (`POST`/`PATCH`/`DELETE`) implementados todavía, ni endpoints de usuarios/autenticación.

## Cómo ejecutarlo

### Opción A: Docker Compose (recomendada)

```bash
git clone https://github.com/Sam220903/VHealth_API.git
cd VHealth_API
docker compose up -d --build
```

Esto levanta:
- `vhealth_db`: MySQL 8, con la base `vh_db` inicializada automáticamente desde `db/VH_DB_V1.sql` (usuario `vh_user`, ver `docker-compose.yml` para la contraseña).
- `vhealth_api`: PHP 7.4 sirviendo con `php -S 0.0.0.0:80 -t /var/www/html`, publicado en el puerto `8080`.

> ⚠️ Con este `docker-compose.yml` tal como está, `config.php` sigue apuntando por defecto a `localhost`/`root` (la variante LAMP), no a las variables `DB_HOST`/`DB_USER`/`DB_PASSWORD` que sí se definen como entorno del contenedor `vhealth_api`. Para que el contenedor conecte a MySQL correctamente, edita `api/src/config/config.php` y descomenta/activa el bloque `"servername" => "vhealth_db", "username" => "vh_user", ...` (el que corresponde a Docker) antes de construir la imagen, o adapta `config.php` para leer esas variables de entorno con `getenv()`.

### Opción B: entorno LAMP/XAMPP manual

```bash
git clone https://github.com/Sam220903/VHealth_API.git
```

1. Copia (o enlaza) la carpeta del repo dentro de tu `htdocs` de XAMPP/Apache.
2. Crea la base de datos importando `db/VH_DB_V1.sql` (por ejemplo, desde phpMyAdmin o `mysql -u root -p < db/VH_DB_V1.sql`).
3. Edita `api/src/config/config.php` y ajusta el bloque `$connection` con las credenciales de tu MySQL local (usuario, contraseña, `dbname` = `vh_db`).
4. Asegúrate de que `mod_rewrite` esté habilitado en Apache (el `.htaccess` de `api/public/` depende de él).
5. Apunta el document root (o un alias/virtualhost) a `api/public/`, o simplemente entra a `http://localhost/VHealth_API/api/public/test` para confirmar que responde.
6. En el frontend `kinetic`, define `VITE_API_URL=http://localhost/VHealth_API/api/public` en su `.env.development` (es justo el valor que trae por defecto).

## Estado del proyecto / limitaciones conocidas

- **Solo lectura**: los controladores solo implementan `GET`; no hay altas, ediciones ni borrados de ejercicios, rutinas o usuarios, aunque los headers CORS ya anuncian `POST, PATCH, DELETE`.
- **Sin autenticación**: la tabla `vh_users` y la columna `password_hash` existen, pero no hay endpoints de login/registro ni middleware de autenticación (la carpeta `middleware/` está prevista en el autoloader pero vacía). El frontend (`apiClient.js`) ya tiene soporte para enviar un token `Bearer`, pero esta API todavía no lo valida.
- **Enrutamiento en el servidor `php -S` de Docker**: al no pasarle un *router script* al comando `php -S 0.0.0.0:80 -t /var/www/html` del `Dockerfile`, el servidor embebido de PHP no reescribe rutas como `/exercises` hacia `index.php` (esa reescritura solo la hace el `.htaccess`, que únicamente aplica bajo Apache). Para usarlo tal cual en Docker probablemente necesites pegarle directo a `api/public/index.php` o agregar un script de enrutamiento al `Dockerfile`.
- **`docker-compose.yml` vs `config.php` desalineados**: como se explica arriba, las variables de entorno `DB_HOST`/`DB_USER`/`DB_PASSWORD` que define Compose no las lee `config.php` (que usa un arreglo hardcodeado); hay que sincronizarlos manualmente.
- **Credenciales en texto plano en el repositorio**: `config.php` y `docker-compose.yml` traen usuarios/contraseñas de base de datos escritos directamente en el código. Antes de desplegar en un entorno real conviene moverlos a variables de entorno y no versionarlos.
- **Modelo `Exercise` sin usar**: existe la clase `models/Exercise.php` pero `ExerciseService` todavía devuelve arreglos asociativos crudos de PDO en vez de instanciar el modelo.
- **`README.md` original vacío**: este documento reemplaza/complementa ese archivo.