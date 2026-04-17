CREATE OR REPLACE PACKAGE pqFacturacion AS
    PROCEDURE generarFactura(p_idPedido NUMBER);
    PROCEDURE obtenerFactura(p_idFactura NUMBER, p_cursor OUT SYS_REFCURSOR);
    PROCEDURE listarFacturas(p_cursor OUT SYS_REFCURSOR);
    PROCEDURE eliminarFactura(p_idFactura NUMBER);
END pqFacturacion;
/

CREATE OR REPLACE PACKAGE BODY pqFacturacion AS

    PROCEDURE generarFactura(p_idPedido NUMBER) IS
    BEGIN
        INSERT INTO Factura (idPedido, fecha)
        VALUES (p_idPedido, SYSDATE);
        
        UPDATE Pedido SET estado = 'Completado' WHERE idPedido = p_idPedido;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20115, 'No se pudo generar la Factura. Error: ' || SQLERRM);
    END;

    PROCEDURE obtenerFactura(p_idFactura NUMBER, p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT * 
        FROM Factura 
        WHERE idFactura = p_idFactura;
    END;

    PROCEDURE listarFacturas(p_cursor OUT SYS_REFCURSOR) IS
    BEGIN
        OPEN p_cursor FOR 
        SELECT * 
        FROM Factura 
        ORDER BY fecha DESC;
    END;

    PROCEDURE eliminarFactura(p_idFactura NUMBER) IS
    BEGIN
        DELETE FROM Factura 
        WHERE idFactura = p_idFactura;
        COMMIT;
    END;

END pqFacturacion;
/