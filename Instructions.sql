-- 1 Al crear un Order deben copiarse los campos de la dirección de envío (Calle, Ciudad y País) de Client a Order.
DELIMITER //
CREATE TRIGGER beforeInsertOrders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Declaramos variable
    DECLARE shipping_street VARCHAR(255);
    DECLARE shipping_city VARCHAR(255);
    DECLARE shipping_country VARCHAR(255);

    -- Selecionamos los datos necesarios en clientes y los metemos en los variables declarados
    SELECT ShippingStreet, ShippingCity, ShippingCountry
    INTO shipping_street, shipping_city, shipping_country
    FROM clients
    WHERE ID = NEW.ClientID;

    -- cambiamos datos en la tabla orders
    SET NEW.ShippingStreet = shipping_street;
    SET NEW.ShippingCity = shipping_city;
    SET NEW.ShippingCountry = shipping_country;
END;

DELIMITER ;

-- 2 Cuando se inserta un OrderLineItems o se elimina un OrderLineItems, es necesario calcular el importe total de su Order.
DELIMITER //
CREATE TRIGGER AfterInsertOLI
AFTER INSERT ON orderlineitems
FOR EACH ROW
BEGIN
    DECLARE total_amount DECIMAL(10,2);

    -- Calcular el importe total del pedido actual
    SELECT SUM(UnitPrice)
    INTO total_amount
    FROM orderlineitems
    WHERE OrderID = NEW.OrderID;

    -- Actualizar el importe total del pedido
    UPDATE orders
    SET TotalPrice = total_amount
    WHERE ID = NEW.OrderID;
END ;
DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterDeleteOLI
AFTER DELETE ON orderlineitems
FOR EACH ROW
BEGIN
    DECLARE total_amount DECIMAL(10,2);

    -- Calcular el importe total del pedido actual
    SELECT SUM(UnitPrice)
    INTO total_amount
    FROM orderlineitems
    WHERE OrderID = OLD.OrderID;

    -- Actualizar el importe total del pedido
    UPDATE orders
    SET TotalPrice = total_amount
    WHERE ID = OLD.OrderID;
END;
DELIMITER ;

-- 3 Cuando se inserta un OrderLineItem o se modifica el producto de un OrderLineItems es necesario poner el precio del producto en el campo “Unit Price”.
DELIMITER //
CREATE TRIGGER BeforeInsertOLI
BEFORE INSERT ON orderlineitems
FOR EACH ROW
BEGIN
    -- declaramos variable
    DECLARE product_price DECIMAL(10,2);

    -- Obtener el precio del producto correspondiente
    SELECT Price INTO product_price
    FROM products
    WHERE ID = NEW.ProductID;

    -- Actualizar el campo Unit Price del nuevo OrderLineItem
    SET NEW.UnitPrice = product_price;
END;
DELIMITER ;

DELIMITER //
CREATE TRIGGER BeforeUpdateOLI
BEFORE UPDATE ON orderlineitems
FOR EACH ROW
BEGIN
    -- Declaramos variable
    DECLARE product_price DECIMAL(10,2);

    -- Obtener el precio del producto correspondiente
    SELECT Price INTO product_price
    FROM products
    WHERE ID = NEW.ProductID;

    -- Actualizar el campo Unit Price del OrderLineItem modificado
    SET NEW.UnitPrice = product_price;
END;
DELIMITER ;

-- 4 Creación de WorkOrder cada vez que un pedido pasa a estado “Accepted”. La información de WorkOrder hay que recuperarla del pedido.
-- Es necesario crear tantas WorkOrderItems como OrderLineItems tenga el pedido y deben rellenarse con la información que haya en cada OrderLineItems.
DELIMITER //
CREATE PROCEDURE create_work_order(IN OrderParam INT)
BEGIN
    DECLARE itsDone INT DEFAULT FALSE;
    DECLARE cur_product_id INT;

    -- Declarar el cursor para obtener los ProductID de los OrderLineItems
    DECLARE cur CURSOR FOR
    SELECT ProductID
    FROM orderlineitems
    WHERE OrderID = OrderParam;

    -- Declarar el manejador de continuidad para el cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET itsDone = TRUE;

    -- Insertar una nueva orden de trabajo
    INSERT INTO workorders (OrderID, Status)
    VALUES (OrderParam, 'New');

    -- Obtener el ID de la orden de trabajo recién insertada
    SET @work_order_id = LAST_INSERT_ID();

    OPEN cur;
    read_loop: LOOP

        -- Leer el siguiente ProductID del cursor
        FETCH cur INTO cur_product_id;
        IF itsDone THEN
            LEAVE read_loop;
        END IF;

        -- Insertar el ProductID en la tabla de WorkOrderItems
        INSERT INTO workorderitems (WorkOrderID, ProductID)
        VALUES (@work_order_id, cur_product_id);
    END LOOP;
    CLOSE cur;
