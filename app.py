from flask import Flask, render_template, request, redirect, session
from functools import wraps
import db

app = Flask(__name__)
app.secret_key = "3lectr0Tiend4"

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if "usuario" not in session:
            return redirect("/")
        return f(*args, **kwargs)
    return decorated_function

@app.route("/", methods=["GET"])
def login_view():
    return render_template("login.html")

@app.route("/login", methods=["POST"])
def login():
    correo = request.form["correo"]
    password = request.form["password"]

    resultado = db.loginUsuario(correo, password)

    if resultado == 1:
        session["usuario"] = correo
        return redirect("/productos")
    else:
        return render_template("login.html", error="Credenciales de Administrador inválidas")

@app.route("/productos")
@login_required
def productos():
    listaProductos = db.obtener_productos()
    return render_template("productos.html", productos=listaProductos)

@app.route("/buscar", methods=["POST"])
@login_required
def buscarProductos():
    criterio = request.form["criterio"]
    resultados = db.buscar_productos(criterio)

    mensaje = None
    if not resultados:
        mensaje = "No se encontraron productos"

    return render_template("productos.html", productos=resultados, mensaje=mensaje)

@app.route("/producto/<int:idProducto>")
@login_required
def infoProducto(idProducto):
    listaProductos = db.obtener_productos()
    producto = db.infoProducto(idProducto)

    return render_template(
        "productos.html",
        productos=listaProductos,
        producto_seleccionado=producto
    )

@app.route("/eliminarProducto/<int:idProducto>", methods=["POST"])
@login_required
def eliminarProducto(idProducto):
    db.eliminar_producto(idProducto)
    return redirect("/productos")

@app.route("/aumentarStock/<int:idProducto>", methods=["POST"])
@login_required
def aumentarStock(idProducto):
    cantidad = int(request.form["cantidad"])

    try:
        db.aumentarStock(idProducto, cantidad)
    except Exception as e:
        mensaje = str(e)

    listaProductos = db.obtener_productos()
    return render_template("productos.html", productos=listaProductos)

@app.route("/actualizarPrecio/<int:idProducto>", methods=["POST"])
@login_required
def actualizarPrecio(idProducto):
    precio = float(request.form["precio"])

    try:
        db.actualizarPrecio(idProducto, precio)
    except Exception as e:
        print(e)

    return redirect("/productos")

@app.route("/usuarios")
@login_required
def usuarios():
    listaUsuarios = db.obtener_usuarios()
    return render_template("usuarios.html", usuarios=listaUsuarios)

@app.route("/crearUsuario", methods=["GET"])
@login_required
def vista_crear_usuario():
    roles = db.obtener_roles()
    return render_template("crearUsuario.html", roles=roles)

@app.route("/crearUsuario", methods=["POST"])
@login_required
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
@login_required
def eliminarUsuario(idUsuario):
    db.eliminarUsuario(idUsuario)
    return redirect("/usuarios?msg=eliminado")

@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")

if __name__ == "__main__":
    app.run(debug=True)