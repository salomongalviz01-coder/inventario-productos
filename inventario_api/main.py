from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

import models
import schemas
from database import Base, engine, get_db

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API de Inventario")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def codigo_en_uso(db: Session, codigo: str, excluir_id: int | None = None) -> bool:
    consulta = db.query(models.Producto).filter(models.Producto.codigo == codigo)
    if excluir_id is not None:
        consulta = consulta.filter(models.Producto.id != excluir_id)
    return consulta.first() is not None


@app.get("/api/productos", response_model=list[schemas.ProductoSalida])
def listar_productos(db: Session = Depends(get_db)):
    return db.query(models.Producto).order_by(models.Producto.id).all()


@app.get("/api/productos/{id}", response_model=schemas.ProductoSalida)
def obtener_producto(id: int, db: Session = Depends(get_db)):
    producto = db.get(models.Producto, id)
    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return producto


@app.post("/api/productos", response_model=schemas.ProductoSalida, status_code=201)
def crear_producto(datos: schemas.ProductoEntrada, db: Session = Depends(get_db)):
    if codigo_en_uso(db, datos.codigo):
        raise HTTPException(status_code=422, detail="Ya existe un producto con ese código")
    producto = models.Producto(**datos.model_dump())
    db.add(producto)
    db.commit()
    db.refresh(producto)
    return producto


@app.put("/api/productos/{id}", response_model=schemas.ProductoSalida)
def actualizar_producto(id: int, datos: schemas.ProductoEntrada, db: Session = Depends(get_db)):
    producto = db.get(models.Producto, id)
    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    if codigo_en_uso(db, datos.codigo, excluir_id=id):
        raise HTTPException(status_code=422, detail="Ya existe un producto con ese código")
    for campo, valor in datos.model_dump().items():
        setattr(producto, campo, valor)
    db.commit()
    db.refresh(producto)
    return producto


@app.delete("/api/productos/{id}")
def eliminar_producto(id: int, db: Session = Depends(get_db)):
    producto = db.get(models.Producto, id)
    if producto is None:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    db.delete(producto)
    db.commit()
    return {"mensaje": "Producto eliminado correctamente"}