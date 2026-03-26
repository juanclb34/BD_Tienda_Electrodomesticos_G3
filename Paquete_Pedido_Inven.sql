-- Crear Paquete de Pedido

CREATE OR REPLACE PACKAGE pqPedidos AS

-- Procedimientos
PROCEDURE agregarProductoPedido(
    p_idPedido NUMBER,
    p_idProducto NUMBER,
    p_cantidad NUMBER
);

PROCEDURE verDetallePedido(
    p_idPedido NUMBER,
    p_cursor OUT SYS_REFCURSOR
);

-- Funciones
FUNCTION crearPedido(
    p_idUsuario NUMBER
) RETURN NUMBER;

FUNCTION calcularTotalPedido(
    p_idPedido NUMBER
) RETURN NUMBER;

END pqPedidos;
/

CREATE OR REPLACE PACKAGE BODY pqPedidos AS

-- FUNCION crear pedido
FUNCTION crearPedido(p_idUsuario NUMBER) RETURN NUMBER IS
    v_idPedido NUMBER;
BEGIN
    SELECT NVL(MAX(idPedido),0)+1 INTO v_idPedido FROM Pedido;

    INSERT INTO Pedido(idPedido,idUsuario,estado,fechaPedido)
    VALUES(v_idPedido,p_idUsuario,'PENDIENTE',SYSDATE);

    RETURN v_idPedido;
END;

-- PROCEDIMIENTO agregar producto
PROCEDURE agregarProductoPedido(
    p_idPedido NUMBER,
    p_idProducto NUMBER,
    p_cantidad NUMBER
) IS
    v_precio NUMBER;
BEGIN
    SELECT precioUnitario
    INTO v_precio
    FROM Inventario
    WHERE idProducto = p_idProducto;

    INSERT INTO DetallePedido(
        idDetalle,
        idPedido,
        idProducto,
        cantidad,
        precioUnitario
    )
    VALUES(
        NVL((SELECT MAX(idDetalle)+1 FROM DetallePedido),1),
        p_idPedido,
        p_idProducto,
        p_cantidad,
        v_precio
    );
END;

-- CURSOR procedimiento detalle
PROCEDURE verDetallePedido(
    p_idPedido NUMBER,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
        SELECT dp.idPedido,
               pr.nombre,
               dp.cantidad,
               dp.precioUnitario,
               (dp.cantidad * dp.precioUnitario) subtotal
        FROM DetallePedido dp
        JOIN Producto pr ON dp.idProducto = pr.idProducto
        WHERE dp.idPedido = p_idPedido;
END;

-- FUNCION calcular total
FUNCTION calcularTotalPedido(p_idPedido NUMBER) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(cantidad * precioUnitario)
    INTO v_total
    FROM DetallePedido
    WHERE idPedido = p_idPedido;

    RETURN NVL(v_total,0);
END;

END pqPedidos;
/

CREATE OR REPLACE PACKAGE BODY pqPedidos AS

-- Crear pedido
FUNCTION crearPedido(p_idUsuario NUMBER) RETURN NUMBER IS
    v_idPedido NUMBER;
BEGIN
    SELECT NVL(MAX(IDPEDIDO),0)+1 INTO v_idPedido FROM PEDIDO;

    INSERT INTO PEDIDO(IDPEDIDO,IDUSUARIO,FECHA,ESTADO)
    VALUES(v_idPedido,p_idUsuario,SYSDATE,'PENDIENTE');

    RETURN v_idPedido;
END;

-- Agregar producto
PROCEDURE agregarProductoPedido(
    p_idPedido NUMBER,
    p_idProducto NUMBER,
    p_cantidad NUMBER
) IS
    v_precio NUMBER;
BEGIN
    SELECT COSTOUNITARIO
    INTO v_precio
    FROM INVENTARIO
    WHERE IDPRODUCTO = p_idProducto;

    INSERT INTO DETALLEPEDIDO(
        IDPEDIDO,
        IDPRODUCTO,
        CANTIDAD,
        PRECIOUNITARIO
    )
    VALUES(
        p_idPedido,
        p_idProducto,
        p_cantidad,
        v_precio
    );
END;

-- Cursor detalle pedido
PROCEDURE verDetallePedido(
    p_idPedido NUMBER,
    p_cursor OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_cursor FOR
        SELECT dp.IDPEDIDO,
               pr.NOMBRE,
               dp.CANTIDAD,
               dp.PRECIOUNITARIO,
               (dp.CANTIDAD * dp.PRECIOUNITARIO) SUBTOTAL
        FROM DETALLEPEDIDO dp
        JOIN PRODUCTO pr ON dp.IDPRODUCTO = pr.IDPRODUCTO
        WHERE dp.IDPEDIDO = p_idPedido;
END;

-- Calcular total
FUNCTION calcularTotalPedido(p_idPedido NUMBER) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(CANTIDAD * PRECIOUNITARIO)
    INTO v_total
    FROM DETALLEPEDIDO
    WHERE IDPEDIDO = p_idPedido;

    RETURN NVL(v_total,0);
END;

END pqPedidos;
/

SET SERVEROUTPUT ON;

DECLARE
    v_idPedido NUMBER;
BEGIN
    v_idPedido := pqPedidos.crearPedido(1);
    DBMS_OUTPUT.PUT_LINE('Pedido creado: ' || v_idPedido);
END;
/

BEGIN
    pqPedidos.agregarProductoPedido(3,1,3);
END;
/

SELECT * 
FROM DETALLEPEDIDO
WHERE IDPEDIDO = 3;

DECLARE
    v_total NUMBER;
BEGIN
    v_total := pqPedidos.calcularTotalPedido(5);
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total);
END;
/

DECLARE
    c SYS_REFCURSOR;
    v_idPedido NUMBER;
    v_nombre VARCHAR2(100);
    v_cantidad NUMBER;
    v_precio NUMBER;
    v_subtotal NUMBER;
BEGIN
    pqPedidos.verDetallePedido(3,c);

    LOOP
        FETCH c INTO v_idPedido,v_nombre,v_cantidad,v_precio,v_subtotal;
        EXIT WHEN c%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_nombre || ' - ' || v_subtotal);
    END LOOP;

    CLOSE c;
