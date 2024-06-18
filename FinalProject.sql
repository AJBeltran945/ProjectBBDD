-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.2.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for practica
CREATE DATABASE IF NOT EXISTS `practica` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `practica`;

-- Dumping structure for table practica.clients
CREATE TABLE IF NOT EXISTS `clients` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(150) NOT NULL,
  `LastName` varchar(150) NOT NULL,
  `ShippingStreet` varchar(255) DEFAULT NULL,
  `ShippingCity` varchar(255) DEFAULT NULL,
  `ShippingCountry` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure practica.create_shipment
DELIMITER //
CREATE PROCEDURE `create_shipment`(IN workOrderIDParam INT, IN OrderIdParam INT)
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
END//
DELIMITER ;

-- Dumping structure for procedure practica.create_work_order
DELIMITER //
CREATE PROCEDURE `create_work_order`(IN OrderParam INT)
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
end//
DELIMITER ;

-- Dumping structure for table practica.orderlineitems
CREATE TABLE IF NOT EXISTS `orderlineitems` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `UnitPrice` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `OrderID` (`OrderID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `orderlineitems_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`ID`),
  CONSTRAINT `orderlineitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for table practica.orders
CREATE TABLE IF NOT EXISTS `orders` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ClientID` int(11) NOT NULL,
  `TotalPrice` decimal(10,2) DEFAULT NULL,
  `ShippingStreet` varchar(255) DEFAULT NULL,
  `ShippingCity` varchar(255) DEFAULT NULL,
  `ShippingCountry` varchar(255) DEFAULT NULL,
  `Status` varchar(100) DEFAULT 'Draft',
  PRIMARY KEY (`ID`),
  KEY `ClientID` (`ClientID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`ClientID`) REFERENCES `clients` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for table practica.products
CREATE TABLE IF NOT EXISTS `products` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ProductName` varchar(255) NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for table practica.shipmentitems
CREATE TABLE IF NOT EXISTS `shipmentitems` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ShipmentID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ShipmentID` (`ShipmentID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `shipmentitems_ibfk_1` FOREIGN KEY (`ShipmentID`) REFERENCES `shipments` (`ID`),
  CONSTRAINT `shipmentitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for table practica.shipments
CREATE TABLE IF NOT EXISTS `shipments` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ClientID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `ShippingStreet` varchar(255) DEFAULT NULL,
  `ShippingCity` varchar(255) DEFAULT NULL,
  `ShippingCountry` varchar(255) DEFAULT NULL,
  `Status` varchar(100) DEFAULT 'New',
  PRIMARY KEY (`ID`),
  KEY `ClientID` (`ClientID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `shipments_ibfk_1` FOREIGN KEY (`ClientID`) REFERENCES `clients` (`ID`),
  CONSTRAINT `shipments_ibfk_2` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for procedure practica.update_order_line_items
DELIMITER //
CREATE PROCEDURE `update_order_line_items`(IN productIDParam INT, IN newPrice DECIMAL(10,2))
BEGIN
    -- Actualizar los OrderLineItems con el nuevo precio del producto
    UPDATE orderlineitems
    JOIN orders ON orderlineitems.OrderID = orders.ID
    SET orderlineitems.UnitPrice = newPrice
    WHERE orderlineitems.ProductID = productIDParam AND orders.Status = 'Draft';
END//
DELIMITER ;

-- Dumping structure for procedure practica.update_order_status_completed
DELIMITER //
CREATE PROCEDURE `update_order_status_completed`(IN order_ID int)
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
END//
DELIMITER ;

-- Dumping structure for table practica.workorderitems
CREATE TABLE IF NOT EXISTS `workorderitems` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `WorkOrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `WorkOrderID` (`WorkOrderID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `workorderitems_ibfk_1` FOREIGN KEY (`WorkOrderID`) REFERENCES `workorders` (`ID`),
  CONSTRAINT `workorderitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for table practica.workorders
CREATE TABLE IF NOT EXISTS `workorders` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) NOT NULL,
  `Status` varchar(100) DEFAULT 'New',
  PRIMARY KEY (`ID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `workorders_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Data exporting was unselected.

-- Dumping structure for trigger practica.AfterDeleteOLI
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.AfterInsertOLI
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.AfterInsertShipments
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER AfterInsertShipments
AFTER INSERT ON shipments
FOR EACH ROW
BEGIN
    -- Actualizar el estado del pedido asociado a "Sent"
    UPDATE orders
    SET Status = 'Sent'
    WHERE ID = NEW.OrderID;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.AfterUpdateOrders
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER AfterUpdateOrders
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Verificar si el estado del pedido ha cambiado a "Accepted"
    IF (NEW.Status = 'Accepted' AND OLD.Status <> 'Accepted') THEN
        CALL create_work_order(NEW.ID);
    end if ;
end//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.AfterUpdateProducts
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER AfterUpdateProducts
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF OLD.Price <> NEW.Price THEN
        CALL update_order_line_items(NEW.ID, NEW.Price);
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.AfterUpdateShipments
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE trigger AfterUpdateShipments
    after update
    on shipments
    for each row
BEGIN
    IF NEW.Status = 'Delivered' AND OLD.Status <> 'Delivered' THEN
        CALL update_order_status_completed(NEW.OrderID);
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.AfterUpdateWorkOrdes
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER AfterUpdateWorkOrdes
AFTER UPDATE ON workorders
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status <> 'Completed' THEN
        CALL create_shipment(NEW.ID, NEW.OrderID);
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.BeforeInsertOLI
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.BeforeInsertOLI_StatusErrors
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.beforeInsertOrders
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.BeforeUpdateOLI
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.BeforeUpdateOrders
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE trigger BeforeUpdateOrders
    before update
    on orders
    for each row
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

    -- Si el pedido no tiene líneas de pedido y el nuevo estado es "Created" o otra cosa, genera un error
    IF order_line_count = 0 AND (
        NEW.Status = 'Created' OR
        NEW.Status = 'Accepted' OR
        NEW.Status = 'Sent' OR
        NEW.Status = 'Completed'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot update order state to "Created" or later without order lines.';
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.BeforeUpdateShipments
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger practica.BeforeUpdateWorkOrders
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
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
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
