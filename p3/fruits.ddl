--Schema for Fresh Juice business database

DROP SCHEMA IF EXISTS fruits CASCADE;
CREATE SCHEMA fruits;
SET SEARCH_PATH to fruits;

--table Store, represent for the mltiple stores the business own. 
--Each store has 3 attributes: city, phone, and manager. city is primary key.
--Since there is only one store per city, I choose using city as the store name.


CREATE TABLE Store(
    city VARCHAR(50) primary key,
    --The location\actual name of the store.
    phone INT NOT NULL,
    --The phone number of the store.
    manager VARCHAR(50) NOT NULL
    --The name of the manager who mangage this store.
);


--table JuiceType, represent for different juice names the business sell.
--Each JuiceType has 2 attributes: juice, cal. Juice is the primary key.  
CREATE TABLE JuiceType(
    juice VARCHAR(50) primary key,
    --the name of the juice the business sell.
    cal INT NOT NULL check (cal >= 0) 
    --The calories of the REGULAR size juice contain, notice that we differ the size in table Transactions.
);


--table LoyaltyCard, represent for a vip card of a store if a customer go to that store a lot.
--Each LoyaltyCard has 2 attributes: card_id, home_store. card_id is the primary key.
CREATE TABLE LoyaltyCard(
    card_id INT primary key,
    --the loyalty card number identify each card provided.
    home_store VARCHAR(50) REFERENCES Store(city) NOT NULL
    --the name i.e.city of the store a custormer goes most frequently, since it must be one of the store in our business, it is the foreign key of Store
); 


--table StoreStock, represent for the inventory\stock of various juices for each store.
--Each Store has 3 attributes: city, juice, stock. The combination of city and juice are the primary key.
--Notice that stock should be non-negtive since it means how many bottles left.
CREATE TABLE StoreStock(
    city VARCHAR(50) REFERENCES Store(city),
    juice VARCHAR(50) REFERENCES JuiceType(Juice),
    stock INT NOT NULL,
    CHECK (stock >=0),


    primary key (city, juice)
);


--table Transactions, represent each time dealing order record. 
--Each Transactions have 8 attributes: city, juice, size_up, trans_id, date, price, card_id, order_num.
--trans_id is the primary key, and city, juice, card_id are foreign key reference to table StoreStock and LoyaltyCard.
--Notice that (card_id, order_num) should be unique, that is canbe null since some transactions may not apply LoyaltyCard.
--Also (trans_id, juice) should be unique since each transaction only purchase one juice.
CREATE TABLE Transactions(
    city VARCHAR(50) NOT NULL,
    --The loacation\name of store the transaction occured.
    juice VARCHAR(50) NOT NULL,
    --The juice name of this transaction sold.
    size_up BOOLEAN NOT NULL,
    --Record whether the juice is larger size or not(Notice that large size always have 200 more calories than regular size.)
    trans_id INT primary key,
    --The transaction id each transaction made.
    date DATE NOT NULL,
    --The date when the transaction made.
    price FLOAT NOT NULL,
    --The price the juice sold.
    card_id INT REFERENCES LoyaltyCard(card_id),
    --The loyalty card id used when transaction occurs, if applicable.
    order_num INT,
    --THe number of order the loyalty card made.
    FOREIGN KEY(city, juice) REFERENCES StoreStock(city, juice),
    --Constraints on city, juice since each transaction base on the stroe stock.
    UNIQUE(card_id, order_num),
    UNIQUE(trans_id, juice)
);

--Now we add some useful data in our table.

--Insert 2 store information in Store.
INSERT INTO Store VALUES ('Trt', 123456, 'Jinny');
INSERT INTO Store VALUES ('NY', 123456, 'Bob');

--Insert 2 juice infotmation in JuiceType.
INSERT INTO JuiceType VALUES ('Lime', 180);
INSERT INTO JuiceType VALUES ('Grape', 204);

--Insert 1 loyaltycard infotmation in LoyaltyCard.
INSERT INTO LoyaltyCard VALUES (7777, 'Trt');

--Insert 3 stock information in StoreStock.
INSERT INTO StoreStock VALUES ('Trt',  'Lime', 170);
INSERT INTO StoreStock VALUES ('NY', 'Grape', 89);
INSERT INTO StoreStock VALUES ('NY', 'Lime', 77);

--Insert 4 transaction information in Transactions.
INSERT INTO Transactions VALUES ('Trt','Lime', FALSE, 1, '2019-01-01', 1.99, 7777, 3);
INSERT INTO Transactions VALUES ('NY','Lime', TRUE, 2, '2019-01-02', 2.99, 7777, 4);
INSERT INTO Transactions VALUES ('Trt','Lime', FALSE, 3, '2019-01-01', 1.99, NULL, NULL);
INSERT INTO Transactions VALUES ('NY','Grape', FALSE, 4, '2019-01-01', 2.99, 7777, 5);
