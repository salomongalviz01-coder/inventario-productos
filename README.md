# Inventario de productos

Solución para la gestión de inventario de un establecimiento comercial, compuesta por una **API REST con persistencia en base de datos** y una **aplicación Flutter** que la consume mediante Dio.

Proyecto del Segundo Parcial Práctico de Electiva Profesional I (Ingeniería de Sistemas).

**Autor:** Salomon Galviz Cabrera — código estudiantil 230232004

## Estructura del repositorio

```
.
├── inventario_api/   # Backend (FastAPI + SQLite)
└── inventario_app/   # Frontend móvil (Flutter)
```

## Tecnologías

### Backend (`inventario_api`)
- Python
- FastAPI (framework web de la API)
- Uvicorn (servidor ASGI)
- SQLAlchemy (ORM)
- SQLite (base de datos, archivo `inventario.db`)
- Pydantic (validación de datos)

### Frontend (`inventario_app`)
- Flutter
- Dio (peticiones HTTP)
- go_router (navegación)
- flutter_dotenv (URL base de la API en un archivo `.env`)

## Backend: instalación y ejecución

Requisitos: Python 3.10 o superior.

```powershell
cd inventario_api
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn main:app --reload
```

La API queda disponible en `http://localhost:8000`.

La documentación interactiva (Swagger UI) está en `http://localhost:8000/docs`, desde donde se pueden probar todos los endpoints.

### Base de datos

La API usa **SQLite**. El archivo `inventario.db` se crea automáticamente al iniciar la API si no existe, y los datos se conservan al reiniciarla.

El archivo `seed.py` carga los productos de prueba:

```powershell
python seed.py
```

Tabla de productos:

| Campo | Tipo | Descripción |
|---|---|---|
| `id` | Entero | Identificador único y autogenerado |
| `nombre` | Texto | Nombre del producto (obligatorio) |
| `codigo` | Texto | Código único del producto (obligatorio) |
| `descripcion` | Texto | Descripción adicional (opcional) |
| `precio` | Decimal | Precio unitario, mayor que 0 |
| `cantidad` | Entero | Unidades disponibles, 0 o más |
| `categoria` | Texto | Categoría del producto (obligatorio) |

### Endpoints

| Método | Endpoint | Funcionalidad | Respuestas |
|---|---|---|---|
| GET | `/api/productos` | Listar todos los productos | 200 |
| GET | `/api/productos/{id}` | Consultar el detalle de un producto | 200, 404 |
| POST | `/api/productos` | Registrar un producto nuevo | 201, 422 |
| PUT | `/api/productos/{id}` | Actualizar un producto existente | 200, 404, 422 |
| DELETE | `/api/productos/{id}` | Eliminar un producto | 200, 404 |

### Validaciones

- `nombre`: obligatorio, de 1 a 100 caracteres.
- `codigo`: obligatorio, de 1 a 50 caracteres y **único** (si ya existe otro producto con ese código, la API responde 422).
- `descripcion`: opcional, hasta 255 caracteres.
- `precio`: obligatorio y mayor que 0.
- `cantidad`: obligatoria, entera y mayor o igual a 0.
- `categoria`: obligatoria, de 1 a 50 caracteres.
- Los espacios al inicio y al final de los textos se eliminan automáticamente.

### Códigos de respuesta

| Código | Cuándo se devuelve |
|---|---|
| 200 | Consulta, actualización o eliminación exitosa |
| 201 | Producto creado |
| 404 | No existe un producto con ese `id` |
| 422 | Datos inválidos o código de producto repetido |

### Ejemplos de peticiones y respuestas

**Listar productos**

```
GET /api/productos
```

```json
[
  {
    "nombre": "Arroz 500g",
    "codigo": "ALI-001",
    "descripcion": "Arroz blanco",
    "precio": 2500,
    "cantidad": 120,
    "categoria": "Alimentos",
    "id": 1
  }
]
```

**Consultar un producto**

```
GET /api/productos/1
```

