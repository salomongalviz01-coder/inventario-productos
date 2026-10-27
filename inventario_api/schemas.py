from pydantic import BaseModel, Field


class ProductoEntrada(BaseModel):
    model_config = {"str_strip_whitespace": True}

    nombre: str = Field(min_length=1, max_length=100)
    codigo: str = Field(min_length=1, max_length=50)
    descripcion: str | None = Field(default=None, max_length=255)
    precio: float = Field(gt=0)
    cantidad: int = Field(ge=0)
    categoria: str = Field(min_length=1, max_length=50)


class ProductoSalida(ProductoEntrada):
    model_config = {"from_attributes": True}

    id: int