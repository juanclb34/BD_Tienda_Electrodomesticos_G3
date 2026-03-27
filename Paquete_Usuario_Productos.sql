CREATE OR REPLACE PACKAGE pqProductos AS
    CURSOR cur_todos_productos IS 
        SELECT p.idProducto, p.nombre, m.nombre as Marca, c.nombre as Categoria, i.cantidadDisponible, i.costoUnitario
        FROM Producto p
        JOIN Marca m ON p.idMarca = m.idMarca
        JOIN Categoria c ON p.idCategoria = c.idCategoria
        JOIN Inventario i ON p.idProducto = i.idProducto;

    PROCEDURE MostrarProductos(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE BuscarProducto(p_criterio VARCHAR2);
    PROCEDURE EliminarProducto(p_idProducto NUMBER);
    PROCEDURE InsertarInventario(p_idProd NUMBER, p_idProv NUMBER, p_cant NUMBER, p_min NUMBER, p_costo NUMBER);
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

    PROCEDURE BuscarProducto(p_criterio VARCHAR2) IS
    BEGIN
        FOR r IN (SELECT p.nombre, m.nombre as Marca 
                  FROM Producto p JOIN Marca m ON p.idMarca = m.idMarca
                  WHERE UPPER(p.nombre) LIKE '%'||UPPER(p_criterio)||'%' 
                  OR UPPER(m.nombre) LIKE '%'||UPPER(p_criterio)||'%') 
                  LOOP
            DBMS_OUTPUT.PUT_LINE('Encontrado: ' || r.nombre || ' (' || r.Marca || ')');
        END LOOP;
    END;

    PROCEDURE EliminarProducto(p_idProducto NUMBER) IS
    BEGIN
        DELETE FROM Inventario 
        WHERE idProducto = p_idProducto;
        COMMIT;
    END;

    PROCEDURE InsertarInventario(p_idProd NUMBER, p_idProv NUMBER, p_cant NUMBER, p_min NUMBER, p_costo NUMBER) IS
    BEGIN
        INSERT INTO Inventario (idProducto, idProveedor, cantidadDisponible, cantidadMinima, costoUnitario, ultimaFechaIngreso)
        VALUES (p_idProd, p_idProv, p_cant, p_min, p_costo, SYSDATE);
        COMMIT;
    END;

    FUNCTION InfoProducto(p_idProducto NUMBER) RETURN SYS_REFCURSOR IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR SELECT * 
        FROM Producto 
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

    PROCEDURE ListarUsuarios;
    PROCEDURE CrearUsuario(p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_correo VARCHAR2, p_password VARCHAR2);
    PROCEDURE ActualizarUsuario(p_idUsuario NUMBER, p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_correo VARCHAR2, p_telefono VARCHAR2, p_direccion VARCHAR2);
    PROCEDURE EliminarUsuario(p_idUsuario NUMBER);
    FUNCTION ValidarLogin(p_correo VARCHAR2, p_password VARCHAR2) RETURN NUMBER;
END pqUsuarios;
/

CREATE OR REPLACE PACKAGE BODY pqUsuarios AS
    PROCEDURE ListarUsuarios IS
    BEGIN
        FOR r IN cur_todos_usuarios 
        LOOP
            DBMS_OUTPUT.PUT_LINE('ID: '||r.idUsuario||' | '||r.nombre||' '||r.apellido1||' | Rol: '||r.nombre_rol);
        END LOOP;
    END;

    PROCEDURE CrearUsuario(p_nombre VARCHAR2, p_apellido1 VARCHAR2, p_correo VARCHAR2, p_password VARCHAR2) IS
    BEGIN
        INSERT INTO Usuario (idRol, nombre, apellido1, correo, password)
        VALUES (2, p_nombre, p_apellido1, p_correo, p_password);
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
        DELETE FROM Usuario 
        WHERE idUsuario = p_idUsuario;
        COMMIT;
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

