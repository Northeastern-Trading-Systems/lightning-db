CREATE DATABASE nts_lightning_db;
GRANT ALL PRIVILEGES ON nts_lightning_db.* TO 'webapp'@'%';
FLUSH PRIVILEGES;

USE nts_lightning_db;

-- Table to represent a strategy, which is a systematic model that listens for alpha insights and makes
-- the appropriate capital allocation decisions.
CREATE TABLE strategy (
    strategy_name varchar(50),
    strategy_id integer AUTO_INCREMENT NOT NULL,
    documentation_link varchar(50),
    launch_date datetime,
    termination_date datetime,
    PRIMARY KEY (strategy_id)
);

-- Table to represent a trade, which is a position taken by a strategy. The trade can consist of any number
-- of trade legs (for more complex, multi-legged trades).
CREATE TABLE trade (
    trade_id integer UNIQUE NOT NULL,
    strategy_id integer,
    open_time datetime,
    close_time datetime,
    PRIMARY KEY (trade_id),
    CONSTRAINT fk_1 
        FOREIGN KEY (strategy_id) REFERENCES strategy (strategy_id)
        ON UPDATE cascade ON DELETE restrict
);

-- Table to represent a trade leg, which is a single-contract position that belongs to a parent trade. A trade
-- leg can be made up of any number of trade fills. 
CREATE TABLE trade_leg (
    leg_no integer NOT NULL,
    trade_id integer NOT NULL,
    contract varchar(50),
    open_time datetime,
    close_time datetime,
    PRIMARY KEY(leg_no, trade_id),
    CONSTRAINT fk_2
        FOREIGN KEY (trade_id) REFERENCES trade (trade_id)
        ON UPDATE restrict ON DELETE restrict
);

-- Table to represent a trade fill, which is a reflection of an actual buy/sell transaction with the broker. A trade
-- fill has exactly one contract, any whole-number quantity, and an average price. 
CREATE TABLE fill (
    fill_id integer NOT NULL,
    leg_no integer NOT NULL,
    trade_id integer NOT NULL,
    contract varchar(50),
    qty integer,
    avg float(32),
    placement_time datetime,
    filled_time datetime,
    PRIMARY KEY (fill_id),
    CONSTRAINT fk_3
        FOREIGN KEY (leg_no, trade_id) REFERENCES trade_leg (leg_no, trade_id)
        ON UPDATE cascade ON DELETE restrict
);

-- DEMO DATA:
-- Dummy data acquired by Mockaroo