end ;
DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterUpdateOrders
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Verificar si el estado del pedido ha cambiado a "Accepted"
    IF (NEW.Status = 'Accepted' AND OLD.Status <> 'Accepted') THEN
        CALL create_work_order(NEW.ID);
    end if ;
end ;
DELIMITER ;

-- 5 Creación de Shipment cada vez que una WorkOrder pase a estado “Completed”. La información de Shipment debe recuperarse del Order y del WorkOrder. Al igual que en el
-- punto anterior es necesario crear tantas ShipmentItems como WorkOrderItems y deben rellenarse con la información de cada WorkOrderItems.
DELIMITER //
CREATE PROCEDURE create_shipment(IN workOrderIDParam INT, IN OrderIdParam INT)
BEGIN
    -- Obtener la información de la orden de trabajo
    DECLARE client_ID INT;
    DECLARE shipping_street VARCHAR(255);
    DECLARE shipping_city VARCHAR(255);
    DECLARE shipping_country VARCHAR(255);

    SELECT ClientID, ShippingStreet, ShippingCity, ShippingCountry
    INTO client_ID, shipping_street, shipping_city, shipping_country
    FROM orders
    WHERE ID = OrderIdParam;

    -- Insertar el envío
    INSERT INTO shipments (ClientID, OrderID, ShippingStreet, ShippingCity, ShippingCountry, Status)
    VALUES (client_ID, OrderIdParam, shipping_street, shipping_city, shipping_country, 'New');

    -- Obtener el ID del envío recién insertado
    SET @shipment_id = LAST_INSERT_ID();

    -- Insertar los elementos de envío
    INSERT INTO shipmentitems (ShipmentID, ProductID)
    SELECT @shipment_id, ProductID
    FROM workorderitems
    WHERE WorkOrderID = workOrderIDParam;
END;
DELIMITER ;

DELIMITER //
CREATE TRIGGER AfterUpdateWorkOrdes
AFTER UPDATE ON workorders
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status <> 'Completed' THEN
        CALL create_shipment(NEW.ID, NEW.OrderID);
    END IF;
END;
DELIMITER ;

-- 6 Cuando se crea un registro Shipment es necesario actualizar el estado del pedido asociado a “Sent”.
DELIMITER //
CREATE TRIGGER AfterInsertShipments
AFTER INSERT ON shipments
FOR EACH ROW
BEGIN
    -- Actualizar el estado del pedido asociado a "Sent"
    UPDATE orders
    SET Status = 'Sent'
    WHERE ID = NEW.OrderID;
END;
DELIMITER ;

-- 7 Cuando un registro Shipment tiene el estado “Delivered” es necesario actualizar el estado del Order a “Completed” siempre y cuando todos sus Shipment estén en “Delivered”.
DELIMITER //
CREATE PROCEDURE update_order_status_completed(IN order_ID INT)
BEGIN
    DECLARE total_shipments INT;
    DECLARE delivered_shipments INT;

    -- Obtener el total de envíos asociados al pedido
    SELECT COUNT(*) INTO total_shipments
    FROM shipments
    WHERE OrderID = order_ID;

    -- Obtener el total de envíos "Delivered" asociados al pedido
    SELECT COUNT(*) INTO delivered_shipments
    FROM shipments
    WHERE OrderID = order_ID AND Status = 'Delivered';

    -- Si todos los envíos están "Delivered", actualizar el estado del pedido a "Completed"
    IF total_shipments = delivered_shipments THEN
        UPDATE orders
        SET Status = 'Completed'
        WHERE ID = order_ID;
    END IF;
END;
DELIMITER ;

DELIMITER //
CREATE TRIGGER update_order_status_trigger
AFTER UPDATE ON shipments
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Delivered' AND OLD.Status != 'Delivered' THEN
        CALL update_order_status_completed( NEW.OrderID);
    END IF;
END;
DELIMITER ;


-- 8 Al modificarse un precio de un producto se deben actualizar los OrderLineItems que tengan ese producto, siempre y cuando el Order esté en estado “Draft”.
DELIMITER //
CREATE TRIGGER AfterUpdateProducts
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.Price <> NEW.Price THEN
        CALL update_order_line_items(NEW.ID, NEW.Price);
    END IF;
END;
DELIMITER ;