```json
{
  "nombre": "Arroz 500g",
  "codigo": "ALI-001",
  "descripcion": "Arroz blanco",
  "precio": 2500,
  "cantidad": 120,
  "categoria": "Alimentos",
  "id": 1
}
```

**Registrar un producto**

```
POST /api/productos
Content-Type: application/json
```

```json
{
  "nombre": "Producto de prueba",
  "codigo": "PRU-001",
  "descripcion": "Producto de ejemplo",
  "precio": 1000,
  "cantidad": 5,
  "categoria": "Pruebas"
}
```

Respuesta `201 Created`:

```json
{
  "nombre": "Producto de prueba",
  "codigo": "PRU-001",
  "descripcion": "Producto de ejemplo",
  "precio": 1000,
  "cantidad": 5,
  "categoria": "Pruebas",
  "id": 11
}
```

**Actualizar un producto**

```
PUT /api/productos/11
Content-Type: application/json
```

```json
{
  "nombre": "Producto de prueba",
  "codigo": "PRU-001",
  "descripcion": "Producto de ejemplo",
  "precio": 1200,
  "cantidad": 8,
  "categoria": "Pruebas"
}
```

**Eliminar un producto**

```
DELETE /api/productos/11
```

```json
{
  "mensaje": "Producto eliminado correctamente"
}
```

**Error: producto no encontrado (404)**

```json
{
  "detail": "Producto no encontrado"
}
```

**Error: código repetido (422)**

```json
{
  "detail": "Ya existe un producto con ese código"
}
```

**Error: datos inválidos (422)**

Por ejemplo, un `precio` igual a 0:

```json
{
  "detail": [
    {
      "type": "greater_than",
      "loc": ["body", "precio"],
      "msg": "Input should be greater than 0"
    }
  ]
}
```

## Frontend: instalación y ejecución

Requisitos: Flutter SDK y Google Chrome. La API debe estar corriendo.

1. Entrar a la carpeta de la app:

   ```powershell
   cd inventario_app
   ```

2. Crear el archivo `.env` a partir del ejemplo (el `.env` no se sube al repositorio):

   ```powershell
   copy .env.example .env
   ```

   Contenido del archivo:

   ```
   API_URL=http://localhost:8000
   ```

3. Instalar las dependencias y ejecutar:

   ```powershell
   flutter pub get
   flutter run -d chrome
   ```

### Funcionalidades

- **Dashboard:** total de productos, total de unidades disponibles y valor económico del inventario (suma de precio × cantidad). Los valores se calculan con los datos reales de la API y se actualizan al modificar productos.
- **Listado:** nombre, código, categoría, precio y cantidad de cada producto, con actualización al arrastrar hacia abajo.
- **Detalle:** todos los datos del producto seleccionado.
- **Registro y edición:** formulario con validaciones (campos obligatorios, precio mayor que 0 y cantidad sin negativos) y mensajes claros si la operación se completa o falla.
- **Eliminación:** con cuadro de confirmación.
- **Estados de la interfaz:** carga, error con botón de reintento y ausencia de registros.
- **Navegación:** `go_router` con menú inferior entre Inicio y Productos.

### Organización del proyecto Flutter

```
lib/
├── config/         # Rutas de la aplicación (go_router)
├── controllers/    # Estado y lógica de los productos
├── models/         # Modelo Producto
├── screens/        # Pantallas: dashboard, lista, detalle y formulario
├── services/       # ApiService: comunicación con la API mediante Dio
├── widgets/        # Componentes reutilizables (menú inferior)
└── main.dart
```

Las peticiones HTTP se hacen únicamente en `ApiService`, y los errores de comunicación se convierten en excepciones (`ApiException`) con mensajes legibles para el usuario. Los widgets no realizan peticiones directamente.

## Despliegue

La API se ejecuta de forma local. No se realizó despliegue público.

## Seguridad

El repositorio no contiene contraseñas, credenciales ni secretos. El archivo `.env` está excluido mediante `.gitignore`.