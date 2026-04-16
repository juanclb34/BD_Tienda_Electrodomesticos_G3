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

def loginUsuario(correo, password):
    conn = get_connection()
    cursor = conn.cursor()

    resultado = cursor.var(int)

    cursor.callproc("pqUsuarios.ValidarLogin", [
        correo,
        password,
        resultado
    ])

    valor = resultado.getvalue()

    cursor.close()
    conn.close()

    return valor

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

def infoProducto(idProducto):
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = cursor.callfunc("pqProductos.InfoProducto",
        oracledb.CURSOR, [idProducto])

    dato = ref_cursor.fetchone()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return dato

def aumentarStock(idProducto, cantidad):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.callproc("pqInventario.aumentarStock", [idProducto, cantidad])

    cursor.close()
    conn.close()

def actualizarPrecio(idProducto, precio):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.callproc("pqInventario.actualizarPrecioUnitario", [idProducto, precio])

    cursor.close()
    conn.close()

def eliminar_producto(id_producto):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.callproc("pqProductos.EliminarProducto", [id_producto])

    cursor.close()
    conn.close()

def crearProducto(datos):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.callproc("pqProductos.CrearProductoInventario", [
        datos["marca"],
        datos["categoria"],
        datos["nombre"],
        datos["modelo"],
        datos["descripcion"],
        datos["proveedor"],
        datos["cantidad"],
        datos["minimo"],
        datos["costo"]
    ])

    cursor.close()
    conn.close()

def obtenerProveedores():
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = cursor.callfunc("pqInventario.ObtenerProveedores",
        oracledb.CURSOR)

    datos = ref_cursor.fetchall()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return datos

def obtenerMarcas():
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = cursor.callfunc("pqInventario.ObtenerMarcas", oracledb.CURSOR)
    datos = ref_cursor.fetchall()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return datos

def obtenerCategorias():
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = cursor.callfunc("pqInventario.ObtenerCategorias", oracledb.CURSOR)
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

def obtener_roles():
    conn = get_connection()
    cursor = conn.cursor()

    ref_cursor = cursor.callfunc("pqUsuarios.listarRoles", oracledb.CURSOR)

    dato = ref_cursor.fetchall()

    ref_cursor.close()
    cursor.close()
    conn.close()

    return dato

def crearUsuario(idRol, nombre, apellido1, apellido2, correo, telefono, direccion, password):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.callproc("pqUsuarios.CrearUsuario", [
        idRol,
        nombre,
        apellido1,
        apellido2,
        correo,
        telefono,
        direccion,
        password
    ])

    cursor.close()
    conn.close()

def eliminarUsuario(idUsuario):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.callproc("pqUsuarios.EliminarUsuario", [idUsuario])

    cursor.close()
    conn.close()

