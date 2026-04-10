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

    ref_cursor = conn.cursor()

    cursor.callproc("pqProductos.MostrarProductos", [ref_cursor])
    datos = ref_cursor.fetchall()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return datos

def buscar_productos(criterio):
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = conn.cursor()

    cursor.callproc("pqProductos.BuscarProducto", [criterio, ref_cursor])
    datos = ref_cursor.fetchall()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return datos

def obtener_usuarios():
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = conn.cursor()

    cursor.callproc("pqUsuarios.ListarUsuarios", [ref_cursor])
    datos = ref_cursor.fetchall()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return datos

