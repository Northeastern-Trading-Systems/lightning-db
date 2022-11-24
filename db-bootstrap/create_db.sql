CREATE DATABASE nts_lightning_db;
CREATE USER 'webapp'@'%' IDENTIFIED BY 'K%7VEJ80Et7M';
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
    strategy_id varchar(50),
    open_time datetime,
    close_time datetime,
    PRIMARY KEY (trade_id),
    CONSTRAINT fk_1 
        FOREIGN KEY (strategy) REFERENCES strategy (strategy_id)
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
    CONSTRAINT fk_1
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
    avg float(64),
    placement_time datetime,
    filled_time datetime,
    PRIMARY KEY (fill_id),
    CONSTRAINT fk_1
        FOREIGN KEY (leg_no, trade_id) REFERENCES trade_leg (leg_no, trade_id)
        ON UPDATE cascade ON DELETE restrict
);

-- DEMO DATA:
-- Dummy data acquired by Mockaroo

-- strategy Table
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Roble Beech', '1', 'webs.com', '2022-08-28 06:10:15', '2022-10-25 21:02:22');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Shortleaf Crabgrass', '2', 'blogger.com', '2022-04-06 10:44:49', '2022-09-28 08:54:25');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Sonoran Maiden Fern', '3', 'walmart.com', '2022-03-13 14:35:47', '2022-10-23 16:15:07');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Kauai Hau Kuahiwi', '4', 'macromedia.com', '2021-12-20 01:53:38', '2022-11-15 00:19:07');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Fanwort', '5', 'sakura.ne.jp', '2022-04-04 20:41:56', '2022-10-03 00:19:31');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Crown Brodiaea', '6', 'msn.com', '2022-07-01 04:12:12', '2022-09-29 23:57:21');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Jeruselem Thorn', '7', 'archive.org', '2022-02-10 11:26:44', '2022-11-18 12:35:16');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Forbestown Rush', '8', 'time.com', '2022-06-17 12:26:05', '2022-10-26 08:03:45');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Alabama Azalea', '9', 'huffingtonpost.com', '2022-08-26 08:13:48', '2022-10-27 06:08:47');
insert into strategy (strategy_name, strategy_id, documentation_link, launch_date, termination_date) values ('Brushpea', '10', 'ameblo.jp', '2022-04-06 05:31:35', '2022-10-27 09:48:29');

-- trade Table
insert into trade (trade_id, strategy_id, open_time, close_time) values ('999221959', '5', '2022-10-05 07:52:49', '2022-03-28 00:25:25');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('701487472', '7', '2021-12-28 04:01:04', '2022-07-15 03:15:57');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('884851633', '6', '2022-04-18 03:32:50', '2022-06-03 01:47:14');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('610493810', '9', '2022-09-17 08:52:09', null);
insert into trade (trade_id, strategy_id, open_time, close_time) values ('719391855', '3', '2022-04-01 18:12:47', '2021-10-04 01:15:40');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('223809725', '5', '2022-05-16 05:27:22', '2022-07-02 08:26:23');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('090033453', '0', '2022-10-21 17:15:32', '2021-11-29 17:35:46');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('807072190', '4', '2022-04-08 13:24:38', null);
insert into trade (trade_id, strategy_id, open_time, close_time) values ('795636734', '1', '2022-04-11 00:52:21', '2022-09-26 10:03:32');
insert into trade (trade_id, strategy_id, open_time, close_time) values ('122174893', '9', '2021-12-27 12:43:49', null);

-- trade_leg table
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '999221959', 'BCS^D', '2021-10-18 16:49:04', '2022-11-14 14:37:41');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '701487472', 'SMCP', null, null);
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('2', '701487472', 'SKOR', '2022-02-07 01:09:47', '2022-04-16 10:56:28');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '884851633', 'NYCB^U', null, null);
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '610493810', 'BHL', '2022-04-03 09:01:24', '2022-06-03 12:42:29');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '719391855', 'SBH', '2022-06-30 09:38:56', '2022-03-20 20:02:52');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '223809725', 'FDEF', '2022-06-03 13:53:47', '2022-07-01 06:29:14');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('1', '090033453', 'EAGL', '2022-02-22 07:40:22', '2022-07-04 09:33:05');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('2', '090033453', 'AETI', '2021-10-17 06:05:32', '2022-07-22 08:52:09');
insert into trade_leg (leg_no, trade_id, contract, open_time, close_time) values ('3', '090033453', 'IPGP', '2022-03-27 05:01:33', '2022-06-15 09:33:04');

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