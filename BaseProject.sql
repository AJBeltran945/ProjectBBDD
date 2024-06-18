-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         10.4.32-MariaDB - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.3.0.6589
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para practica
CREATE DATABASE IF NOT EXISTS `practica` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `practica`;

-- Volcando estructura para tabla practica.clients
CREATE TABLE IF NOT EXISTS `clients` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(150) NOT NULL,
  `LastName` varchar(150) NOT NULL,
  `ShippingStreet` varchar(255) DEFAULT NULL,
  `ShippingCity` varchar(255) DEFAULT NULL,
  `ShippingCountry` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.clients: ~0 rows (aproximadamente)
INSERT INTO `clients` (`ID`, `Name`, `LastName`, `ShippingStreet`, `ShippingCity`, `ShippingCountry`) VALUES
	(1, 'John', 'Doe', '123 Main St', 'Cityville', 'Countryland'),
	(2, 'Jane', 'Smith', '456 Oak St', 'Townsville', 'Countryland'),
	(3, 'Alice', 'Johnson', '789 Pine St', 'Villageton', 'Countryland'),
	(4, 'Bob', 'Williams', '101 Maple St', 'Hamletville', 'Countryland'),
	(5, 'Eva', 'Davis', '202 Elm St', 'Cityburg', 'Countryland'),
	(6, 'Carlos', 'Martinez', '303 Birch St', 'Villageburg', 'Countryland'),
	(7, 'Olivia', 'Taylor', '404 Cedar St', 'Townburg', 'Countryland'),
	(8, 'David', 'Brown', '505 Spruce St', 'Hamletburg', 'Countryland'),
	(9, 'Sophia', 'Miller', '606 Walnut St', 'Cityton', 'Countryland'),
	(10, 'Matthew', 'Jones', '707 Oak St', 'Villagetown', 'Countryland');

-- Volcando estructura para tabla practica.orderlineitems
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
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.orderlineitems: ~15 rows (aproximadamente)
INSERT INTO `orderlineitems` (`ID`, `OrderID`, `ProductID`, `UnitPrice`) VALUES
	(1, 1, 1, 29.99),
	(2, 1, 5, 34.99),
	(3, 1, 9, 9.99),
	(4, 1, 13, 24.99),
	(5, 1, 16, 129.99),
	(6, 2, 2, 99.99),
	(7, 2, 7, 39.99),
	(8, 2, 11, 89.99),
	(9, 2, 14, 12.99),
	(10, 3, 3, 49.99),
	(11, 3, 8, 17.99),
	(12, 3, 12, 74.99),
	(13, 3, 15, 19.99),
	(14, 3, 18, 49.99),
	(15, 3, 20, 79.99);

-- Volcando estructura para tabla practica.orders
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.orders: ~3 rows (aproximadamente)
INSERT INTO `orders` (`ID`, `ClientID`, `TotalPrice`, `ShippingStreet`, `ShippingCity`, `ShippingCountry`, `Status`) VALUES
	(1, 1, 0.00, '123 Main St', 'Cityville', 'Countryland', 'Draft'),
	(2, 3, 0.00, '456 Oak St', 'Townsville', 'Countryland', 'Draft'),
	(3, 5, 0.00, '789 Pine St', 'Villageton', 'Countryland', 'Draft');

-- Volcando estructura para tabla practica.products
CREATE TABLE IF NOT EXISTS `products` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ProductName` varchar(255) NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.products: ~21 rows (aproximadamente)
INSERT INTO `products` (`ID`, `ProductName`, `Price`) VALUES
	(1, 'Balón de Baloncesto Nike', 29.99),
	(2, 'Zapatillas de Baloncesto Adidas', 99.99),
	(3, 'Camiseta Oficial del Equipo', 49.99),
	(4, 'Gorra con Logo del Equipo', 19.99),
	(5, 'Pantalones Cortos de Entrenamiento', 34.99),
	(6, 'Mochila para Equipos de Baloncesto', 39.99),
	(7, 'Calcetines Técnicos para Baloncesto', 9.99),
	(8, 'Botella de Agua Deportiva', 12.99),
	(9, 'Toalla de Microfibra para Entrenamiento', 17.99),
	(10, 'Sudadera con Capucha del Equipo', 54.99),
	(11, 'Chaqueta Impermeable para Entrenamientos', 74.99),
	(12, 'Rodilleras de Compresión', 24.99),
	(13, 'Cinta para la Cabeza de Baloncesto', 7.99),
	(14, 'Entrenador de Baloncesto Portátil', 89.99),
	(15, 'Conos de Entrenamiento (Set de 10)', 14.99),
	(16, 'Reloj Deportivo con GPS', 129.99),
	(17, 'Banda de Resistencia para Ejercicios', 19.99),
	(18, 'Tabla de Tiro de Baloncesto', 49.99),
	(19, 'Entrenador Virtual de Tiro', 159.99),
	(20, 'Poster Firmado por el Jugador Estrella', 79.99),
	(21, 'Gastos de envío', 4.99);

-- Volcando estructura para tabla practica.shipmentitems
CREATE TABLE IF NOT EXISTS `shipmentitems` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ShipmentID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ShipmentID` (`ShipmentID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `shipmentitems_ibfk_1` FOREIGN KEY (`ShipmentID`) REFERENCES `shipments` (`ID`),
  CONSTRAINT `shipmentitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.shipmentitems: ~0 rows (aproximadamente)

-- Volcando estructura para tabla practica.shipments
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.shipments: ~0 rows (aproximadamente)

-- Volcando estructura para tabla practica.workorderitems
CREATE TABLE IF NOT EXISTS `workorderitems` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `WorkOrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `WorkOrderID` (`WorkOrderID`),
  KEY `ProductID` (`ProductID`),
  CONSTRAINT `workorderitems_ibfk_1` FOREIGN KEY (`WorkOrderID`) REFERENCES `workorders` (`ID`),
  CONSTRAINT `workorderitems_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.workorderitems: ~0 rows (aproximadamente)

-- Volcando estructura para tabla practica.workorders
CREATE TABLE IF NOT EXISTS `workorders` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` int(11) NOT NULL,
  `Status` varchar(100) DEFAULT 'New',
  PRIMARY KEY (`ID`),
  KEY `OrderID` (`OrderID`),
  CONSTRAINT `workorders_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Volcando datos para la tabla practica.workorders: ~0 rows (aproximadamente)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
