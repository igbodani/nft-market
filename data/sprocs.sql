use rhobix;

DROP PROCEDURE IF EXISTS CreateContract;
DROP PROCEDURE IF EXISTS GetContract;
DROP PROCEDURE IF EXISTS CreateTokens;
DROP PROCEDURE IF EXISTS CreateCollections;
DROP PROCEDURE IF EXISTS CreateProducts;
DROP PROCEDURE IF EXISTS CreateUsers;
DROP PROCEDURE IF EXISTS CreateCollectionOwners;
DROP PROCEDURE IF EXISTS CreateComments;
DROP PROCEDURE IF EXISTS CreateRequests;
DROP PROCEDURE IF EXISTS CreateLikes;

DROP PROCEDURE IF EXISTS GetContract;
DROP PROCEDURE IF EXISTS GetAllContracts;
DROP PROCEDURE IF EXISTS GetOwnerContracts;

DROP PROCEDURE IF EXISTS GetTokensForCreator;
DROP PROCEDURE IF EXISTS GetToken;
DROP PROCEDURE IF EXISTS getTokenId;


DROP PROCEDURE IF EXISTS GetCollectionsForContract;
DROP PROCEDURE IF EXISTS GetCollectionForId;
DROP PROCEDURE IF EXISTS GetCollectionForOwner;


DROP PROCEDURE IF EXISTS GetAllProducts;
DROP PROCEDURE IF EXISTS GetListedProducts;
DROP PROCEDURE IF EXISTS GetProductForId;
DROP PROCEDURE IF EXISTS GetProductForOwner;
DROP PROCEDURE IF EXISTS GetProductForCreator;
DROP PROCEDURE IF EXISTS GetProductsForContract;
DROP PROCEDURE IF EXISTS GetProductsForCollection;
DROP PROCEDURE IF EXISTS GetProductForToken;



DROP PROCEDURE IF EXISTS UpdateCollection;
DROP PROCEDURE IF EXISTS UpdateContract;
DROP PROCEDURE IF EXISTS UpdateProduct;
DROP PROCEDURE IF EXISTS UpdateToken;






DELIMITER //

CREATE PROCEDURE CreateContract(IN _address varchar(100), IN _name varchar(50), IN _symbol varchar(20),
                                IN _type varchar(8), IN _owner varchar(75))
BEGIN
    INSERT INTO contracts (address, name, symbol, type, owner)
    VALUES (_address, _name, _symbol,_type, _owner);

END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE GetAllContracts()
BEGIN
    SELECT *  FROM contracts;


END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetContract(IN _address varchar(100))
BEGIN
    SELECT *  FROM contracts

    WHERE contracts.address = _address;

END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetOwnerContracts(IN _owner varchar(100))
BEGIN
    SELECT *  FROM contracts

    WHERE contracts.owner = _owner;

END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE UpdateContract(IN _address varchar(100), IN _owner varchar(100))
BEGIN

    UPDATE contracts
        SET
            owner =_owner

    WHERE address = _address;

END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE CreateToken(IN _address varchar(100), INOUT _Id int(11), IN _tokenUri varchar(100), IN _creator varchar(100),
 IN _royalties int(5), IN _minted boolean, IN _amount int(11),IN _soldNum int(11) )
BEGIN

    CALL getTokenId(_address, @id1);
    SET _Id = @id1;


    INSERT INTO tokens (contractAddress, tokenId, tokenUri, creator, royalties, minted, amount, soldNum)
    VALUES (_address, _id, _tokenUri,  _creator, _royalties, _minted, _amount, _soldNum);

END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetToken(IN _id INT(11), IN _address varchar(100))
BEGIN
    SELECT *  FROM tokens

    WHERE tokens.tokenId = _id && tokens.contractAddress = _address;

END //

DELIMITER ;



DELIMITER //

CREATE PROCEDURE GetTokensForCreator(IN _creator varchar(100))
BEGIN
    SELECT *  FROM tokens

    WHERE tokens.creator = _creator;

END //

DELIMITER ;




