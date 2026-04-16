CREATE OR REPLACE PACKAGE pqProductos AS
    CURSOR cur_todos_productos IS 
        SELECT p.idProducto, p.nombre, m.nombre as Marca, c.nombre as Categoria, i.cantidadDisponible, i.costoUnitario
        FROM Producto p
        JOIN Marca m ON p.idMarca = m.idMarca
        JOIN Categoria c ON p.idCategoria = c.idCategoria
        JOIN Inventario i ON p.idProducto = i.idProducto;

    PROCEDURE MostrarProductos(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE BuscarProducto(p_criterio VARCHAR2,p_cursor OUT SYS_REFCURSOR);
    PROCEDURE EliminarProducto(p_idProducto NUMBER);
    FUNCTION InfoProducto(p_idProducto NUMBER) RETURN SYS_REFCURSOR;
    FUNCTION ConsultarStock(p_idProducto NUMBER) RETURN NUMBER;
END pqProductos;
/

CREATE OR REPLACE PACKAGE BODY pqProductos AS
    PROCEDURE MostrarProductos(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT p.idProducto, p.nombre, m.nombre, c.nombre, i.cantidadDisponible, i.costoUnitario
            FROM Producto p
            JOIN Marca m ON p.idMarca = m.idMarca
            JOIN Categoria c ON p.idCategoria = c.idCategoria
            JOIN Inventario i ON p.idProducto = i.idProducto;
    END;

    PROCEDURE BuscarProducto(p_criterio VARCHAR2,p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT p.idProducto, p.nombre, m.nombre, c.nombre, i.cantidadDisponible, i.costoUnitario
            FROM Producto p JOIN Marca m ON p.idMarca = m.idMarca
            JOIN Categoria c ON p.idCategoria = c.idCategoria
            JOIN Inventario i ON p.idProducto = i.idProducto
            WHERE UPPER(p.nombre) LIKE '%'||UPPER(p_criterio)||'%' 
            OR UPPER(m.nombre) LIKE '%'||UPPER(p_criterio)||'%'
            OR UPPER(c.nombre) LIKE '%'||UPPER(p_criterio)||'%';
    END;

    PROCEDURE EliminarProducto(p_idProducto NUMBER) IS
    BEGIN
        DELETE FROM Inventario 
        WHERE idProducto = p_idProducto;
        DELETE FROM Producto 
        WHERE idProducto = p_idProducto;
        COMMIT;
    END;

    FUNCTION InfoProducto(p_idProducto NUMBER) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR SELECT * 
        FROM vista_productos_completa 
        WHERE idProducto = p_idProducto;
        RETURN v_cursor;
    END;

    FUNCTION ConsultarStock(p_idProducto NUMBER) RETURN NUMBER IS
        v_stock NUMBER;
    BEGIN
        SELECT cantidadDisponible INTO v_stock 
        FROM Inventario 
        WHERE idProducto = p_idProducto;
        RETURN v_stock;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 0;
    END;
END pqProductos;
/

CREATE OR REPLACE PACKAGE pqUsuarios AS
    CURSOR cur_todos_usuarios IS 
        SELECT u.idUsuario, u.nombre, u.apellido1, u.correo, r.nombre AS nombre_rol
        FROM Usuario u 
        JOIN Rol r ON u.idRol = r.idRol;

    FUNCTION listarRoles RETURN SYS_REFCURSOR;
    PROCEDURE ListarUsuarios(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE CrearUsuario(p_idRol NUMBER, p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_apellido2 VARCHAR2, p_correo VARCHAR2, p_telefono VARCHAR2, p_direccion VARCHAR2, p_password VARCHAR2);
    PROCEDURE ActualizarUsuario(p_idUsuario NUMBER, p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_correo VARCHAR2, p_telefono VARCHAR2, p_direccion VARCHAR2);
    PROCEDURE EliminarUsuario(p_idUsuario NUMBER);
    FUNCTION ValidarLogin(p_correo VARCHAR2, p_password VARCHAR2) RETURN NUMBER;
END pqUsuarios;
/

CREATE OR REPLACE PACKAGE BODY pqUsuarios AS
    FUNCTION listarRoles RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
        SELECT idRol, Nombre FROM Rol;
        RETURN v_cursor;
    END;

    PROCEDURE ListarUsuarios(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT u.idUsuario, u.nombre, u.apellido1, u.apellido2, u.correo, r.nombre AS nombre_rol
            FROM Usuario u 
            JOIN Rol r ON u.idRol = r.idRol;
    END;

    PROCEDURE CrearUsuario(p_idRol NUMBER, p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_apellido2 VARCHAR2, p_correo VARCHAR2, p_telefono VARCHAR2, p_direccion VARCHAR2, p_password VARCHAR2) IS
    BEGIN
        INSERT INTO Usuario (idRol, nombre, apellido1, apellido2, correo, telefono, direccion, password)
        VALUES (p_idRol, p_nombre, p_apellido1, p_apellido2, p_correo, p_telefono, p_direccion, p_password);
        COMMIT;
    END;

    PROCEDURE ActualizarUsuario(p_idUsuario NUMBER, p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_correo VARCHAR2, p_telefono VARCHAR2, p_direccion VARCHAR2) IS
        v_existe NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_existe 
        FROM Usuario 
        WHERE idUsuario = p_idUsuario;
        IF v_existe > 0 THEN
            UPDATE Usuario 
            SET nombre = p_nombre, apellido1 = p_apellido1, correo = p_correo, telefono = p_telefono, direccion = p_direccion 
            WHERE idUsuario = p_idUsuario;
            COMMIT;
        END IF;
    END;

    PROCEDURE EliminarUsuario(p_idUsuario NUMBER) IS
    BEGIN
        DELETE FROM DetallePedido WHERE idPedido IN (
            SELECT idPedido FROM Pedido Where idUsuario = p_idUsuario);
        DELETE FROM Pedido WHERE idUsuario = p_idUsuario;
        DELETE FROM Usuario WHERE idUsuario = p_idUsuario;
        COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Error al eliminar el usuario: ' || SQLERRM);
    END;

    FUNCTION ValidarLogin(p_correo VARCHAR2, p_password VARCHAR2) RETURN NUMBER IS
        v_idUsuario NUMBER;
    BEGIN
        SELECT idUsuario INTO v_idUsuario 
        FROM Usuario WHERE correo = p_correo AND password = p_password;
        RETURN v_idUsuario;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;
END pqUsuarios;
/
