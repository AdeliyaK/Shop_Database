CREATE TABLE Product_name (
	ID int auto_increment,
    name varchar(20),
    Product_type varchar(20),
    Primary key(ID),
    Unique(name)
);

CREATE TABLE Product (
	ID int AUTO_INCREMENT,
    Size enum ('small','middle','big'),
    Type_of_the_product enum ('seeds','bulbs','stalk', 'flower in a pot'),
    Regular_nomenclature enum ('Yes', 'No'),
    Price_with_profit decimal(5,2),
    Price_without_profit decimal(5,2),
    ID_name int,
    Primary key(ID),
    Foreign key(ID_name) references Product_name(ID)
);


CREATE TABLE Colour_product (
ID_Product int not NULL,
col varchar(20),
Primary key(ID_Product,col),
Foreign key(ID_Product) references Product(ID)
);

create table Shop(
	ID int auto_increment,
	Name varchar(30) not NULL,
	Address varchar(30) not NULL,
    Primary key(ID),
    Unique(Name)
);

create table is_in_stock(
	ID_product int,
    ID_shop int,
All_number int,
    Primary key(ID_product,ID_shop),
    Foreign key(ID_product) references Product(ID),
    Foreign key(ID_shop) references Shop(ID)
);

create table Employee(
	ID int auto_increment,
    Firstname varchar(20) not NULL,
    Surname varchar(20) not null,
    Familyname varchar(20) not null,
    Address varchar(30), 
    Salary Decimal(7,2) not null,
    ID_shop int,
    check(300<Salary),
    Primary key(ID),
    unique(Firstname),
    foreign key(ID_shop) references Shop(ID)
);

create table one_order(
	Number_of_the_order int auto_increment, 
    order_date date,
Type_of_sale enum('single units', 'bouquets', 'large batches'),
    Firstname varchar(20) not null,
	Familyname varchar(20) not null,
    Phone_number char(10),
    Delivery_address varchar(30),
    ID_Employed int, 
    Primary key(Number_of_the_order),
    Foreign key(ID_Employed) references Employee(ID)
);

create table order_contains_product (
	Order_Number_of_the_order int,
    ID_product_ int, 
    number_of_products int,
    primary key(Order_Number_of_the_order,ID_product_),
    foreign key(Order_Number_of_the_order) references one_order(Number_of_the_order),
    foreign key(ID_product_) references Product(ID)
);

create trigger fix_at_new_value
after Insert on order_contains_product
for each row 
	update is_in_stock
    Set All_number = All_number -new.number_of_products
    where new.ID_product_=ID_product and ID_shop=(Select ID_shop
						  from Employee
						  where ID=(Select ID_Employed
							    from one_order
							    where Number_of_the_order =new.Order_Number_of_the_order));


DELIMITER //
create trigger fix_rewrite_value
after update on order_contains_product
for each row 
begin
    UPDATE is_in_stock
    SET All_number = All_number - NEW.number_of_products
    WHERE ID_product = NEW.ID_product_ AND ID_shop = (
        SELECT ID_shop
        FROM Employee
        WHERE ID = (
            SELECT ID_Employeda
            FROM one_order
            WHERE Number_of_the_order = NEW.Order_Number_of_the_order
        )
    );
    
    UPDATE is_in_stock
    SET All_number = All_number + OLD.number_of_products
    WHERE ID_product=old.ID_product_ AND ID_shop = (
        SELECT ID_shop
        FROM Employee
        WHERE ID = (
            SELECT ID_Employed
            FROM one_order
            WHERE Number_of_the_order = OLD.Order_Number_of_the_order
        )
    );
end;
//
DELIMITER ;

create trigger fix_delete_value
after delete on order_contains_product
for each row 
    UPDATE is_in_stock
    SET All_number = All_number + OLD.number_of_products
    WHERE ID_product=old.ID_product_ AND ID_shop = (
        SELECT ID_shop
        FROM Employee
        WHERE ID = (
            SELECT ID_Employed
            FROM one_order
            WHERE Number_of_the_order = OLD.Order_Number_of_the_order
        )
    );
