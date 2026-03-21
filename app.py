from flask import Flask, render_template
from database import conexionBD

app = Flask(__name__)

@app.route('/')
def home():
    db = conexionBD()
    if db:
        cursor = db.cursor()
        cursor.execute("SELECT nombre,precio,stock FROM PRODUCTO")

        productos = []
        for fila in cursor:
            productos.append({"nombre": fila[0], "precio": fila[1], "stock": fila[2]})
        cursor.close()
        db.close()
        return render_template('index.html', productos=productos)
    else:
        return "<h1>Error: No se pudo conectar a la base de datos</h1>"
if __name__ == '__main__':
    app.run(debug=True)
