-- ============================================================================
-- Little Lemon Booking System - Database Schema, Sample Data & Stored Procedures
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `little_lemon_db`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `little_lemon_db`;

-- ----------------------------------------------------------------------------
-- 1. Customers Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Customers` (
  `CustomerID` INT NOT NULL AUTO_INCREMENT,
  `FullName` VARCHAR(150) NOT NULL,
  `PhoneNumber` VARCHAR(30) NOT NULL,
  `Email` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`CustomerID`),
  UNIQUE INDEX `Email_UNIQUE` (`Email` ASC)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 2. DiningTables Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `DiningTables` (
  `TableID` INT NOT NULL AUTO_INCREMENT,
  `TableNumber` INT NOT NULL,
  `Capacity` INT NOT NULL,
  `LocationZone` VARCHAR(50) NOT NULL DEFAULT 'Main Dining',
  PRIMARY KEY (`TableID`),
  UNIQUE INDEX `TableNumber_UNIQUE` (`TableNumber` ASC)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 3. Staff Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Staff` (
  `StaffID` INT NOT NULL AUTO_INCREMENT,
  `StaffName` VARCHAR(150) NOT NULL,
  `Role` VARCHAR(60) NOT NULL,
  `Salary` DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (`StaffID`)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 4. MenuItems Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `MenuItems` (
  `MenuItemID` INT NOT NULL AUTO_INCREMENT,
  `ItemName` VARCHAR(150) NOT NULL,
  `Category` VARCHAR(60) NOT NULL,
  `Price` DECIMAL(8, 2) NOT NULL,
  PRIMARY KEY (`MenuItemID`)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 5. Bookings Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Bookings` (
  `BookingID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `TableID` INT NOT NULL,
  `StaffID` INT NULL,
  `BookingDate` DATETIME NOT NULL,
  `NumberOfGuests` INT NOT NULL,
  `Status` VARCHAR(30) NOT NULL DEFAULT 'Confirmed',
  PRIMARY KEY (`BookingID`),
  INDEX `fk_Bookings_Customers_idx` (`CustomerID` ASC),
  INDEX `fk_Bookings_Tables_idx` (`TableID` ASC),
  INDEX `fk_Bookings_Staff_idx` (`StaffID` ASC),
  CONSTRAINT `fk_Bookings_Customers`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `Customers` (`CustomerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Bookings_Tables`
    FOREIGN KEY (`TableID`)
    REFERENCES `DiningTables` (`TableID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Bookings_Staff`
    FOREIGN KEY (`StaffID`)
    REFERENCES `Staff` (`StaffID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 6. Orders Table
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Orders` (
  `OrderID` INT NOT NULL AUTO_INCREMENT,
  `BookingID` INT NOT NULL,
  `MenuItemID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `TotalCost` DECIMAL(10, 2) NOT NULL,
  `OrderDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`OrderID`),
  INDEX `fk_Orders_Bookings_idx` (`BookingID` ASC),
  INDEX `fk_Orders_MenuItems_idx` (`MenuItemID` ASC),
  CONSTRAINT `fk_Orders_Bookings`
    FOREIGN KEY (`BookingID`)
    REFERENCES `Bookings` (`BookingID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Orders_MenuItems`
    FOREIGN KEY (`MenuItemID`)
    REFERENCES `MenuItems` (`MenuItemID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Sample Test Data
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO `Customers` (`CustomerID`, `FullName`, `PhoneNumber`, `Email`) VALUES
(1, 'Rohan Kulkarni', '+91-9820111222', 'rohan.k@example.com'),
(2, 'Ananya Deshmukh', '+91-9820333444', 'ananya.d@example.com'),
(3, 'Vikramaditya Rao', '+91-9820555666', 'vikram.r@example.com'),
(4, 'Meera Iyer', '+91-9820777888', 'meera.i@example.com');

INSERT IGNORE INTO `DiningTables` (`TableID`, `TableNumber`, `Capacity`, `LocationZone`) VALUES
(1, 1, 2, 'Patio'),
(2, 2, 4, 'Main Dining'),
(3, 3, 6, 'Main Dining'),
(4, 4, 8, 'Private Room');

INSERT IGNORE INTO `Staff` (`StaffID`, `StaffName`, `Role`, `Salary`) VALUES
(1, 'Kabir Verma', 'Restaurant Manager', 75000.00),
(2, 'Neha Joshi', 'Host / Maitre D', 42000.00);

INSERT IGNORE INTO `MenuItems` (`MenuItemID`, `ItemName`, `Category`, `Price`) VALUES
(1, 'Mediterranean Grilled Sea Bass', 'Main Course', 850.00),
(2, 'Lemon Herb Risotto', 'Main Course', 540.00),
(3, 'Hummus & Warm Pita Platter', 'Starter', 320.00),
(4, 'Classic Tiramisu', 'Dessert', 290.00);

INSERT IGNORE INTO `Bookings` (`BookingID`, `CustomerID`, `TableID`, `StaffID`, `BookingDate`, `NumberOfGuests`, `Status`) VALUES
(1, 1, 1, 2, '2026-11-26 19:00:00', 2, 'Confirmed'),
(2, 2, 2, 2, '2026-11-26 20:00:00', 4, 'Confirmed'),
(3, 3, 3, 1, '2026-11-27 19:30:00', 5, 'Confirmed'),
(4, 4, 4, 1, '2026-11-27 21:00:00', 7, 'Confirmed');

INSERT IGNORE INTO `Orders` (`OrderID`, `BookingID`, `MenuItemID`, `Quantity`, `TotalCost`, `OrderDate`) VALUES
(1, 1, 3, 2, 640.00, '2026-11-26 19:15:00'),
(2, 1, 1, 2, 1700.00, '2026-11-26 19:30:00'),
(3, 2, 2, 3, 1620.00, '2026-11-26 20:20:00'),
(4, 3, 1, 4, 3400.00, '2026-11-27 19:50:00');

-- ----------------------------------------------------------------------------
-- Stored Procedure 1: GetMaxQuantity()
-- Returns the maximum order quantity recorded across orders.
-- ----------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE `GetMaxQuantity`()
BEGIN
    SELECT COALESCE(MAX(Quantity), 0) AS `MaxQuantity`
    FROM `Orders`;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Stored Procedure 2: ManageBooking(IN p_BookingDate DATETIME, IN p_TableNumber INT)
-- Checks whether a given table is already booked on the specified date/time.
-- ----------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE `ManageBooking`(
    IN `p_BookingDate` DATETIME,
    IN `p_TableNumber` INT
)
BEGIN
    DECLARE v_TableID INT;
    DECLARE v_ExistingCount INT DEFAULT 0;

    SELECT `TableID` INTO v_TableID
    FROM `DiningTables`
    WHERE `TableNumber` = `p_TableNumber`
    LIMIT 1;

    IF v_TableID IS NULL THEN
        SELECT CONCAT('Table ', p_TableNumber, ' does not exist.') AS `BookingStatus`;
    ELSE
        SELECT COUNT(*) INTO v_ExistingCount
        FROM `Bookings`
        WHERE `TableID` = v_TableID
          AND `BookingDate` = `p_BookingDate`
          AND `Status` <> 'Cancelled';

        IF v_ExistingCount > 0 THEN
            SELECT CONCAT('Table ', p_TableNumber, ' is already booked on ', p_BookingDate) AS `BookingStatus`;
        ELSE
            SELECT CONCAT('Table ', p_TableNumber, ' is available on ', p_BookingDate) AS `BookingStatus`;
        END IF;
    END IF;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Stored Procedure 3: AddBooking(...)
-- Inserts a new booking record for a customer and table.
-- ----------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE `AddBooking`(
    IN `p_CustomerID` INT,
    IN `p_TableID` INT,
    IN `p_StaffID` INT,
    IN `p_BookingDate` DATETIME,
    IN `p_NumberOfGuests` INT
)
BEGIN
    INSERT INTO `Bookings` (
        `CustomerID`,
        `TableID`,
        `StaffID`,
        `BookingDate`,
        `NumberOfGuests`,
        `Status`
    )
    VALUES (
        `p_CustomerID`,
        `p_TableID`,
        `p_StaffID`,
        `p_BookingDate`,
        `p_NumberOfGuests`,
        'Confirmed'
    );

    SELECT LAST_INSERT_ID() AS `NewBookingID`, 'New booking added' AS `Confirmation`;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Stored Procedure 4: UpdateBooking(IN p_BookingID INT, IN p_BookingDate DATETIME, IN p_NumberOfGuests INT)
-- Updates an existing booking's date and/or guest count.
-- ----------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE `UpdateBooking`(
    IN `p_BookingID` INT,
    IN `p_BookingDate` DATETIME,
    IN `p_NumberOfGuests` INT
)
BEGIN
    UPDATE `Bookings`
    SET
        `BookingDate` = COALESCE(`p_BookingDate`, `BookingDate`),
        `NumberOfGuests` = COALESCE(`p_NumberOfGuests`, `NumberOfGuests`)
    WHERE `BookingID` = `p_BookingID`;

    IF ROW_COUNT() > 0 THEN
        SELECT CONCAT('Booking ', p_BookingID, ' updated successfully') AS `Confirmation`;
    ELSE
        SELECT CONCAT('Booking ', p_BookingID, ' not found') AS `Confirmation`;
    END IF;
END //
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Stored Procedure 5: CancelBooking(IN p_BookingID INT)
-- Cancels an existing booking (marks status as 'Cancelled').
-- ----------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE `CancelBooking`(
    IN `p_BookingID` INT
)
BEGIN
    UPDATE `Bookings`
    SET `Status` = 'Cancelled'
    WHERE `BookingID` = `p_BookingID`;

    IF ROW_COUNT() > 0 THEN
        SELECT CONCAT('Booking ', p_BookingID, ' cancelled') AS `Confirmation`;
    ELSE
        SELECT CONCAT('Booking ', p_BookingID, ' not found') AS `Confirmation`;
    END IF;
END //
DELIMITER ;
