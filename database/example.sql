DROP DATABASE IF EXISTS `i`;

CREATE DATABASE `i` CHARACTER SET `latin1` COLLATE `latin1_swedish_ci`;

USE `i`;

--
-- Tables
--

CREATE TABLE `accounts` (
    `id`            INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `name`          VARCHAR(24) NOT NULL
);

CREATE TABLE `item-builds` (
    `id`            SMALLINT    NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `name`          VARCHAR(32) NOT NULL,
    `name-key`      VARCHAR(32) NOT NULL,
    `model`         SMALLINT    NOT NULL
);

CREATE TABLE `items` (
    `item-build-id` SMALLINT    NOT NULL,
    `owner-id`      INT             NULL,
    `x`             FLOAT       NOT NULL             DEFAULT 0.0,
    `y`             FLOAT       NOT NULL             DEFAULT 0.0,
    `z`             FLOAT       NOT NULL             DEFAULT 0.0,
    `rotation-x`    FLOAT       NOT NULL             DEFAULT 0.0,
    `rotation-y`    FLOAT       NOT NULL             DEFAULT 0.0,
    `rotation-z`    FLOAT       NOT NULL             DEFAULT 0.0,
    `uuid`          CHAR(36)    NOT NULL PRIMARY KEY DEFAULT UUID(),
    `added_at`      TIMESTAMP   NOT NULL             DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk-items-item-builds` FOREIGN KEY (`item-build-id`) REFERENCES `item-builds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk-items-accounts` FOREIGN KEY (`owner-id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE `item-attributes` (
    `key`           VARCHAR(32) NOT NULL,
    `value`         INT         NOT NULL,
    `item-uuid`     CHAR(36)    NOT NULL,
    UNIQUE KEY `uk-item-attributes-items` (`key`, `item-uuid`),
    CONSTRAINT `fk-item-attributes-items` FOREIGN KEY (`item-uuid`) REFERENCES `items` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE
);

--
-- Tests
--

INSERT INTO `accounts` (`name`) VALUES
    ('User-A'),
    ('User-B'),
    ('User-C');

INSERT INTO `item-builds` (`name`, `name-key`, `model`) VALUES
    ('AK-47', 'ak47', 355),
    ('M4', 'm4', 356),
    ('Pizza', 'pizza', 2702),
    ('Hamburger', 'hamburger', 2703),
    ('Medkit', 'medkit', 11736);

INSERT INTO `items` (`item-build-id`, `owner-id`, `uuid`) VALUES
    (1, 1, 'e11abc7a-3f74-11ef-be5a-2cfda1c8c8dc'),
    (2, 1, 'e11ac5a8-3f74-11ef-be5a-2cfda1c8c8dc'),
    (3, 1, 'e11ac60f-3f74-11ef-be5a-2cfda1c8c8dc');

INSERT INTO `item-attributes` (`key`, `value`, `item-uuid`) VALUES
    ('Key-A', 100, 'e11abc7a-3f74-11ef-be5a-2cfda1c8c8dc'),
    ('Key-B', 200, 'e11abc7a-3f74-11ef-be5a-2cfda1c8c8dc'),
    ('Key-C', 300, 'e11abc7a-3f74-11ef-be5a-2cfda1c8c8dc'),
    ('Key-D', 400, 'e11ac5a8-3f74-11ef-be5a-2cfda1c8c8dc'),
    ('Key-E', 500, 'e11ac5a8-3f74-11ef-be5a-2cfda1c8c8dc'),
    ('Key-F', 600, 'e11ac60f-3f74-11ef-be5a-2cfda1c8c8dc');