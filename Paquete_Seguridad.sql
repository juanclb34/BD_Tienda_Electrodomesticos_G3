CREATE OR REPLACE PACKAGE pqSeguridad AS
    --Roles
    PROCEDURE insertarRol(p_nombre VARCHAR2);
    PROCEDURE actualizarRol(p_idRol NUMBER, p_nombre VARCHAR2);
    PROCEDURE eliminarRol(p_idRol NUMBER);
    PROCEDURE listarRoles(p_cursor OUT SYS_REFCURSOR);
    
    --Gestión de Permisos de un Usuario
    PROCEDURE cambiarRolUsuario(p_idUsuario NUMBER, p_idRolNuevo NUMBER);
END pqSeguridad;
/

CREATE OR REPLACE PACKAGE BODY pqSeguridad AS

    PROCEDURE insertarRol(p_nombre VARCHAR2) IS
    BEGIN
        INSERT INTO Rol (nombre) 
        VALUES (p_nombre);
        COMMIT;
    END;

    PROCEDURE actualizarRol(p_idRol NUMBER, p_nombre VARCHAR2) IS
    BEGIN
        UPDATE Rol 
        SET nombre = p_nombre 
        WHERE idRol = p_idRol;
        COMMIT;
    END;

    PROCEDURE eliminarRol(p_idRol NUMBER) IS
    BEGIN
        DELETE FROM Rol 
        WHERE idRol = p_idRol;
        COMMIT;
    EXCEPTION WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20090, 'No se puede eliminar: Hay usuarios con este rol.');
    END;

    PROCEDURE listarRoles(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT idRol, nombre 
        FROM Rol 
        ORDER BY idRol;
    END;

    PROCEDURE cambiarRolUsuario(p_idUsuario NUMBER, p_idRolNuevo NUMBER) IS
    BEGIN
        UPDATE Usuario 
        SET idRol = p_idRolNuevo 
        WHERE idUsuario = p_idUsuario;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20091, 'Usuario no encontrado.');
        END IF;
        COMMIT;
    END;

END pqSeguridad;
/