#We drop the Database in the beginning in order to make sure, that it is always up to date
DROP DATABASE if exists foodapp;
CREATE DATABASE IF NOT EXISTS foodapp;
USE foodapp;

###############################################################################################################
#CREATION OF TABLES
###############################################################################################################

CREATE TABLE IF NOT EXISTS `Supermarkets` (
  `Supermarket_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Location_ID` int NOT NULL,
  `Supermarket_NAME` varchar(40) NOT NULL
);

CREATE TABLE IF NOT EXISTS `Supermarket_Items` (
  `Super_Item_ID` int primary key AUTO_INCREMENT,
  `Item_ID` int NOT NULL,
  `Supermarket_ID` int NOT NULL,
  `Item_Price` float NOT NULL,
   `Stock` int NOT NULL
);

CREATE TABLE IF NOT EXISTS `country` (
  `country_ID` int PRIMARY KEY AUTO_INCREMENT,
  `country_name` VARCHAR(50) NOT NULL);

CREATE TABLE IF NOT EXISTS `city` (
  `city_ID` int PRIMARY KEY AUTO_INCREMENT,
  `city_name` VARCHAR(50) NOT NULL, 
  `country_ID` int NOT NULL,
   Foreign KeY (`country_id`)
	References `country` (`country_ID`)
    On DELETE Restrict  #A country column shouldn't be deleted
    ON UPDATe Restrict
  );
  
  CREATE TABLE IF NOT EXISTS `postal_codes`(
  `postal_code_id` int primary key auto_increment, 
  `postal_code` varchar(7) NOT NULL, 
  `city_id` int NOT NULL,
  Foreign KeY (`city_id`)
	References `city` (`city_ID`)
    On DELETE Restrict  #A whole city  shouldn't be deleted
    ON UPDATe Restrict);
  

CREATE TABLE IF NOT EXISTS `Location` (
  `Location_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Street_Name` varchar(255) NOT NULL,
  `House_NR` varchar(5) NOT NULL,
  `Postal_Code_ID` int NOT NULL,
   Foreign KeY (`postal_code_id`)
	References `postal_codes` (`postal_code_id`)
    On DELETE Restrict #A whole postal code area shouldn't be deleted...
    ON UPDATE Restrict #...or updated
);

