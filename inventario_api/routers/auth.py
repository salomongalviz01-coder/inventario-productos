
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pwdlib import PasswordHash

import models
import schemas

from database import get_db
from security.jwt import create_access_token
from security.dependencies import get_current_user


router = APIRouter(
    prefix="/api/auth",
    tags=["Autenticación"]
)

password_hash = PasswordHash.recommended()


# ==========================================
# REGISTRO DE USUARIOS
# ==========================================

@router.post(
    "/register",
    response_model=schemas.UsuarioSalida,
    status_code=status.HTTP_201_CREATED
)
def registrar_usuario(
        datos: schemas.UsuarioRegistro,
        db: Session = Depends(get_db)
):

    correo = datos.correo.strip().lower()

    usuario_existente = (
        db.query(models.Usuario)
        .filter(models.Usuario.correo == correo)
        .first()
    )

    if usuario_existente:
        raise HTTPException(
            status_code=409,
            detail="El correo ya se encuentra registrado"
        )

    nuevo_usuario = models.Usuario(
        nombre=datos.nombre,
        correo=correo,
        password_hash=password_hash.hash(datos.password),
        activo=True
    )

    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)

    return nuevo_usuario


# ==========================================
# INICIO DE SESION
# ==========================================

@router.post(
    "/login",
    response_model=schemas.TokenSalida
)
def iniciar_sesion(
        datos: schemas.LoginEntrada,
        db: Session = Depends(get_db)
):

    correo = datos.correo.strip().lower()

    usuario = (
        db.query(models.Usuario)
        .filter(models.Usuario.correo == correo)
        .first()
    )

    if not usuario or not password_hash.verify(
            datos.password,
            usuario.password_hash
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos"
        )

    if not usuario.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario desactivado"
        )

    access_token = create_access_token({
        "sub": str(usuario.id)
    })

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "usuario": usuario
    }


# ==========================================
# CONSULTAR USUARIO AUTENTICADO
# ==========================================

@router.get(
    "/me",
    response_model=schemas.UsuarioSalida
)
def obtener_usuario_actual(
        usuario: models.Usuario = Depends(get_current_user)
):

    return usuario
