CREATE OR REPLACE VIEW vista_productos_completa AS
SELECT p.idProducto, p.nombre AS Producto, m.nombre AS Marca, c.nombre AS Categoria, i.cantidadDisponible, i.costoUnitario, i.cantidadMinima
FROM Producto p
JOIN Marca m ON p.idMarca = m.idMarca
JOIN Categoria c ON p.idCategoria = c.idCategoria
JOIN Inventario i ON p.idProducto = i.idProducto;

CREATE OR REPLACE VIEW vista_detalle_pedido AS
SELECT pe.idPedido, u.nombre || ' ' || u.apellido1 AS Cliente, pe.fecha, dp.idProducto, dp.cantidad, dp.precioUnitario
FROM Pedido pe
JOIN Usuario u ON pe.idUsuario = u.idUsuario
JOIN DetallePedido dp ON pe.idPedido = dp.idPedido;

CREATE OR REPLACE VIEW vista_productos_bajo_stock AS
SELECT p.nombre, i.cantidadDisponible, i.cantidadMinima
FROM Inventario i
JOIN Producto p ON i.idProducto = p.idProducto
WHERE i.cantidadDisponible < i.cantidadMinima;

CREATE OR REPLACE VIEW vista_historial_usuarios AS
SELECT u.idUsuario, u.nombre AS Cliente, pe.idPedido, pe.fecha, p.nombre AS Producto, dp.cantidad, dp.precioUnitario
FROM Usuario u
JOIN Pedido pe ON u.idUsuario = pe.idUsuario
JOIN DetallePedido dp ON pe.idPedido = dp.idPedido
JOIN Producto p ON dp.idProducto = p.idProducto;

CREATE OR REPLACE VIEW vista_proveedores_productos AS
SELECT p.nombre AS Producto, pr.nombre AS Proveedor, m.nombre AS Marca, c.nombre AS Categoria, i.cantidadDisponible
FROM Producto p
JOIN Inventario i ON p.idProducto = i.idProducto
JOIN Proveedor pr ON i.idProveedor = pr.idProveedor
JOIN Marca m ON p.idMarca = m.idMarca
JOIN Categoria c ON p.idCategoria = c.idCategoria;

CREATE OR REPLACE TRIGGER trigger_reducir_stock_factura
AFTER INSERT ON Factura FOR EACH ROW
BEGIN
    FOR r IN (SELECT idProducto, cantidad FROM DetallePedido WHERE idPedido = :NEW.idPedido) 
    LOOP
        UPDATE Inventario 
        SET cantidadDisponible = cantidadDisponible - r.cantidad
        WHERE idProducto = r.idProducto;
    END LOOP;
END;
/
CREATE OR REPLACE TRIGGER trigger_calcular_factura_completa
BEFORE INSERT ON Factura FOR EACH ROW
DECLARE
    v_subtotal NUMBER(10,2);
BEGIN
    SELECT SUM(cantidad * precioUnitario) INTO v_subtotal
    FROM DetallePedido 
    WHERE idPedido = :NEW.idPedido;
    :NEW.subtotal := v_subtotal;
    :NEW.impuesto := v_subtotal * 0.13;
    :NEW.total := v_subtotal + (v_subtotal * 0.13);
END;
/
CREATE OR REPLACE TRIGGER trigger_actualizar_estado_pedido
AFTER INSERT ON Pago FOR EACH ROW
DECLARE
    v_idPedido NUMBER;
BEGIN
    SELECT idPedido INTO v_idPedido 
    FROM Factura 
    WHERE idFactura = :NEW.idFactura;

    UPDATE Pedido 
    SET estado = 'Pagado' 
    WHERE idPedido = v_idPedido;
END;
/