-- strategy Table
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('BullBreakout', 1, 'github.com/NTS-Lightning/BullBreakout', '01/01/2022', '12/03/2022');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('DynamicBreakoutII', 2, 'github.com/NTS-Lightning/DynamicBreakoutII', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('NineEMAVWAPCrossover', 3, 'github.com/NTS-Lightning/NineEMAVWAPCrossover', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('ChinaADRArbitrage', 4, 'github.com/NTS-Lightning/ChinaADRArbitrage', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('LongFTX', 5, 'github.com/NTS-Lightning/LongFTX', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('MeanReversionLunchbreak', 6, 'github.com/NTS-Lightning/MeanReversionLunchbreak', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('ModifiedVWAPReversion', 7, 'github.com/NTS-Lightning/ModifiedVWAPReversion', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('OrnamentalGourdArbitrage', 8, 'github.com/NTS-Lightning/OrnamentalGourdArbitrage', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('BuyHighSellLowOnMargin', 9, 'github.com/NTS-Lightning/BuyHighSellLowOnMargin', '01/01/2022', NULL);
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('GOHMRebasePoolArbitrage', 10, 'github.com/NTS-Lightning/GOHMRebasePoolArbitrage', '01/01/2022', NULL);


-- trade Table
insert into trade (trade_id, strategy_id, open_time, close_time) values (1, 2, '2022-04-24 14:20:03', '2022-04-24 14:50:03');
insert into trade (trade_id, strategy_id, open_time, close_time) values (2, 2, '2022-07-09 11:29:08', '2022-07-09 11:59:08');
insert into trade (trade_id, strategy_id, open_time, close_time) values (3, 4, '2022-04-24 08:29:58', '2022-04-24 08:59:58');
insert into trade (trade_id, strategy_id, open_time, close_time) values (4, 4, '2022-09-03 13:51:29', '2022-09-03 14:21:29');
insert into trade (trade_id, strategy_id, open_time, close_time) values (5, 5, '2022-07-23 22:52:44', '2022-07-23 23:22:44');
insert into trade (trade_id, strategy_id, open_time, close_time) values (6, 3, '2022-07-18 13:42:57', '2022-07-18 14:12:57');
insert into trade (trade_id, strategy_id, open_time, close_time) values (7, 4, '2022-09-20 07:11:42', '2022-09-20 07:41:42');
insert into trade (trade_id, strategy_id, open_time, close_time) values (8, 1, '2022-10-18 07:44:53', '2022-10-18 08:14:53');
insert into trade (trade_id, strategy_id, open_time, close_time) values (9, 5, '2021-12-28 06:15:19', '2021-12-28 06:45:19');
insert into trade (trade_id, strategy_id, open_time, close_time) values (10, 4, '2022-07-16 17:47:23', '2022-07-16 18:17:23');
insert into trade (trade_id, strategy_id, open_time, close_time) values (11, 2, '2022-09-09 17:30:18', '2022-09-09 18:00:18');
insert into trade (trade_id, strategy_id, open_time, close_time) values (12, 5, '2022-03-08 03:47:40', '2022-03-08 04:17:40');
insert into trade (trade_id, strategy_id, open_time, close_time) values (13, 3, '2022-05-07 20:15:13', '2022-05-07 20:45:13');
insert into trade (trade_id, strategy_id, open_time, close_time) values (14, 5, '2022-06-21 08:35:02', '2022-06-21 09:05:02');
insert into trade (trade_id, strategy_id, open_time, close_time) values (15, 3, '2022-06-05 18:32:32', '2022-06-05 19:02:32');
insert into trade (trade_id, strategy_id, open_time, close_time) values (16, 2, '2022-07-22 20:43:33', '2022-07-22 21:13:33');
insert into trade (trade_id, strategy_id, open_time, close_time) values (17, 3, '2022-02-10 04:53:50', '2022-02-10 05:23:50');
insert into trade (trade_id, strategy_id, open_time, close_time) values (18, 1, '2022-08-09 18:03:14', '2022-08-09 18:33:14');
insert into trade (trade_id, strategy_id, open_time, close_time) values (19, 2, '2022-01-08 05:39:28', '2022-01-08 06:09:28');
insert into trade (trade_id, strategy_id, open_time, close_time) values (20, 3, '2022-02-23 17:38:55', '2022-02-23 18:08:55');
insert into trade (trade_id, strategy_id, open_time, close_time) values (21, 5, '2022-08-17 16:17:54', '2022-08-17 16:47:54');
insert into trade (trade_id, strategy_id, open_time, close_time) values (22, 1, '2022-09-20 07:13:28', '2022-09-20 07:43:28');
insert into trade (trade_id, strategy_id, open_time, close_time) values (23, 5, '2022-07-19 14:51:56', '2022-07-19 15:21:56');
insert into trade (trade_id, strategy_id, open_time, close_time) values (24, 1, '2022-01-05 03:19:06', '2022-01-05 03:49:06');
insert into trade (trade_id, strategy_id, open_time, close_time) values (25, 1, '2022-09-06 15:43:33', '2022-09-06 16:13:33');
insert into trade (trade_id, strategy_id, open_time, close_time) values (26, 2, '2021-12-29 08:11:08', '2021-12-29 08:41:08');
insert into trade (trade_id, strategy_id, open_time, close_time) values (27, 4, '2022-02-24 14:16:03', '2022-02-24 14:46:03');
insert into trade (trade_id, strategy_id, open_time, close_time) values (28, 4, '2022-04-25 10:09:29', '2022-04-25 10:39:29');
insert into trade (trade_id, strategy_id, open_time, close_time) values (29, 1, '2022-02-02 22:18:54', '2022-02-02 22:48:54');
insert into trade (trade_id, strategy_id, open_time, close_time) values (30, 5, '2022-01-08 12:08:20', '2022-01-08 12:38:20');
insert into trade (trade_id, strategy_id, open_time, close_time) values (31, 5, '2022-01-23 11:09:39', '2022-01-23 11:39:39');
insert into trade (trade_id, strategy_id, open_time, close_time) values (32, 1, '2022-01-20 12:15:31', '2022-01-20 12:45:31');
insert into trade (trade_id, strategy_id, open_time, close_time) values (33, 3, '2022-04-17 11:06:10', '2022-04-17 11:36:10');
insert into trade (trade_id, strategy_id, open_time, close_time) values (34, 2, '2022-07-31 22:13:44', '2022-07-31 22:43:44');
insert into trade (trade_id, strategy_id, open_time, close_time) values (35, 4, '2022-03-19 20:13:20', '2022-03-19 20:43:20');
insert into trade (trade_id, strategy_id, open_time, close_time) values (36, 4, '2022-02-19 01:20:41', '2022-02-19 01:50:41');
insert into trade (trade_id, strategy_id, open_time, close_time) values (37, 4, '2022-01-27 16:47:16', '2022-01-27 17:17:16');
insert into trade (trade_id, strategy_id, open_time, close_time) values (38, 3, '2022-03-28 08:09:27', '2022-03-28 08:39:27');
insert into trade (trade_id, strategy_id, open_time, close_time) values (39, 2, '2022-08-30 05:15:01', '2022-08-30 05:45:01');
insert into trade (trade_id, strategy_id, open_time, close_time) values (40, 1, '2022-03-04 05:53:22', '2022-03-04 06:23:22');
insert into trade (trade_id, strategy_id, open_time, close_time) values (41, 5, '2021-12-24 00:15:13', '2021-12-24 00:45:13');
insert into trade (trade_id, strategy_id, open_time, close_time) values (42, 1, '2022-05-01 09:11:55', '2022-05-01 09:41:55');
insert into trade (trade_id, strategy_id, open_time, close_time) values (43, 2, '2022-07-30 03:26:45', '2022-07-30 03:56:45');
insert into trade (trade_id, strategy_id, open_time, close_time) values (44, 4, '2022-08-31 06:19:26', '2022-08-31 06:49:26');
insert into trade (trade_id, strategy_id, open_time, close_time) values (45, 1, '2022-07-18 09:54:48', '2022-07-18 10:24:48');
insert into trade (trade_id, strategy_id, open_time, close_time) values (46, 2, '2022-07-26 15:43:49', '2022-07-26 16:13:49');
insert into trade (trade_id, strategy_id, open_time, close_time) values (47, 2, '2022-01-22 15:29:31', '2022-01-22 15:59:31');
insert into trade (trade_id, strategy_id, open_time, close_time) values (48, 1, '2022-07-04 12:34:01', '2022-07-04 13:04:01');
insert into trade (trade_id, strategy_id, open_time, close_time) values (49, 4, '2022-11-30 19:57:48', '2022-11-30 20:27:48');
insert into trade (trade_id, strategy_id, open_time, close_time) values (50, 1, '2021-12-09 16:40:07', '2021-12-09 17:10:07');
insert into trade (trade_id, strategy_id, open_time, close_time) values (51, 2, '2022-05-12 23:45:43', '2022-05-13 00:15:43');
insert into trade (trade_id, strategy_id, open_time, close_time) values (52, 4, '2022-10-19 06:09:56', '2022-10-19 06:39:56');
insert into trade (trade_id, strategy_id, open_time, close_time) values (53, 4, '2022-04-20 19:16:06', '2022-04-20 19:46:06');
insert into trade (trade_id, strategy_id, open_time, close_time) values (54, 1, '2022-04-02 22:48:06', '2022-04-02 23:18:06');
insert into trade (trade_id, strategy_id, open_time, close_time) values (55, 1, '2022-05-23 04:50:04', '2022-05-23 05:20:04');
insert into trade (trade_id, strategy_id, open_time, close_time) values (56, 3, '2022-11-04 06:56:49', '2022-11-04 07:26:49');
insert into trade (trade_id, strategy_id, open_time, close_time) values (57, 4, '2022-02-19 18:58:14', '2022-02-19 19:28:14');
insert into trade (trade_id, strategy_id, open_time, close_time) values (58, 4, '2022-09-01 11:16:09', '2022-09-01 11:46:09');
insert into trade (trade_id, strategy_id, open_time, close_time) values (59, 2, '2022-08-18 19:41:55', '2022-08-18 20:11:55');
insert into trade (trade_id, strategy_id, open_time, close_time) values (60, 1, '2022-01-22 13:01:00', '2022-01-22 13:31:00');
insert into trade (trade_id, strategy_id, open_time, close_time) values (61, 1, '2022-10-11 22:19:35', '2022-10-11 22:49:35');
insert into trade (trade_id, strategy_id, open_time, close_time) values (62, 5, '2022-11-13 18:44:29', '2022-11-13 19:14:29');
insert into trade (trade_id, strategy_id, open_time, close_time) values (63, 3, '2022-06-06 10:05:07', '2022-06-06 10:35:07');
insert into trade (trade_id, strategy_id, open_time, close_time) values (64, 2, '2022-11-11 02:02:35', '2022-11-11 02:32:35');
insert into trade (trade_id, strategy_id, open_time, close_time) values (65, 2, '2022-05-13 20:58:38', '2022-05-13 21:28:38');
insert into trade (trade_id, strategy_id, open_time, close_time) values (66, 5, '2022-02-20 18:12:25', '2022-02-20 18:42:25');
insert into trade (trade_id, strategy_id, open_time, close_time) values (67, 5, '2022-03-03 14:17:43', '2022-03-03 14:47:43');
insert into trade (trade_id, strategy_id, open_time, close_time) values (68, 4, '2022-03-20 04:59:03', '2022-03-20 05:29:03');
insert into trade (trade_id, strategy_id, open_time, close_time) values (69, 4, '2022-03-29 20:56:43', '2022-03-29 21:26:43');
insert into trade (trade_id, strategy_id, open_time, close_time) values (70, 3, '2022-01-31 09:01:54', '2022-01-31 09:31:54');
insert into trade (trade_id, strategy_id, open_time, close_time) values (71, 1, '2022-08-07 14:46:23', '2022-08-07 15:16:23');
insert into trade (trade_id, strategy_id, open_time, close_time) values (72, 1, '2022-08-18 12:16:31', '2022-08-18 12:46:31');
insert into trade (trade_id, strategy_id, open_time, close_time) values (73, 5, '2022-03-06 04:40:37', '2022-03-06 05:10:37');
insert into trade (trade_id, strategy_id, open_time, close_time) values (74, 3, '2022-03-13 13:05:54', '2022-03-13 13:35:54');
insert into trade (trade_id, strategy_id, open_time, close_time) values (75, 1, '2022-01-20 04:24:43', '2022-01-20 04:54:43');
insert into trade (trade_id, strategy_id, open_time, close_time) values (76, 5, '2022-06-15 10:18:49', '2022-06-15 10:48:49');
insert into trade (trade_id, strategy_id, open_time, close_time) values (77, 2, '2022-07-31 15:14:50', '2022-07-31 15:44:50');
insert into trade (trade_id, strategy_id, open_time, close_time) values (78, 1, '2022-01-12 01:52:16', '2022-01-12 02:22:16');
insert into trade (trade_id, strategy_id, open_time, close_time) values (79, 3, '2022-08-31 12:26:48', '2022-08-31 12:56:48');
insert into trade (trade_id, strategy_id, open_time, close_time) values (80, 2, '2022-07-03 04:52:40', '2022-07-03 05:22:40');
insert into trade (trade_id, strategy_id, open_time, close_time) values (81, 3, '2022-11-10 20:24:13', '2022-11-10 20:54:13');
insert into trade (trade_id, strategy_id, open_time, close_time) values (82, 3, '2022-02-17 10:10:36', '2022-02-17 10:40:36');
insert into trade (trade_id, strategy_id, open_time, close_time) values (83, 1, '2022-03-13 23:45:00', '2022-03-14 00:15:00');
insert into trade (trade_id, strategy_id, open_time, close_time) values (84, 5, '2022-11-06 21:16:33', '2022-11-06 21:46:33');
insert into trade (trade_id, strategy_id, open_time, close_time) values (85, 1, '2022-10-12 10:53:26', '2022-10-12 11:23:26');
insert into trade (trade_id, strategy_id, open_time, close_time) values (86, 4, '2021-12-27 19:48:51', '2021-12-27 20:18:51');
insert into trade (trade_id, strategy_id, open_time, close_time) values (87, 1, '2022-11-07 18:10:29', '2022-11-07 18:40:29');
insert into trade (trade_id, strategy_id, open_time, close_time) values (88, 1, '2022-10-04 10:32:53', '2022-10-04 11:02:53');
insert into trade (trade_id, strategy_id, open_time, close_time) values (89, 1, '2022-07-06 23:29:21', '2022-07-06 23:59:21');
insert into trade (trade_id, strategy_id, open_time, close_time) values (90, 1, '2022-04-19 21:34:24', '2022-04-19 22:04:24');
insert into trade (trade_id, strategy_id, open_time, close_time) values (91, 2, '2022-08-17 23:56:10', '2022-08-18 00:26:10');
insert into trade (trade_id, strategy_id, open_time, close_time) values (92, 2, '2022-07-20 20:49:41', '2022-07-20 21:19:41');
insert into trade (trade_id, strategy_id, open_time, close_time) values (93, 2, '2022-08-30 23:20:44', '2022-08-30 23:50:44');
insert into trade (trade_id, strategy_id, open_time, close_time) values (94, 2, '2022-02-01 09:47:33', '2022-02-01 10:17:33');
insert into trade (trade_id, strategy_id, open_time, close_time) values (95, 2, '2021-12-18 01:11:04', '2021-12-18 01:41:04');
insert into trade (trade_id, strategy_id, open_time, close_time) values (96, 1, '2022-06-16 13:10:27', '2022-06-16 13:40:27');
insert into trade (trade_id, strategy_id, open_time, close_time) values (97, 3, '2022-02-02 02:47:11', '2022-02-02 03:17:11');
insert into trade (trade_id, strategy_id, open_time, close_time) values (98, 3, '2022-10-07 13:12:40', '2022-10-07 13:42:40');
insert into trade (trade_id, strategy_id, open_time, close_time) values (99, 2, '2022-03-11 22:47:44', '2022-03-11 23:17:44');
insert into trade (trade_id, strategy_id, open_time, close_time) values (100, 1, '2022-10-13 00:52:49', '2022-10-13 01:22:49');

-- trade_leg table

insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 1, 'BOH', '2022-06-18 09:50:58', '2022-06-18 10:20:58');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 2, 'PRKR', '2022-03-21 12:59:15', '2022-03-21 13:29:15');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 3, 'STT^G', '2022-01-01 12:06:22', '2022-01-01 12:36:22');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 4, 'CFX', '2022-09-03 23:14:07', '2022-09-03 23:44:07');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 5, 'DEST', '2022-01-20 18:08:27', '2022-01-20 18:38:27');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 6, 'UGP', '2022-07-28 01:46:14', '2022-07-28 02:16:14');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 7, 'BRKR', '2022-04-21 21:23:18', '2022-04-21 21:53:18');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 8, 'FL', '2022-05-01 12:32:09', '2022-05-01 13:02:09');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 9, 'CSV', '2022-07-27 03:55:26', '2022-07-27 04:25:26');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 10, 'UNXL', '2021-12-06 16:44:33', '2021-12-06 17:14:33');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 11, 'MUI', '2022-03-12 23:26:33', '2022-03-12 23:56:33');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 12, 'WSR', '2022-03-16 18:50:54', '2022-03-16 19:20:54');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 13, 'KNOP', '2022-05-29 20:49:43', '2022-05-29 21:19:43');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 14, 'LNN', '2022-06-27 23:41:23', '2022-06-28 00:11:23');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 15, 'CPAC', '2022-09-16 13:09:43', '2022-09-16 13:39:43');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 16, 'BML^I', '2022-10-23 22:13:20', '2022-10-23 22:43:20');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 17, 'CFBI', '2022-05-10 21:57:55', '2022-05-10 22:27:55');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 18, 'ONVO', '2022-02-21 06:37:48', '2022-02-21 07:07:48');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 19, 'CIGI', '2022-08-18 04:53:04', '2022-08-18 05:23:04');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 20, 'BV', '2022-01-29 08:36:11', '2022-01-29 09:06:11');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 21, 'AHPI', '2022-09-11 17:31:10', '2022-09-11 18:01:10');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 22, 'FOXA', '2022-05-26 06:57:21', '2022-05-26 07:27:21');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 23, 'CLNE', '2022-10-12 18:51:01', '2022-10-12 19:21:01');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 24, 'OMEX', '2022-08-26 05:20:15', '2022-08-26 05:50:15');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 25, 'PLXP', '2022-05-30 01:15:30', '2022-05-30 01:45:30');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 26, 'BBU', '2022-07-14 12:41:21', '2022-07-14 13:11:21');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 27, 'CDZI', '2022-02-21 16:20:13', '2022-02-21 16:50:13');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 28, 'JBK', '2022-06-01 05:12:08', '2022-06-01 05:42:08');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 29, 'CTIB', '2022-02-21 17:26:10', '2022-02-21 17:56:10');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 30, 'DPZ', '2022-03-18 07:33:13', '2022-03-18 08:03:13');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 31, 'CRVS', '2022-08-27 23:43:04', '2022-08-28 00:13:04');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 32, 'PSB', '2022-01-12 17:29:11', '2022-01-12 17:59:11');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 33, 'LXRX', '2022-10-12 13:30:42', '2022-10-12 14:00:42');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 34, 'POWI', '2022-08-24 18:12:35', '2022-08-24 18:42:35');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 35, 'LITB', '2022-10-01 07:13:36', '2022-10-01 07:43:36');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 36, 'DNR', '2022-06-11 06:54:46', '2022-06-11 07:24:46');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 37, 'BOE', '2022-05-31 14:09:19', '2022-05-31 14:39:19');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 38, 'SSRI', '2022-02-19 08:09:00', '2022-02-19 08:39:00');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 39, 'SKM', '2022-08-27 16:51:16', '2022-08-27 17:21:16');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 40, 'BQH', '2022-08-03 20:00:27', '2022-08-03 20:30:27');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 41, 'AWF', '2021-12-23 13:41:12', '2021-12-23 14:11:12');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 42, 'SMCI', '2022-11-20 15:29:16', '2022-11-20 15:59:16');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 43, 'KOSS', '2022-01-10 20:22:38', '2022-01-10 20:52:38');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 44, 'EVTC', '2022-10-23 03:52:05', '2022-10-23 04:22:05');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 45, 'HYI', '2022-06-02 14:42:12', '2022-06-02 15:12:12');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 46, 'TGNA', '2022-07-15 23:50:34', '2022-07-16 00:20:34');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 47, 'TRMB', '2022-06-21 17:31:59', '2022-06-21 18:01:59');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 48, 'MUH', '2022-06-25 07:56:20', '2022-06-25 08:26:20');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 49, 'JBSS', '2022-02-13 21:45:31', '2022-02-13 22:15:31');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 50, 'GTIM', '2022-09-29 01:05:47', '2022-09-29 01:35:47');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 51, 'CBRL', '2022-11-12 15:29:18', '2022-11-12 15:59:18');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 52, 'NNN', '2021-12-13 11:45:56', '2021-12-13 12:15:56');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 53, 'MNK', '2022-07-24 12:12:16', '2022-07-24 12:42:16');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 54, 'RUBI', '2022-07-02 21:42:40', '2022-07-02 22:12:40');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 55, 'LIVE', '2022-05-05 00:35:00', '2022-05-05 01:05:00');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 56, 'CEZ', '2022-08-15 00:06:54', '2022-08-15 00:36:54');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 57, 'WSFSL', '2022-10-24 10:14:50', '2022-10-24 10:44:50');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 58, 'GYB', '2022-10-26 19:24:31', '2022-10-26 19:54:31');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 59, 'UAL', '2022-02-22 13:51:07', '2022-02-22 14:21:07');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 60, 'TIF', '2022-02-21 12:47:41', '2022-02-21 13:17:41');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 61, 'MTB', '2022-10-27 00:05:58', '2022-10-27 00:35:58');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 62, 'AZRE', '2022-05-10 20:19:36', '2022-05-10 20:49:36');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 63, 'FPAY', '2022-04-25 15:27:46', '2022-04-25 15:57:46');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 64, 'AP', '2022-09-06 06:08:03', '2022-09-06 06:38:03');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 65, 'MLI', '2022-11-14 04:15:27', '2022-11-14 04:45:27');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 66, 'CUBI^F', '2022-12-02 12:02:19', '2022-12-02 12:32:19');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 67, 'LNTH', '2022-07-08 02:36:42', '2022-07-08 03:06:42');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 68, 'SSW', '2022-06-09 03:03:15', '2022-06-09 03:33:15');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 69, 'ENZY          ', '2022-04-06 04:49:10', '2022-04-06 05:19:10');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 70, 'XOMA', '2022-08-27 19:45:06', '2022-08-27 20:15:06');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 71, 'CASC', '2022-09-26 14:57:38', '2022-09-26 15:27:38');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 72, 'GGZ', '2022-01-22 04:47:15', '2022-01-22 05:17:15');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 73, 'PLBC', '2022-02-28 11:25:17', '2022-02-28 11:55:17');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 74, 'QRVO', '2022-04-24 21:38:24', '2022-04-24 22:08:24');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 75, 'ACSF', '2022-11-18 04:17:31', '2022-11-18 04:47:31');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 76, 'MLI', '2021-12-30 12:44:19', '2021-12-30 13:14:19');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 77, 'ATRO', '2022-09-21 07:39:36', '2022-09-21 08:09:36');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 78, 'AXAS', '2022-05-13 15:05:32', '2022-05-13 15:35:32');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 79, 'IPHS', '2022-06-11 05:17:32', '2022-06-11 05:47:32');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 80, 'MYN', '2022-10-22 20:09:11', '2022-10-22 20:39:11');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 81, 'WTFC', '2022-07-07 09:40:18', '2022-07-07 10:10:18');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 82, 'RRD', '2022-05-28 01:52:58', '2022-05-28 02:22:58');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 83, 'AES', '2022-02-22 03:56:04', '2022-02-22 04:26:04');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 84, 'PSTG', '2022-01-18 21:46:01', '2022-01-18 22:16:01');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 85, 'TFX', '2022-04-24 01:54:22', '2022-04-24 02:24:22');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 86, 'DAL', '2022-09-02 22:45:48', '2022-09-02 23:15:48');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 87, 'VEACW', '2022-03-23 05:40:53', '2022-03-23 06:10:53');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 88, 'ARTW', '2022-02-03 01:24:14', '2022-02-03 01:54:14');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 89, 'LGCY', '2022-03-08 18:31:51', '2022-03-08 19:01:51');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 90, 'NTEST.A', '2021-12-20 05:40:14', '2021-12-20 06:10:14');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 91, 'AI^B', '2022-07-05 11:59:39', '2022-07-05 12:29:39');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 92, 'AED', '2022-01-06 06:33:35', '2022-01-06 07:03:35');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 93, 'TVPT', '2022-04-27 20:07:01', '2022-04-27 20:37:01');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 94, 'REXR', '2022-05-16 10:24:17', '2022-05-16 10:54:17');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 95, 'MRDNW', '2022-12-02 07:30:44', '2022-12-02 08:00:44');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 96, 'GGG', '2022-11-23 09:20:53', '2022-11-23 09:50:53');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 97, 'LVS', '2022-03-01 15:03:44', '2022-03-01 15:33:44');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 98, 'IAC', '2022-05-28 17:33:51', '2022-05-28 18:03:51');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 99, 'ICLR', '2022-03-26 23:21:15', '2022-03-26 23:51:15');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values (1, 100, 'SPOK', '2022-05-27 21:52:16', '2022-05-27 22:22:16');
s
-- fill table
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('893459281', '1', '999221959', 'UMPQ', '5193', '539.5317', '2021-10-19 12:59:34', '2022-01-03 11:38:14');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('881132966', '1', '701487472', 'PVH', '9265', '919.3130', '2022-06-10 18:42:45', '2022-05-08 05:24:53');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('425781062', '2', '884851633', 'EFOI', '7130', '252.2400', '2021-12-22 12:34:31', '2022-08-18 22:17:12');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('135832727', '1', '884851633', 'ELEC', '7082', '907.5581', '2022-02-10 13:15:30', '2022-01-28 09:10:37');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('865865587', '1', '610493810', 'SRRA', '6705', '885.5957', '2022-06-20 15:24:39', '2022-11-06 20:47:12');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('427776515', '1', '719391855', 'AHPI', '3326', '515.3842', '2022-11-16 09:26:32', '2021-11-11 01:03:08');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('593761824', '1', '223809725', 'ESGE', '0719', '309.9214', '2021-09-24 14:41:13', '2022-09-27 19:22:01');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('226252951', '1', '090033453', 'AMOV', '5221', '698.6650', '2021-12-01 22:45:59', '2021-12-13 05:46:34');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('513688701', '2', '090033453', 'AHT^D', '7739', '194.7322', '2021-12-31 03:36:15', '2021-10-03 19:27:10');
insert into fill (fill_id, leg_no, trade_id, contract, qty, avg, placement_time, filled_time) values ('549155019', '3', '090033453', 'EVK', '8633', '691.1788', '2022-10-11 20:15:10', '2022-02-02 01:43:54');