CREATE TABLE IF NOT EXISTS `Contact` (
  `Contact_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Location_ID` int NOT NULL, 
  `First_Name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `Gender` varchar(255) default NULL, #Gender is not mandatory
  `Phone_number` varchar(15) NOT NULL,
  `E_Mail` varchar(255) NOT NULL, 
  `Bank_Info_MD5_Hash` varchar(255) NOT NULL #We are not saving the original information of the bank details but a MD5 Hash
);

CREATE TABLE IF NOT EXISTS `Drivers` (
  `Driver_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Contact_ID` int NOT NULL,
  `employment_start_date` date NOT NULL
);

    
CREATE TABLE IF NOT EXISTS `Users` (
  `User_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Contact_ID` int NOT NULL
  );
    
CREATE TABLE IF NOT EXISTS `Reviews` (
  `Review_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Order_ID` int NOT NULL,
  `Rating` int(1) NOT NULL, #if you submitted a review you are forced to submit a rating from 1-5 stars
  `Comment` varchar(255) default null, #The comment is optional
  Check(`Rating` > 0 and `Rating` <6) #This makes sure that only stars from one to 5 are givrn
	);
  
    
create table if not exists `Items` (
  `Item_ID` int Primary key AUTO_INCREMENT, 
  `Item_Name` varchar(50) NOT NULL,  #We restrict the number of characters in order to control for data quality
  `Item_Brand` varchar(50) NOT NULL,
  `Item_Category` varchar(100) NOT NULL);
  
CREATE TABLE IF NOT EXISTS `Payments` (
  `Payment_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Order_ID` int NOT NULL,
  `Total` float(6, 2) NOT NULL,  #The total value of the order WITHOUT the fee for delivery
  `Fee` float(6,2) NOT NULL,
  `Payment_info` varchar(255) NOT NULL #The payment info of the customer
);  
    
#Promotions Table and values
CREATE TABLE IF NOT EXISTS `Promotions` (
  `Promo_Code` varchar(255) PRIMARY KEY,
  `Promo_Name` varchar(255) NOT NULL, 
  `Discount` float(2,2) NOT NULL,
  `Start_Date` date NOT NULL,
  `End_Date` date NOT NULL
);      

#Insert values into promotion
INSERT INTO promotions VALUES("CARNIVAL","Carnival",0.15,"2022-02-15","2022-02-17");
INSERT INTO promotions VALUES("FESTIVE_SEASON","Freedom Day and Easter",0.20,"2022-04-04","2022-04-25");
INSERT INTO promotions VALUES("EASTER_PARTY","Easter Holidays",0.15,"2021-04-20","2021-04-27");
INSERT INTO promotions VALUES("EASTER2020","Easter Holidays",0.10,"2020-04-20","2020-04-27");
INSERT INTO promotions VALUES("PORTUGAL_LOVE","Portugal National Day",0.05,"2021-06-09","2021-06-11");
INSERT INTO promotions VALUES("RONALDOGO!","Portugal National Day",0.05,"2022-06-09","2022-06-10");
INSERT INTO promotions VALUES("HOHOHO!","Christmas and New Year",0.20,"2021-12-17","2022-01-03");
INSERT INTO promotions VALUES("MERRY_CHRISTMAS","Christmas and New Year",0.15,"2022-12-17","2023-01-01");


CREATE TABLE IF NOT EXISTS `Opening_Hours` (
  `Opening_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Supermarket_ID` int NOT NULL, 
  `Weekday_ID` int NOT NULL, 
  `Opening_time` time NOT NULL,
  `Closing_time` time NOT NULL
	);

CREATE TABLE IF NOT EXISTS `Weekdays` (
  `Weekday_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Weekday` varchar(9) NOT NULL
	);
    
create table if not exists `Orders`(
  `Order_ID` int PRIMARY KEY AUTO_INCREMENT,
  `Supermarket_ID` int NOT NULL,
  `Promo_Code` varchar(255) default null,
  `User_ID` int NOT NULL,
  `Driver_ID` int NOT NULL,
  `Order_Date` DATETIME NOT NULL,
  Foreign KeY (`USER_ID`)
	References `Users` (`User_ID`)
    On DELETE Cascade #If an user wishes to have all his data removed we are obliged by GDPR 
    ON UPDATe CASCADE,
Foreign KeY (`DRIVER_ID`)
	References `Drivers` (`Driver_ID`)
    On DELETE cascade #If a driver wishes to have all his data removed we are obliged by GDPR 
    ON UPDATe CASCADE,
Foreign KeY (`Supermarket_ID`)
	References `Supermarkets` (`Supermarket_ID`)
    On DELETE Restrict #We can't afford to lose all the orders from one restaurants, as it is used by various functions
    ON UPDATe CASCADE,
	Foreign KeY (`Promo_Code`) 
	References `Promotions` (`Promo_Code`) 
 On DELETE restrict #can't be deleted as the information is needed to generate the invoice
ON UPDATe CASCADE


  );
  

  create table if not exists `Order_Items`(
  `Order_ID` int NOT NULL,
  `Super_Item_ID` int not null, 
  `Quantity` int not null,
  Primary Key (`Super_Item_ID`, `Order_ID`),
Foreign KeY (`Super_Item_ID`)
	References `Supermarket_Items` (`Super_Item_ID`)
    On DELETE RESTRICT #Important information about user behaviour, needs to be preserved
    ON UPDATe CASCADE, 
Foreign KeY (`Order_ID`)
	References `Orders` (`Order_ID`)
    On DELETE Cascade #user information 
    ON UPDATe CASCADE);
    
 #Create a log table for when the price of a product is changed 
CREATE TABLE IF NOT EXISTS `log` (
  `log_ID` int unsigned PRIMARY KEY AUTO_INCREMENT,
  `admin_id` varchar(255) NOT NULL,
  `Change_time` datetime NOT NULL, 
  `Super_Item_ID` int NOT NULL,
  `Old_Price` float(6,2) NOT NULL,
  `New_Price` float(6,2) NOT NULL
);     

###############################################################################################################
#ALTERING TABLES IN ORDER TO ADD FOREIGN KEYS
###############################################################################################################

ALTER TABLE `Supermarket_Items`
ADD CONSTRAINT `fk_supermarkets_Items_1`
   Foreign KeY (`Item_ID`)
	References `Items` (`Item_ID`)
    On DELETE RESTRICT  #Items should never be deleted
    ON UPDATe CASCADE, 
ADD CONSTRAINT `fk_supermarkets_Items_2`
   Foreign KeY (`Supermarket_ID`)
	References `Supermarkets` (`Supermarket_ID`)
    On DELETE restrict #important customer behaviour data - shouldn't be deleted 
    ON UPDATe CASCADE;

Alter table `Reviews`
ADD CONSTRAINT `fk_reviews_1`
Foreign KeY (`Order_ID`)
	References `Orders` (`Order_ID`)
    On DELETE Cascade #If an order is deleted for whatever reason, the review should also be deleted as it doesn't make any sense without the order information and could contain customer info
    ON UPDATe CASCADE;


ALTER TABLE `Supermarkets`
ADD CONSTRAINT `fk_supermarkets_1`
   Foreign KeY (`Location_ID`)
	References `Location` (`Location_ID`)
    On DELETE Restrict #Very important information for the drivers
    ON UPDATe CASCADE;

ALTER TABLE `Contact`
ADD CONSTRAINT `fk_location_1`
Foreign KeY (`Location_ID`)
	References `location` (`Location_ID`)
    On DELETE Cascade #Needs to be able to be deleted if the customer/driver requests it
    ON UPDATe CASCADE;
  
ALTER TABLE `Drivers`
ADD CONSTRAINT `fk_Drivers_1`
   Foreign KeY (`Contact_ID`)
	References `Contact` (`Contact_ID`)
    On DELETE Cascade #needs to be deleted if the driver requests it (GDPR)
    ON UPDATe CASCADE;
    
ALTER TABLE `Users`
ADD CONSTRAINT `fk_Users_1`
    Foreign KeY (`Contact_ID`)
	References `Contact` (`Contact_ID`)
    On DELETE Cascade #needs to be deleted if the user requests it (GDPR)
    ON UPDATe CASCADE;

    
Alter Table `Opening_hours`
  Add constraint `fk_opening_hours_1`
  Foreign KeY (`Supermarket_ID`)
	References `Supermarkets` (`Supermarket_ID`)
    On DELETE cascade # we won't need the information if the supermarket is not on the app anymore
    ON UPDATe CASCADE,
    Add constraint `fk_opening_hours_2`
Foreign KeY (`Weekday_ID`)
	References `Weekdays` (`Weekday_ID`)
    On DELETE Restrict #A weekday shouldn't be deleted or updated as it is important for queries/triggers
    ON UPDATe Restrict;
    
Alter Table `Payments`
Add constraint `fk_payments_1`
Foreign KeY (`Order_ID`)
	References `Orders` (`Order_ID`)
    On DELETE Cascade #Doens't give any information without the order and could contain customer information
    ON UPDATe Cascade;

###############################################################################################################
#CREATING TRIGGERS FOR LOG, DATA GOVERNANCE AND AUTOMATIC STOCK UPDATES
###############################################################################################################
#--------------------------------------------------------------------------------------------------------------
#Create Trigger: add promotion to order 
# We are checking if the order falls into a promotion date. If that is the case we will deduct a percentage of the total value of the order.
Delimiter $$
create trigger
add_promo
before insert on Orders
for each row
begin 
   set new.promo_code = (select promo_code from promotions where new.Order_Date between start_date and end_date);
end$$
Delimiter ;    

#--------------------------------------------------------------------------------------------------------------
#Create Trigger: Update Payment Information 
# To ensure data consistency and correctness we calculate the payment values, which are also used for the invoices via a trigger
# This is particularly important as we offer discounts for important events and also take a percentage of the order value as a fee
# This table has a 1:1 relationship with the orders table, as there is only one payment per order
# The payment date is also equal to the order date, as users have to deposit a credit-card, to ensure solvency

Delimiter $$
create trigger
fill_payment
after insert on Order_Items
for each row
begin

#Check of the Order_ID is already within the payments table
if new.Order_ID not in (select distinct order_id from payments) then
	insert into payments (payment_id, order_id, total, fee, payment_info)
	values (
    new.order_id, #Payment_ID
    new.order_id, #Order_ID
    
    #Calculate Total order value
	(select sum(quantity*item_price) total from  order_items as oi 
	join supermarket_items using (super_item_id) where oi.order_id = new.order_id
	group by order_id) * 
    
    #Add discount
    (1-(select
		ifnull(discount, 0) 
		from  orders
		left join promotions using (Promo_code)
		where order_id = new.order_id)), #Order Value (Price x Quantity x Discount) 
                            
    #Add Fee percentage here
    (0.30*(select sum(quantity*item_price) total from  order_items as oi 
	join supermarket_items using (super_item_id) where oi.order_id = new.order_id
	group by order_id)), 
    
    #Add Hashed Payment Information
    (select bank_info_md5_hash from contact
    join users  using (contact_id)
    join orders o using (user_id)
    where o.order_id =new.order_id
    group by order_id));
    
#If the order_id was already in payments we update the row
else 
	update payments
    #Update Totals
    set total =(select sum(quantity*item_price) total from  order_items as oi 
	join supermarket_items using (super_item_id) where oi.order_id = new.order_id
	group by order_id)*
    
    #Add discount 
    (1-(select
			ifnull(discount, 0) 
			from  orders
			left join promotions using (Promo_code)
			where order_id = new.order_id)), 
            
    #Update Fee
    fee = ((select sum(quantity*item_price) total from  order_items as oi 
	join supermarket_items using (super_item_id) where oi.order_id = new.order_id
	group by order_id)*(1-(select
							ifnull(discount, 0) 
							from  orders
							left join promotions using (Promo_code)
							where order_id = new.order_id)))*0.30
                            
    where order_id = new.order_id
    ;
end if;
end$$
Delimiter ;

#--------------------------------------------------------------------------------------------------------------
#Create Trigger: Update Stock 
# This trigger updates the stock after an order
# It ensures that the stock is always up to date and no customer can order a product, which is not available
# if there is not enough stock, it will throw an error

Delimiter $$
create trigger
update_stock
after insert on Order_Items
for each row
begin
if new.quantity < (select stock from supermarket_items si where new.super_item_id = si.super_item_id) then
	update supermarket_items
    set stock = stock-new.quantity
    where super_item_id = new.super_item_id;
    else
    SIGNAL SQLSTATE '45000'
	set message_text = 'Out of stock!';
    end if;
end$$
Delimiter ;

#--------------------------------------------------------------------------------------------------------------
#Creating a Trigger that saves an update of the price to the log table
#Any price changes are saved in an independent log table to ensure data consistency and traceability

Delimiter $$
create trigger
log_price
before update on Supermarket_Items 
for each row
begin
if new.item_price != (select item_price from supermarket_items si where new.super_item_id = si.super_item_id) then
insert into log (admin_id, change_time, super_item_id, old_price, new_price)
values(user(), now(), new.super_item_id, (select item_price from Supermarket_Items  si where si.super_item_id = new.super_item_id), new.item_price);
end if;
end$$
Delimiter ;

#--------------------------------------------------------------------------------------------------------------
#Create a trigger to check if the supermarket is open at the time of order 
#To make sure that no one orders from a supermarket, which is closed, a trigger is created to throw an error if that happens

Delimiter $$
create trigger
supermarket_open
before insert on orders
for each row
begin

if time(new.order_date) <

	(select time(opening_time) from weekdays
	join opening_hours using  (weekday_id)
	where  (weekday(new.order_date)+1) = weekdays.weekday_id and 
	new.supermarket_id= opening_hours.Supermarket_ID)
or
time(new.order_date)>

	(select time(closing_time) from weekdays
	join opening_hours using  (weekday_id)
	where  (weekday(new.order_date)+1) = weekdays.weekday_id and 
	new.supermarket_id= opening_hours.Supermarket_ID) 
    then

    SIGNAL SQLSTATE '45000'
	set message_text = 'The store is closed!';
    end if;
end$$
Delimiter ;

    
###############################################################################################################
#Populating Tables (including orders over the last two years
###############################################################################################################

INSERT INTO country VALUES(1, "Portugal");

#City
INSERT INTO city VALUES(1, "Lisboa",1);
INSERT INTO city VALUES(2, "Aveiro",1);

#Postal Codes
INSERT INTO postal_codes (`Postal_Code`, `City_id`) values
(1000036,1), 
(4520406,1), 
(1000024,1), 
(1750025,1), 
(4520301,1), 
(2460122,1),
(4560185,1), 
(4560097,1), 
(1750412,1), 
(3880696,1), 
(1000027,1), 
(1000005,1),
(3550303,1), 
(3550688,1), 
(1000055,1),
(1750302,1), 
(2795157,1),
(4755043,1), 
(4520405,1), 
(4650289,1), 
(4520308,1), 
(1000025,1), 
(4520301,1), 
(6354123,2), 
(5841098,2);





#Locations
INSERT INTO location VALUES (1,"Rua Jorge Sena",49,1);
INSERT INTO location VALUES (2,"Rua Ciprestes",92,2);
INSERT INTO location VALUES (3,"R Afonso Albuquerque",88,3);
INSERT INTO location VALUES (4,"R Velhas",89,4);
INSERT INTO location VALUES (5,"Estrada Abrantes",10,5) ;
INSERT INTO location VALUES (6,"R Frei Fortunato",6,6);
INSERT INTO location VALUES (7,"R Figueiras",91,7);
INSERT INTO location VALUES (8,"Avenida João Crisóstomo",2, 8);
INSERT INTO location VALUES (9,"Rua Doutor Teófilo Braga",33,9);
INSERT INTO location VALUES (10,"Colónia Agrícola Casal",77, 10);
INSERT INTO location VALUES (11,"Avenida Nova",96,11);
INSERT INTO location VALUES (12,"Quinta Lama",29,12);
INSERT INTO location VALUES (13,"R Portela",62,13);
INSERT INTO location VALUES (14,"R Goa",71,14);
INSERT INTO location VALUES (15,"Avenida Liberdade",75, 15);
INSERT INTO location VALUES (16,"R Florbela Espanca",3, 16);
INSERT INTO location VALUES (17,"Rua Índia",16, 17);
INSERT INTO location VALUES (18,"R Cruzes",59, 18);
INSERT INTO location VALUES (19,"R Projectada",100, 19);
INSERT INTO location VALUES (20,"Rua Heróis Ultramar",34, 20);
INSERT INTO location VALUES (21,"R Maria M Tavares",11, 21);
INSERT INTO location VALUES (22,"R Cimo Povo",34, 22);
INSERT INTO location VALUES (23,"Rua Doutor José Marques",115,23);
INSERT INTO location VALUES (24,"R Flores de Jesus",49, 24);
INSERT INTO location VALUES (25,"Rua Doutor João Vasconcelos",115,25);

#Contact------------------------------------------------------------------------------------------
INSERT INTO contact VALUE(1,1,"Iris", "Magalhães","Female",961262184,"azevedo.beatriz@clix.pt", "fa22b062734dcb7c93e4e0b11dc19d89");
INSERT INTO contact VALUE(2,2,"Verónica" ,"Amorim","Female",+351912710971,"mariana.rocha@gaspar.pt", "cfefa787e8f04fd221590e383edcca50");
INSERT INTO contact VALUE(3,3,"Davi","Neves","Male",+351964391021,"nadia.figueiredo@gmail.com", "7b4f0a9fec988ab4cc6734ad5b6511c2");
INSERT INTO contact VALUE(4,4,"Vicente", "Oliveira","Male",272431976,"marta48@clix.pt", "63c48f3347aa2143933353b23c339eef");
INSERT INTO contact VALUE(5,5,"Eduardo", "Pires","Male",+351285289094,"francisca.borges@ramos.com", "46d8db63057b887c2b5b0da2d08e451e");
INSERT INTO contact VALUE(6,6,"Hélder", "Melo","Male",937864888,"david.vicente@abreu.pt", "bc07540674eacd05c451479950b2f629");
INSERT INTO contact VALUE(7,7,"Teresa" ,"Machado","Female",+351965571527,"lisandro.melo@yahoo.com", "4553f78d1352c62a67f6cce6f40d9686");
INSERT INTO contact VALUE(8,8,"Micael", "Maia","Male",+351293415882,"francisco.sa@yahoo.com", "5b0f0ea5c7f288198eb407f8f691ffb0");
INSERT INTO contact VALUE(9,9,"Luís",  "Matias","Male",+351220694092,"ncarneiro@sapo.pt", "51b15f3b10dbb5b5746bf3e1993bc204");
INSERT INTO contact VALUE(10,10,"Vicente", "Sá","Male",269556487 ,"mateus.almeida@pereira.pt", "a1cac920acedd07e9a2203b6f65bafbb");
INSERT INTO contact VALUE(11,11,"Salvador","Freitas","Male",256505660,"simoes.iris@yahoo.com", "08c07fe727f510331989042b4ca0cc8e");
INSERT INTO contact VALUE(12,12,"Mateus", "Araújo","Male",+351211098874,"wrodrigues@matias.com", "bff3b8f83933df81bc66b30fc2ba39a4");
INSERT INTO contact VALUE(13,13,"Leandro", "Antunes","Male",935532103,"diego08@mendes.pt", "dd2a441ba9eb63c4f30f7745b4f1fe45");
INSERT INTO contact VALUE(14,14,"Emanuel", "Carneiro","Male",914114691,"claudia.faria@cardoso.com", "8e494594f3fb22f271c28203187b67e5");
INSERT INTO contact VALUE(15,15,"Liliana", "Pinto","Female",+351938754395,"carolina16@hotmail.com", "215e70226b7e8bdabccb36aa06bbff50");
INSERT INTO contact VALUE(16,16,"Salvador", "Silva","Male",+351297109037,"azevedo.kevin33@mail.pt", "037ac64877315d0ea699b93cfbb1395c");
INSERT INTO contact VALUE(17,17,"Henrique", "Barbosa","Male",+351287512322,"hsimoes@clix.pt", "a34a739b9a39044051a0d7015a1cf0be");
INSERT INTO contact VALUE(18,18,"Filipe", "Morais","Male",298030496,"debora.antunes@rodrigues.pt", "367919f3ae0300a1b8a3f385bc9a8b92");
INSERT INTO contact VALUE(19,19,"Sandro", "Morais","Male",+351240070812,"lourenco.julia@branco.com", "9be7b9db798d7062801e9579ee9c90e9");
INSERT INTO contact VALUE(20,20,"Ema", "Campos","Female",211340740,"martim.alves@carneiro.org", "f92f497de6d201391103b32ff468d71e");
INSERT INTO contact VALUE(21,25,"Maria", "Joana","Female",215390745,"joanitas@gmail.com", "rt2g497dsd25691153b32ff468d71k");

#Users------------------------------------------------------------------------------------------
INSERT INTO users VALUES(1,1);
INSERT INTO users VALUES(2,2);
INSERT INTO users VALUES(3,3);
INSERT INTO users VALUES(4,4);
INSERT INTO users VALUES(5,5);
INSERT INTO users VALUES(6,6);
INSERT INTO users VALUES(7,7);
INSERT INTO users VALUES(8,8);
INSERT INTO users VALUES(9,9);
INSERT INTO users VALUES(10,10);
INSERT INTO users VALUES(11,11);
INSERT INTO users VALUES(12,12);
INSERT INTO users VALUES(13,13);
INSERT INTO users VALUES(14,14);
INSERT INTO users VALUES(15,15);
INSERT INTO users VALUES(16,16);
INSERT INTO users VALUES(17,17);
INSERT INTO users VALUES(18,18);
INSERT INTO users VALUES(19,19);
INSERT INTO users VALUES(20,20);
INSERT INTO users VALUES(21,21);

#Drivers------------------------------------------------------------------------------------------
INSERT INTO drivers VALUES(1, 1, '2020-05-06');
INSERT INTO drivers VALUES(2, 8, '2020-05-20');
INSERT INTO drivers VALUES(3, 10, '2020-10-08');
INSERT INTO drivers VALUES(4, 11, '2020-01-05');
INSERT INTO drivers VALUES(5, 16, '2020-08-09');
INSERT INTO drivers VALUES(6, 18, '2021-12-09');
INSERT INTO drivers VALUES(7, 20, '2022-08-09');
INSERT INTO drivers VALUES(8, 21, '2022-11-25');

#Weekdays (like the weekday() funtion------------------------------------------------------------------------------------------
INSERT INTO weekdays VALUES(1, "Monday");
INSERT INTO weekdays VALUES(2, "Tuesday");
INSERT INTO weekdays VALUES(3, "Wednesday");
INSERT INTO weekdays VALUES(4, "Thursday");
INSERT INTO weekdays VALUES(5, "Friday");
INSERT INTO weekdays VALUES(6, "Saturday");
INSERT INTO weekdays VALUES(7, "Sunday");


#Supermarket------------------------------------------------------------------------------------------
INSERT INTO supermarkets VALUE(1,21,"Tudo em Um");
INSERT INTO supermarkets VALUE(2,22,"Lupin");
INSERT INTO supermarkets VALUE(3,23,"Moana");
INSERT INTO supermarkets VALUE(4,24,"AvSuper");


#Opening Hours------------------------------------------------------------------------------------
INSERT INTO opening_hours VALUES(1,1,1,"08:00","22:30");
INSERT INTO opening_hours VALUES(2,1,2,"08:00","22:30");
INSERT INTO opening_hours VALUES(3,1,3,"08:00","22:30");
INSERT INTO opening_hours VALUES(4,1,4,"08:00","22:30");
INSERT INTO opening_hours VALUES(5,1,5,"08:00","22:30");
INSERT INTO opening_hours VALUES(6,1,6,"09:30","20:00");
INSERT INTO opening_hours VALUES(7,1,7,"10:00","20:00");
INSERT INTO opening_hours VALUES(8,2,1,"09:00","22:30");
INSERT INTO opening_hours VALUES(9,2,2,"09:00","22:30");
INSERT INTO opening_hours VALUES(10,2,3,"09:00","22:30");
INSERT INTO opening_hours VALUES(11,2,4,"09:00","22:30");
INSERT INTO opening_hours VALUES(12,2,5,"09:00","22:30");
INSERT INTO opening_hours VALUES(13,2,6,"10:00","20:00");
INSERT INTO opening_hours VALUES(14,2,7,"10:00","20:00");
INSERT INTO opening_hours VALUES(15,3,1,"09:00","23:00");
INSERT INTO opening_hours VALUES(16,3,2,"09:00","23:00");
INSERT INTO opening_hours VALUES(17,3,3,"09:00","23:00");
INSERT INTO opening_hours VALUES(18,3,4,"09:00","23:00");
INSERT INTO opening_hours VALUES(19,3,5,"09:00","23:00");
INSERT INTO opening_hours VALUES(20,3,6,"10:00","20:00");
INSERT INTO opening_hours VALUES(21,3,7,"10:00","20:00");


#Items----------------------------------------------------------
INSERT INTO items VALUE(1,"Still Water","Tudo em Um","Water");
INSERT INTO items VALUE(2,"Still Water","Luso","Water");
INSERT INTO items VALUE(3,"Coke","Cola","Soft Drink");
INSERT INTO items VALUE(4,"Small Beer","Sagres","Beer");
INSERT INTO items VALUE(5,"Big Beer","Super Bock","Beer");
INSERT INTO items VALUE(6,"Apple Juice","Compal","Juice");
INSERT INTO items VALUE(7,"Orange Juice","Compal","Juice");
INSERT INTO items VALUE(8,"Rosé Wine","Sao Mateus","Wine");
INSERT INTO items VALUE(9,"Green Wine","Jardin Secretos","Wine");
INSERT INTO items VALUE(10,"Vodka","Smirnoff","Spirits");
INSERT INTO items VALUE(11,"Tequila","Don Julio","Spirits");


#Supermarket Items----------------------------------------------------------
INSERT INTO Supermarket_Items VALUE(1,1,1,0.30,130);
INSERT INTO Supermarket_Items VALUE(2,2,2,0.90,210);
INSERT INTO Supermarket_Items VALUE(3,2,3,0.90,151);
INSERT INTO Supermarket_Items VALUE(4,3,1,1.20,145);
INSERT INTO Supermarket_Items VALUE(5,3,2,1.60,135);
INSERT INTO Supermarket_Items VALUE(6,3,3,1.80,120);
INSERT INTO Supermarket_Items VALUE(7,4,1,1.20,135);
INSERT INTO Supermarket_Items VALUE(8,4,2,1.40,150);
INSERT INTO Supermarket_Items VALUE(9,4,3,1.40,150);
INSERT INTO Supermarket_Items VALUE(10,5,2,2.00,130);
INSERT INTO Supermarket_Items VALUE(11,5,3,2.00,120);
INSERT INTO Supermarket_Items VALUE(12,6,1,1.20,120);
INSERT INTO Supermarket_Items VALUE(13,6,2,1.30,120);
INSERT INTO Supermarket_Items VALUE(14,6,3,1.50,120);
INSERT INTO Supermarket_Items VALUE(15,7,1,1.20,130);
INSERT INTO Supermarket_Items VALUE(16,7,2,1.30,130);
INSERT INTO Supermarket_Items VALUE(17,7,3,1.50,130);
INSERT INTO Supermarket_Items VALUE(18,8,2,4.90,110);
INSERT INTO Supermarket_Items VALUE(19,8,3,5.60,115);
INSERT INTO Supermarket_Items VALUE(20,9,2,8.00,115);
INSERT INTO Supermarket_Items VALUE(21,9,3,11.00,110);
INSERT INTO Supermarket_Items VALUE(22,10,2,27.00,115);
INSERT INTO Supermarket_Items VALUE(23,10,3,32.00,110);
INSERT INTO Supermarket_Items VALUE(24,11,2,35.00,115);
INSERT INTO Supermarket_Items VALUE(26,2,4,0.85,50);
INSERT INTO Supermarket_Items VALUE(27,3,4,1.5,25);
INSERT INTO Supermarket_Items VALUE(28,7,4,1.15,60);
INSERT INTO Supermarket_Items VALUE(29,9,4,4.9,50);

#Populate the orders table
INSERT INTO Orders (
  `Supermarket_ID`,
  `User_ID`,
  `Driver_ID`,
  `Order_Date`) 
values
(1,2,1, '2020-01-29 13:26:09'),
(2,2,2, '2020-02-27 19:03:01'), 
(3,2,1, '2020-03-23 17:02:37'), 
(1,1,2, '2020-07-16 20:09:35'), 
(2,1,2, '2020-08-10 10:26:46'), 
(3,1,2, '2020-09-08 10:52:08'), 
(1,2,3, '2021-01-27 18:24:04'), 
(2,3,3, '2021-03-24 11:07:41'),
(3,4,4, '2021-04-11 13:37:31'), 
(1,5,1, '2021-04-14 12:23:09'),
(2,6,1, '2021-04-22 15:18:37'),
(3,6,5, '2021-09-20 19:15:58'),
(1,7,6, '2021-10-15 11:51:34'),
(2,8,7, '2021-10-26 13:44:29'),
(3,9,7, '2021-10-29 10:13:10'),
(1,1,7, '2021-11-24 10:00:17'),
(2,3,7, '2021-12-10 15:14:04'),
(3,10,6, '2021-12-31 13:43:29'),
(1,5,5, '2022-01-09 15:13:03'),
(2,8,5, '2022-01-16 10:28:29'),
(3,11,3, '2022-01-20 10:50:51'),
(1,12,4, '2022-02-02 15:50:24'),
(2,13,5, '2022-04-20 12:36:03'),
(3,14,1, '2022-04-21 19:42:56'),
(1,15,1, '2022-04-26 11:39:53'),
(2,2,2, '2022-07-18 13:08:03'),
(3,2,2, '2022-07-19 13:06:40'),
(1,8,3, '2022-09-18 18:29:26'),
(2,9,2, '2022-10-08 17:31:41'),
(3,2,5, '2022-10-15 14:07:53');


#Add the respective products to the orders
INSERT INTO Order_Items (`Order_ID`, `Super_Item_ID`, `Quantity`) values
(1, 1, 2),
(1, 4, 1),
(1, 7, 1),
(2, 2, 2),
(2, 5, 1),
(2, 8, 1),
(3, 3, 2),
(3, 11, 1),
(3, 17, 1),
(4, 12, 2),
(4, 15, 1),
(4, 7, 1),
(5, 10, 2),
(5, 18, 1),
(5, 13, 1),
(6, 6, 2),
(6, 19, 1),
(6, 14, 1),
(7, 15, 2),
(7, 12, 1),
(7, 4, 1),
(8, 16, 2),
(8, 8, 1),
(8, 24, 1),
(9, 3, 2),
(9, 14, 1),
(9, 21, 1),
(10, 1, 2),
(10, 15, 1),
(10, 7, 1),
(11, 2, 2),
(11, 5, 1),
(11, 22, 1),
(12, 3, 2),
(12, 9, 1),
(12, 21, 1),
(13, 4, 2),
(13, 12, 1),
(13, 7, 1),
(14, 2, 2),
(14, 13, 1),
(14, 20, 1),
(15, 17, 2),
(15, 23, 1),
(15, 11, 1),
(16, 12, 2),
(16, 15, 1),
(16, 4, 1),
(17, 20, 2),
(17, 22, 1),
(17, 8, 1),
(18, 21, 2),
(18, 19, 1),
(18, 17, 1),
(19, 7, 2),
(19, 4, 1),
(19, 15, 1),
(20, 13, 2),
(20, 22, 1),
(20, 18, 1),
(21, 11, 2),
(21, 17, 1),
(21, 23, 1),
(22, 1, 2),
(22, 15, 1),
(22, 7, 1),
(23, 22, 2),
(23, 8, 1),
(23, 5, 1),
(24, 3, 2),
(24, 6, 1),
(24, 14, 1),
(25, 1, 2),
(25, 4, 1),
(25, 15, 1),
(26, 8, 2),
(26, 13, 1),
(26, 22, 1),
(27, 9, 2),
(27, 11, 1),
(27, 17, 1),
(28, 1, 2),
(28, 7, 1),
(28, 15, 1),
(29, 5, 2),
(29, 20, 1),
(29, 24, 1),
(30, 3, 2),
(30, 6, 1),
(30, 9, 1),
(30, 11, 2),
(30, 14, 1),
(30, 17, 1),
(30, 19, 2),
(30, 21, 1),
(30, 23, 1);


#Populate Reviews
INSERT INTO reviews VALUES(1, 2, 3, "Enrega rápida, mas produto 1 errado");
INSERT INTO reviews VALUES(2, 5, 4, NULL);
INSERT INTO reviews VALUES(3, 9, 4, NULL);
INSERT INTO reviews VALUES(4, 10, 2, "Produtos errados e mal embalados");
INSERT INTO reviews VALUES(5, 12, 5, NULL);
INSERT INTO reviews VALUES(6, 16, 3, "Demorou demasiado tempo");
INSERT INTO reviews VALUES(7, 19, 4, NULL);
INSERT INTO reviews VALUES(8, 20, 5, NULL);
INSERT INTO reviews VALUES(9, 21, 3, NULL);
INSERT INTO reviews VALUES(10, 22, 2, "Produtos fora do prazo!");
INSERT INTO reviews VALUES(11, 24, 5, NULL);
INSERT INTO reviews VALUES(12, 29, 5, NULL);

###############################################################################################################
#Testing
###############################################################################################################

# Test the change in price
update supermarket_items
set item_price = 0.9
where super_item_id = 4;
select * from log;


# Add an order and check the stock, payment and promo/order table afterwards
select * from supermarket_items
where super_item_id = 4 ;#Stock = 138

INSERT INTO Orders (
  `Order_ID`,
  `Supermarket_ID`,
  `User_ID`,
  `Driver_ID`,
  `Order_Date`) 
values
(31,1,1,1, '2022-12-19 14:07:53');

INSERT INTO Order_Items (`Order_ID`, `Super_Item_ID`, `Quantity`) values
(31, 4, 15);

select * from supermarket_items
where super_item_id = 4 ;#Stock: 138-15= 123 => correct!; 

select * from orders 
where order_id = 31; #Promo was applied

Select * from payments where order_id = 31;

###############################################################################################################
#Uncomment to check if you can make an order when there is not enough stock

#INSERT INTO Orders (
 # `Order_ID`,
  #`Supermarket_ID`,
  #`User_ID`,
  #`Driver_ID`,
  #`Order_Date`) 
#values
#(32,1,1,1, '2022-12-19 14:08:53');

#INSERT INTO Order_Items (`Order_ID`, `Super_Item_ID`, `Quantity`) values
#(32, 4, 1000); #Error Message out of Stock!


###############################################################################################################
#Uncomment to check if you can make an order when the supermarket is closed

#INSERT INTO Orders (
#  `Order_ID`,
#  `Supermarket_ID`,
#  `User_ID`,
#  `Driver_ID`,
#  `Order_Date`) 
#values
#(32,1,1,1, '2022-12-19 23:08:53'); #Error Message store is closed
