from database import Base, engine, SessionLocal
import models

Base.metadata.create_all(bind=engine)

productos = [
    ("Arroz 500g", "ALI-001", "Arroz blanco", 2500, 120, "Alimentos"),
    ("Aceite 1L", "ALI-002", "Aceite vegetal", 9800, 60, "Alimentos"),
    ("Leche entera 1L", "LAC-001", "Leche larga vida", 4200, 80, "Lácteos"),
    ("Queso campesino", "LAC-002", "Queso fresco 500g", 12500, 25, "Lácteos"),
    ("Jabón de baño", "ASE-001", "Jabón en barra", 2300, 150, "Aseo"),
    ("Detergente 1kg", "ASE-002", "Detergente en polvo", 11900, 40, "Aseo"),
    ("Gaseosa 1.5L", "BEB-001", "Bebida gaseosa", 5200, 90, "Bebidas"),
    ("Agua 600ml", "BEB-002", "Agua sin gas", 1800, 200, "Bebidas"),
    ("Cuaderno 100 hojas", "PAP-001", "Cuaderno rayado", 4500, 70, "Papelería"),
    ("Lápiz HB", "PAP-002", "Lápiz de grafito", 900, 300, "Papelería"),
]

db = SessionLocal()
if db.query(models.Producto).count() == 0:
    for nombre, codigo, descripcion, precio, cantidad, categoria in productos:
        db.add(models.Producto(
            nombre=nombre, codigo=codigo, descripcion=descripcion,
            precio=precio, cantidad=cantidad, categoria=categoria,
        ))
    db.commit()
    print("10 productos de prueba registrados")
else:
    print("La base de datos ya tiene productos")
db.close()