DELIMITER //
CREATE PROCEDURE UpdateToken( IN _address varchar(100), INOUT _Id int(11), IN _tokenUri varchar(100),
                              IN _royalties int(5), IN _minted boolean, IN _amount int(11),IN _soldNum int(11))

BEGIN
    UPDATE Tokens
    SET
        tokenUri = _tokenUri,
        royalties = _royalties,
        minted = _minted,
        amount =_amount,
        soldNum = _soldNum

    WHERE
             tokenId = _id && contractAddress = _address;

END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE CreateCollections(OUT _id int(11), IN _address varchar(100),
                                   IN _profile varchar(50), IN _minPrice decimal(13, 2),
                                   IN _royalties int(5), IN _explicit boolean,
                                   IN _extra boolean, IN _totalNum int(11),
                                  IN _currentNum int(11),
                                   IN _soldNum int(11), IN _dateCreated datetime,
                                   IN _dateModified datetime, IN _dateDeleted datetime)
BEGIN


    INSERT INTO collections (contractAddress, profile, minPrice, royalties, explicit, extra, totalNum, currentNum,
                             soldNum, dateCreated, dateModified, dateDeleted)
    VALUES (_address, _profile, _minPrice, _royalties, _explicit, _extra, _totalNum, _currentNum, _soldNum,
            _dateCreated, _dateModified, _dateDeleted);


    SET _id = LAST_INSERT_ID();


END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE GetCollectionForId(IN _id INT(11))
BEGIN
    SELECT *  FROM collections

    WHERE id = _id;

END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetCollectionsForContract(IN _address varchar(100))
BEGIN
    SELECT *  FROM collections

    WHERE contractAddress = _address;

END //

DELIMITER ;






DELIMITER //
CREATE PROCEDURE UpdateCollection(IN _id int(11),
                                  IN _profile varchar(50), IN _minPrice decimal(13, 2),
                                  IN _royalties int(5), IN _explicit boolean,
                                  IN _extra boolean, IN _totalNum int(11),
                                  IN _currentNum int(11),
                                  IN _soldNum int(11), IN _dateCreated datetime,
                                  IN _dateModified datetime, IN _dateDeleted datetime )

BEGIN
    UPDATE collections
    SET

        profile = _profile,
        minPrice = _minPrice,
        royalties = _royalties,
        explicit = _explicit,
        extra = _extra,
        totalNum = _totalNum,
        currentNum = _currentNum,
        soldNum = _soldNum,
        dateCreated = _dateCreated,
        dateModified = _dateModified,
        dateDeleted = _dateDeleted

    WHERE
            id = _id;

END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE GetCollectionForOwner(IN _owner varchar(100),IN _id INT(11))
BEGIN
    SELECT  collections.*  FROM collections, collectionowners

    WHERE collectionowners.address = _owner;

END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE CreateProducts(OUT _id int(11), IN _tokenId int(11), IN _address varchar(100), IN _owner varchar(100),
                                IN _price decimal(13, 2), IN _collectionId int(11),
                                IN _hide boolean, IN _explicit boolean,
                                IN _extra boolean, IN _listed boolean,
                                 IN _stc boolean, IN _dateCreated datetime,
                                IN _dateModified datetime, IN _dateDeleted datetime)
BEGIN


    INSERT INTO products (tokenId, contractAddress,owner, price, collectionId, hide, explicit, extra, listed, stc, dateCreated,
                          dateModified, dateDeleted)
    VALUES (_tokenId, _address,_owner, _price, _collectionId, _hide, _explicit, _extra, _listed, _stc, _dateCreated, _dateModified,
            _dateDeleted);


    SET _id = LAST_INSERT_ID();


END //

DELIMITER ;





DELIMITER //
CREATE PROCEDURE UpdateProduct(IN _id int(11),  IN _tokenId int(11), IN _owner varchar(100),
                             IN _price decimal(13, 2), IN _collectionId int(11),
                             IN _hide boolean, IN _explicit boolean,
                             IN _extra boolean, IN _listed boolean,
                             IN _stc boolean, IN _dateCreated datetime,
                             IN _dateModified datetime, IN _dateDeleted datetime )

