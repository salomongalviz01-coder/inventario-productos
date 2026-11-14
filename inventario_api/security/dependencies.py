
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

import jwt
import models

from database import get_db
from security.jwt import decode_access_token


# ==========================================
# CONFIGURACION DE AUTENTICACION
# ==========================================

security_scheme = HTTPBearer(auto_error=False)


# ==========================================
# OBTENER USUARIO AUTENTICADO
# ==========================================

def get_current_user(
        credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
        db: Session = Depends(get_db)
):

    # 1. Verificar que exista el encabezado Bearer
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No se proporciono un token de autenticacion",
            headers={"WWW-Authenticate": "Bearer"}
        )

    # 2. Obtener el token
    token = credentials.credentials

    # 3. Validar y decodificar JWT
    try:
        payload = decode_access_token(token)

        # Obtener identificador del usuario
        user_id = payload.get("sub")

        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token sin identificador de usuario",
                headers={"WWW-Authenticate": "Bearer"}
            )

        # Convertir identificador a entero
        user_id = int(user_id)

    except (jwt.InvalidTokenError, ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalido o expirado",
            headers={"WWW-Authenticate": "Bearer"}
        )

    # 4. Consultar usuario en SQLite
    usuario = (
        db.query(models.Usuario)
        .filter(models.Usuario.id == user_id)
        .first()
    )

    # 5. Verificar que exista
    if usuario is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado",
            headers={"WWW-Authenticate": "Bearer"}
        )

    # 6. Verificar que este activo
    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="El usuario se encuentra desactivado"
        )

    # 7. Retornar usuario autenticado
    return usuario
