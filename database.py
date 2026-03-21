import oracledb
import os

USER = "ADMIN"
PASSWORD = "Sofi051217."

DSN = "basedatoslenguajes_low"

WALLET_PATH = os.path.join(os.getcwd(), 'wallet')

def conexionBD():
    try:
        conn = oracledb.connect(
            user=USER,
            password=PASSWORD,
            dsn=DSN,
            config_dir=WALLET_PATH,
            wallet_password="G3.ElectroTienda!"
        )
        return conn
    except Exception as e:
        print(f"Error de conexion: {e}")
        return None