BEGIN
    UPDATE products
    SET
        tokenId = _tokenId,
        owner = _owner,
        price = _price,
        collectionId = _collectionId,
        hide = _hide,
        explicit = _explicit,
        extra = _extra,
        listed = _listed,
        stc = _stc,
        dateCreated = _dateCreated,
        dateModified = _dateModified,
        dateDeleted = _dateDeleted

    WHERE
                id = _id;

END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE GetAllProducts()
BEGIN
    SELECT *  FROM products;
END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE GetListedProducts()
BEGIN
    SELECT *  FROM products
    WHERE  products.listed = true;
END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE GetProductForId(IN _id INT(11))
BEGIN
    SELECT *  FROM products

    WHERE products.id = _id;

END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE GetProductForToken(IN _id INT(11), IN _address varchar(100))
BEGIN
    SELECT *  FROM products

    WHERE products.tokenId = _id && products.contractAddress = _address;

END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE GetProductForCreator(IN _creator varchar(100))
BEGIN
    SELECT  products.*  FROM products, tokens

    WHERE creator = _creator;

END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE GetProductForOwner(IN _owner varchar(100))
BEGIN
    SELECT  *  FROM products

    WHERE owner = _owner;

END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE GetProductsForContract(IN _address varchar(100))
BEGIN
    SELECT *  FROM products

    WHERE products.contractAddress = _address;

END //

DELIMITER ;





DELIMITER //

CREATE PROCEDURE GetProductsForCollection(IN _id int(11))
BEGIN
    SELECT *  FROM products

    WHERE collectionId = _id;

END //

DELIMITER ;






DELIMITER //

CREATE PROCEDURE CreateUsers(IN _address varchar(100),
                             IN _profile varchar(50),
                             IN _dateCreated datetime,
                             IN _dateModified datetime, IN _dateDeleted datetime)
BEGIN


    INSERT INTO users (address, profile, dateCreated, dateModified, dateDeleted)
    VALUES (_address, _profile, _dateCreated, _dateModified, _dateDeleted);

END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE CreateCollectionOwners(IN _collectionId int(11), IN _address varchar(100))

BEGIN


    INSERT INTO collectionowners (collectionId, address)
    VALUES (_collectionId, _address);

END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE CreateComments(OUT _id int(11), IN _address varchar(100),
                                IN _collectionId int(11),
                                IN _comment varchar(300),
                                IN _dateCreated datetime,
                                IN _dateModified datetime, IN _dateDeleted datetime)
BEGIN


    INSERT INTO comments (address, productId, comment, dateCreated, dateModified, dateDeleted)
    VALUES (_address, _collectionId, _comment, _dateCreated, _dateModified, _dateDeleted);


    SET _id = LAST_INSERT_ID();


END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE CreateRequests(OUT _id int(11), IN _address varchar(100),
                                IN _collectionId int(11),
                                IN _request varchar(300),
                                IN _dateCreated datetime,
                                IN _dateModified datetime, IN _dateDeleted datetime)
BEGIN


    INSERT INTO requests (address, collectionId, request, dateCreated, dateModified, dateDeleted)
    VALUES (_address, _collectionId, _request, _dateCreated, _dateModified, _dateDeleted);


    SET _id = LAST_INSERT_ID();


END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE CreateLikes(OUT _id int(11), IN _address varchar(100),
                             IN _productId int(11)
)
BEGIN


    INSERT INTO likes (address, productId)
    VALUES (_address, _productId);


    SET _id = LAST_INSERT_ID();


END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE getTokenId(IN _address varchar(100), INOUT _Id int(11))

BEGIN


    DECLARE id int DEFAULT 1;


    IF EXISTS(SELECT MAX(tokenId)
              FROM tokens
              WHERE contractAddress = _address) THEN

        SELECT MAX(tokenId)
        FROM tokens
        WHERE contractAddress = _address
        INTO id;

        IF id > 1 THEN
            set _id = id + 1;
        END IF;

    END IF;

END //
DELIMITER ;




