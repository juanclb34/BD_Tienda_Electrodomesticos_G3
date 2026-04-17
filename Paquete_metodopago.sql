CREATE OR REPLACE PACKAGE pqFinanzas AS
    --MetodoPago
    PROCEDURE insertarMetodoPago(p_nombre VARCHAR2);
    PROCEDURE actualizarMetodoPago(p_idmetodopago NUMBER, p_nombre VARCHAR2);
    PROCEDURE eliminarMetodoPago(p_idmetodopago NUMBER);
    PROCEDURE listarMetodosPago(p_cursor OUT SYS_REFCURSOR);
END pqFinanzas;
/

CREATE OR REPLACE PACKAGE BODY pqFinanzas AS

    --METODOPAGO
    PROCEDURE insertarMetodoPago(p_nombre VARCHAR2) IS
    BEGIN
        INSERT INTO MetodoPago (nombre) 
        VALUES (p_nombre);
        COMMIT;
    END;

    PROCEDURE listarMetodosPago(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT idmetodopago, nombre 
        FROM MetodoPago 
        ORDER BY nombre;
    END;

    PROCEDURE actualizarMetodoPago(p_idmetodopago NUMBER, p_nombre VARCHAR2) IS
    BEGIN
        UPDATE MetodoPago 
        SET nombre = p_nombre 
        WHERE idmetodopago = p_idmetodopago;
        COMMIT;
    END;

    PROCEDURE eliminarMetodoPago(p_idmetodopago NUMBER) IS
    BEGIN
        DELETE FROM MetodoPago 
        WHERE idmetodopago = p_idmetodopago;
        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20110, 'No se puede eliminar: El método ha sido usado en transacciones.');
    END;

END pqFinanzas;
/