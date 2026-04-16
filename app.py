from flask import Flask, render_template, request, redirect
import db

app = Flask(__name__)

@app.route("/")
def productos():
    listaProductos = db.obtener_productos()
    return render_template("productos.html", productos=listaProductos)

@app.route("/buscar", methods=["POST"])
def buscarProductos():
    criterio = request.form["criterio"]
    resultados = db.buscar_productos(criterio)

    mensaje = None
    if not resultados:
        mensaje = "No se encontraron productos"

    return render_template("productos.html", productos=resultados, mensaje=mensaje)

@app.route("/producto/<int:idProducto>")
def infoProducto(idProducto):
    listaProductos = db.obtener_productos()
    producto = db.infoProducto(idProducto)

    return render_template(
        "productos.html",
        productos=listaProductos,
        producto_seleccionado=producto
    )

@app.route("/eliminarProducto/<int:idProducto>", methods=["POST"])
def eliminarProducto(idProducto):
    db.eliminar_producto(idProducto)
    return redirect("/")

@app.route("/aumentarStock/<int:idProducto>", methods=["POST"])
def aumentarStock(idProducto):
    cantidad = int(request.form["cantidad"])

    try:
        db.aumentarStock(idProducto, cantidad)
    except Exception as e:
        mensaje = str(e)

    listaProductos = db.obtener_productos()
    return render_template("productos.html", productos=listaProductos)

@app.route("/actualizarPrecio/<int:idProducto>", methods=["POST"])
def actualizarPrecio(idProducto):
    precio = float(request.form["precio"])

    try:
        db.actualizarPrecio(idProducto, precio)
    except Exception as e:
        print(e)

    return redirect("/")

@app.route("/usuarios")
def usuarios():
    listaUsuarios = db.obtener_usuarios()
    return render_template("usuarios.html", usuarios=listaUsuarios)

@app.route("/crearUsuario", methods=["GET"])
def vista_crear_usuario():
    roles = db.obtener_roles()
    return render_template("crearUsuario.html", roles=roles)

@app.route("/crearUsuario", methods=["POST"])
def crearUsuario():
    idRol = request.form["rol"]
    nombre = request.form["nombre"]
    apellido1 = request.form["apellido1"]
    apellido2 = request.form["apellido2"]
    correo = request.form["correo"]
    telefono = request.form["telefono"]
    direccion = request.form["direccion"]
    password = request.form["password"]

    try:
        db.crearUsuario(idRol, nombre, apellido1, apellido2, correo, telefono, direccion, password)
    except Exception as e:
        print(e)

    return redirect("/usuarios")

@app.route("/eliminarUsuario/<int:idUsuario>", methods=["POST"])
def eliminarUsuario(idUsuario):
    db.eliminarUsuario(idUsuario)
    return redirect("/usuarios?msg=eliminado")

if __name__ == "__main__":
    app.run(debug=True)