END;
/

SELECT SUM(CANTIDAD * PRECIOUNITARIO)
FROM DETALLEPEDIDO
WHERE IDPEDIDO = 3;


-- Crear Paquete de Inventario

CREATE OR REPLACE PACKAGE pqInventario AS

-- Procedimientos
PROCEDURE aumentarStock(
    p_idProducto NUMBER,
    p_cantidad NUMBER
);

PROCEDURE ajusteManualStock(
    p_idProducto NUMBER,
    p_cantidad NUMBER
);

PROCEDURE actualizarPrecioUnitario(
    p_idProducto NUMBER,
    p_precio NUMBER
);

-- Función
FUNCTION consultarStock(
    p_idProducto NUMBER
) RETURN NUMBER;

END pqInventario;
/

CREATE OR REPLACE PACKAGE BODY pqInventario AS

-- Aumentar stock
PROCEDURE aumentarStock(
    p_idProducto NUMBER,
    p_cantidad NUMBER
) IS
BEGIN
    IF p_cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20020,'Cantidad debe ser mayor a cero');
    END IF;

    UPDATE INVENTARIO
    SET CANTIDADDISPONIBLE = CANTIDADDISPONIBLE + p_cantidad,
        ULTIMAFECHAINGRESO = SYSDATE
    WHERE IDPRODUCTO = p_idProducto;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20021,'Producto no existe en inventario');
    END IF;

END;

-- Ajuste manual
PROCEDURE ajusteManualStock(
    p_idProducto NUMBER,
    p_cantidad NUMBER
) IS
    v_stock NUMBER;
BEGIN
    SELECT CANTIDADDISPONIBLE
    INTO v_stock
    FROM INVENTARIO
    WHERE IDPRODUCTO = p_idProducto;

    IF (v_stock + p_cantidad) < 0 THEN
        RAISE_APPLICATION_ERROR(-20022,'Stock no puede quedar negativo');
    END IF;

    UPDATE INVENTARIO
    SET CANTIDADDISPONIBLE = CANTIDADDISPONIBLE + p_cantidad
    WHERE IDPRODUCTO = p_idProducto;

END;

-- Actualizar precio
PROCEDURE actualizarPrecioUnitario(
    p_idProducto NUMBER,
    p_precio NUMBER
) IS
BEGIN
    IF p_precio <= 0 THEN
        RAISE_APPLICATION_ERROR(-20023,'Precio debe ser mayor a cero');
    END IF;

    UPDATE INVENTARIO
    SET COSTOUNITARIO = p_precio
    WHERE IDPRODUCTO = p_idProducto;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20024,'Producto no encontrado');
    END IF;

END;

-- Función consultar stock
FUNCTION consultarStock(
    p_idProducto NUMBER
) RETURN NUMBER IS
    v_stock NUMBER;
BEGIN
    SELECT CANTIDADDISPONIBLE
    INTO v_stock
    FROM INVENTARIO
    WHERE IDPRODUCTO = p_idProducto;

    RETURN v_stock;
END;

END pqInventario;
/

-- Consultar Stock

SET SERVEROUTPUT ON;

DECLARE
    v_stock NUMBER;
BEGIN
    v_stock := pqInventario.consultarStock(1);
    DBMS_OUTPUT.PUT_LINE('Stock: ' || v_stock);
END;
/

-- Aumentar Stock

BEGIN
    pqInventario.aumentarStock(1,5);
END;
/

SELECT IDPRODUCTO, CANTIDADDISPONIBLE
FROM INVENTARIO
WHERE IDPRODUCTO = 1;

-- Ajuste de producto dañado

BEGIN
    pqInventario.ajusteManualStock(1,-2);
END;
/

SELECT IDPRODUCTO, CANTIDADDISPONIBLE
FROM INVENTARIO
WHERE IDPRODUCTO = 1;

-- Cambiar precio

BEGIN
    pqInventario.actualizarPrecioUnitario(1,900);
END;
/

SELECT IDPRODUCTO, COSTOUNITARIO
FROM INVENTARIO
WHERE IDPRODUCTO = 1;


SET SERVEROUTPUT ON;

DECLARE
    v_stock NUMBER;
BEGIN
    v_stock := pqInventario.consultarStock(1);
    DBMS_OUTPUT.PUT_LINE('Stock actual: ' || v_stock);

    pqInventario.aumentarStock(1,3);

    v_stock := pqInventario.consultarStock(1);
    DBMS_OUTPUT.PUT_LINE('Stock despues aumento: ' || v_stock);

END;
/
