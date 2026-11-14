
from pydantic import BaseModel, Field


# ==========================================
# ESQUEMAS DE PRODUCTOS
# ==========================================

class ProductoEntrada(BaseModel):
    model_config = {"str_strip_whitespace": True}

    nombre: str = Field(min_length=1, max_length=100)
    codigo: str = Field(min_length=1, max_length=50)
    descripcion: str | None = Field(default=None, max_length=255)
    precio: float = Field(ge=0)
    cantidad: int = Field(ge=0)
    categoria: str = Field(min_length=1, max_length=50)


class ProductoSalida(ProductoEntrada):
    model_config = {"from_attributes": True}

    id: int


# ==========================================
# ESQUEMAS DE AUTENTICACION JWT
# ==========================================

class UsuarioRegistro(BaseModel):
    nombre: str = Field(min_length=2, max_length=100)
    correo: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=128)


class LoginEntrada(BaseModel):
    correo: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)


class UsuarioSalida(BaseModel):
    model_config = {"from_attributes": True}

    id: int
    nombre: str
    correo: str
    activo: bool


class TokenSalida(BaseModel):
    access_token: str
    token_type: str = "bearer"
    usuario: UsuarioSalida