DELIMITER //
CREATE PROCEDURE update_order_line_items(IN productIDParam INT, IN newPrice DECIMAL(10,2))
BEGIN
    -- Actualizar los OrderLineItems con el nuevo precio del producto
    UPDATE orderlineitems
    JOIN orders ON orderlineitems.OrderID = orders.ID
    SET orderlineitems.UnitPrice = newPrice
    WHERE orderlineitems.ProductID = productIDParam AND orders.Status = 'Draft';
END ;
DELIMITER ;

-- Puntos que solicita el club y que deben tenerse en cuenta en las automatizaciones.
-- 1 Los estados de un pedido son: “Draft”, “Created”, “Accepted”, “Sent”, “Completed”.
    -- No hay que hacer

-- 2 Los estados de un pedido son secuenciales, por ejemplo, no es posible mover un estado “Created” a un estado “Sent” sin antes haber pasado por “Accepted”.
DELIMITER //
CREATE TRIGGER BeforeUpdateOrders
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    DECLARE order_line_count INT;
    DECLARE prevStatus VARCHAR(50);

    -- Obtener el estado anterior del pedido
    SELECT Status INTO prevStatus
    FROM orders
    WHERE ID = NEW.ID - 1;

    -- Contar las líneas de pedido asociadas al pedido
    SELECT COUNT(*) INTO order_line_count
    FROM orderlineitems
    WHERE OrderID = NEW.ID;

    -- Validar la transición de estado
    IF NOT ((prevStatus = 'Draft' AND NEW.Status = 'Created') OR
        (prevStatus = 'Created' AND NEW.Status = 'Accepted') OR
        (prevStatus = 'Accepted' AND NEW.Status = 'Sent') OR
        (prevStatus = 'Sent' AND NEW.Status = 'Completed')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid order state';
    END IF;

    -- Si el pedido no tiene líneas de pedido y el nuevo estado es "Created" o posterior, genera un error
    IF order_line_count = 0 AND (
        NEW.Status = 'Created' OR
        NEW.Status = 'Accepted' OR
        NEW.Status = 'Sent' OR
        NEW.Status = 'Completed'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update order state to "Created" or later without order lines.';
    END IF;
END ;
DELIMITER ;


-- 3 Los estados de un WorkOrder son: “New” y “Completed”.
DELIMITER //
CREATE TRIGGER BeforeUpdateWorkOrders
BEFORE UPDATE ON workorders
FOR EACH ROW
BEGIN
    DECLARE prevStatus VARCHAR(50);

    -- Obtener el estado anterior del pedido
    SELECT Status INTO prevStatus
    FROM orders
    WHERE ID = NEW.ID - 1;

    -- Validar la transición de estado
    IF NOT ((prevStatus = 'New' AND NEW.Status = 'Completed')) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid order state';
    END IF;
END ;
DELIMITER ;

-- 4 Los estados de un Shipment son:”New”, “Sent” y “Delivered”.
DELIMITER //
CREATE TRIGGER BeforeUpdateShipments
BEFORE UPDATE ON shipments
FOR EACH ROW
BEGIN
    DECLARE prevStatus VARCHAR(50);

    -- Obtener el estado anterior del pedido
    SELECT Status INTO prevStatus
    FROM orders
    WHERE ID = NEW.ID - 1;

    -- Validar la transición de estado
    IF NOT ((prevStatus = 'New' AND NEW.Status = 'Sent') OR
        (prevStatus = 'Sent' AND NEW.Status = 'Delivered')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid order state';
    END IF;
END ;
DELIMITER ;

-- 5 No es posible que un pedido sin líneas de pedido actualice su estado a “Created” ni posteriores.
-- lo he hecho con el 2

-- 6 No es posible volver atrás en los estados de ninguna tabla. Por ejemplo, no es posible volver a poner un estado “Created” o “Accepted” a un Order cuyo estado es “Sent”.
-- hecho en los actividades anteriores

-- 7 No es posible insertar nuevos Products en Orders con estado diferente a “Draft”.
DELIMITER //
CREATE TRIGGER BeforeInsertOLI_StatusErrors
BEFORE INSERT ON orderlineitems
FOR EACH ROW
BEGIN
    DECLARE order_status VARCHAR(50);

    -- Obtener el estado del pedido asociado
    SELECT Status INTO order_status
    FROM orders
    WHERE ID = NEW.OrderID;

    -- Si el estado del pedido no es "Draft", generar un error
    IF order_status <> 'Draft' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot insert new products into orders with status other than "Draft".';
    END IF;
END ;
DELIMITER ;
