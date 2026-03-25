from flask import Flask, render_template
import db

app = Flask(__name__)

@app.route("/")
def productos():
    lista = db.obtener_productos()
    return render_template("productos.html", productos=lista)

if __name__ == "__main__":
    app.run(debug=True)