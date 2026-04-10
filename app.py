from flask import Flask, render_template, request
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

@app.route("/usuarios")
def usuarios():
    listaUsuarios = db.obtener_usuarios()
    return render_template("usuarios.html", usuarios=listaUsuarios)

if __name__ == "__main__":
    app.run(debug=True)