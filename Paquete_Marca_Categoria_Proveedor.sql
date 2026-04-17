CREATE OR REPLACE PACKAGE pqMantenimientos AS
    --Marcas
    PROCEDURE insertarMarca(p_nombre VARCHAR2);
    PROCEDURE actualizarMarca(p_idMarca NUMBER, p_nombre VARCHAR2);
    PROCEDURE eliminarMarca(p_idMarca NUMBER);
    PROCEDURE listarMarcas(p_cursor OUT SYS_REFCURSOR);
    --Categorías
    PROCEDURE insertarCategoria(p_nombre VARCHAR2);
    PROCEDURE actualizarCategoria(p_idCategoria NUMBER, p_nombre VARCHAR2);
    PROCEDURE eliminarCategoria(p_idCategoria NUMBER);
    PROCEDURE listarCategorias(p_cursor OUT SYS_REFCURSOR);
    --Proveedor
    PROCEDURE insertarProveedor(p_nombre VARCHAR2, p_correo VARCHAR2, p_tel VARCHAR2);
    PROCEDURE actualizarProveedor(p_idProv NUMBER, p_nombre VARCHAR2, p_correo VARCHAR2, p_tel VARCHAR2);
    PROCEDURE eliminarProveedor(p_idProv NUMBER);
    PROCEDURE listarProveedores(p_cursor OUT SYS_REFCURSOR);
END pqMantenimientos;
/

CREATE OR REPLACE PACKAGE BODY pqMantenimientos AS

    --MARCAS
    PROCEDURE insertarMarca(p_nombre VARCHAR2) IS
    BEGIN
        INSERT INTO Marca (nombre) 
        VALUES (p_nombre);
        COMMIT;
    END;

    PROCEDURE listarMarcas(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT idMarca, nombre 
        FROM Marca 
        ORDER BY nombre;
    END;

    PROCEDURE actualizarMarca(p_idMarca NUMBER, p_nombre VARCHAR2) IS
    BEGIN
        UPDATE Marca 
        SET nombre = p_nombre 
        WHERE idMarca = p_idMarca;
        COMMIT;
    END;

    PROCEDURE eliminarMarca(p_idMarca NUMBER) IS
    BEGIN
        DELETE FROM Marca 
        WHERE idMarca = p_idMarca;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20052, 'No se puede eliminar: Marca en uso por productos.');
    END;

    --CATEGORÍAS
    PROCEDURE insertarCategoria(p_nombre VARCHAR2) IS
    BEGIN
        INSERT INTO Categoria (nombre) 
        VALUES (p_nombre);
        COMMIT;
    END;

    PROCEDURE listarCategorias(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT idCategoria, nombre 
        FROM Categoria 
        ORDER BY nombre;
    END;

    PROCEDURE actualizarCategoria(p_idCategoria NUMBER, p_nombre VARCHAR2) IS
    BEGIN
        UPDATE Categoria 
        SET nombre = p_nombre 
        WHERE idCategoria = p_idCategoria;
        COMMIT;
    END;

    PROCEDURE eliminarCategoria(p_idCategoria NUMBER) IS
    BEGIN
        DELETE FROM Categoria 
        WHERE idCategoria = p_idCategoria;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20053, 'No se puede eliminar: Categoría en uso.');
    END;
    
    --PROVEEDORES
    PROCEDURE insertarProveedor(p_nombre VARCHAR2, p_correo VARCHAR2, p_tel VARCHAR2) IS
    BEGIN
        INSERT INTO Proveedor (nombre, correo, telefono) 
        VALUES (p_nombre, p_correo, p_tel);
        COMMIT;
    END;

    PROCEDURE actualizarProveedor(p_idProv NUMBER, p_nombre VARCHAR2, p_correo VARCHAR2, p_tel VARCHAR2) IS
    BEGIN
        UPDATE Proveedor 
        SET nombre = p_nombre, correo = p_correo, telefono = p_tel 
        WHERE idProveedor = p_idProv;
        COMMIT;
    END;

    PROCEDURE eliminarProveedor(p_idProv NUMBER) IS
    BEGIN
        DELETE FROM Proveedor 
        WHERE idProveedor = p_idProv;
        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20082, 'No se puede eliminar: Proveedor con historial de inventario.');
    END;

    PROCEDURE listarProveedores(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT idProveedor, nombre, correo, telefono 
        FROM Proveedor 
        ORDER BY nombre;
    END;

END pqMantenimientos;
/