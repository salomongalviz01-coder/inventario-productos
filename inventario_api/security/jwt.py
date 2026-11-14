
import os
from pathlib import Path
from datetime import datetime, timedelta, timezone

import jwt
from dotenv import load_dotenv


# ==========================================
# CONFIGURACION DE VARIABLES DE ENTORNO
# ==========================================

BASE_DIR = Path(__file__).resolve().parent.parent

# Cargar variables del archivo .env
load_dotenv(BASE_DIR / ".env")

# Clave secreta para firmar los tokens
SECRET_KEY = os.getenv("JWT_SECRET_KEY")

# Algoritmo de encriptacion/firma
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

# Tiempo de expiracion del token
ACCESS_TOKEN_EXPIRE_MINUTES = int(
    os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "30")
)


# Validar configuracion
if not SECRET_KEY or len(SECRET_KEY) < 32:
    raise RuntimeError(
        "JWT_SECRET_KEY no esta configurada correctamente "
        "en el archivo .env"
    )


# ==========================================
# GENERACION DE TOKEN JWT
# ==========================================

def create_access_token(
        data: dict,
        expires_delta: timedelta | None = None
) -> str:

    # Copiar los datos que tendra el token
    to_encode = data.copy()

    # Fecha y hora actual
    now = datetime.now(timezone.utc)

    # Calcular expiracion
    expire = now + (
        expires_delta
        if expires_delta
        else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    # Agregar fechas de emision y expiracion
    to_encode.update({
        "iat": now,
        "exp": expire
    })

    # Generar y firmar JWT
    encoded_jwt = jwt.encode(
        to_encode,
        SECRET_KEY,
        algorithm=ALGORITHM
    )

    return encoded_jwt


# ==========================================
# VALIDACION Y DECODIFICACION DEL TOKEN
# ==========================================

def decode_access_token(token: str) -> dict:

    # Verificar firma, algoritmo y expiracion
    payload = jwt.decode(
        token,
        SECRET_KEY,
        algorithms=[ALGORITHM]
    )

    return payload
