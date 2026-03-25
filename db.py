import oracledb
import os
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    connection = oracledb.connect(
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        dsn=os.getenv("DB_DSN"),
        config_dir=os.getenv("WALLET_PATH"),
        wallet_location=os.getenv("WALLET_PATH"),
        wallet_password=os.getenv("WALLET_PASSWORD")
    )
    return connection

def obtener_productos():
    conn = get_connection()
    cursor = conn.cursor()

    query = """
    SELECT 
        p.idProducto,
        p.nombre,
        m.nombre AS Marca,
        c.nombre AS Categoria,
        i.cantidadDisponible,
        i.costoUnitario
    FROM Producto p JOIN Marca m ON p.idMarca = m.idMarca
    JOIN Categoria c ON p.idCategoria = c.idCategoria
    JOIN Inventario i ON p.idProducto = i.idProducto"""

    cursor.execute(query)
    datos = cursor.fetchall()

    cursor.close()
    conn.close()

    return datos