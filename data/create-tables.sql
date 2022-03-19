
drop database Rhobix;


create database Rhobix;

use Rhobix;

create table `Contracts`
(
    `address` VARCHAR(100) NOT NULL,
    `name`    varchar(50)  NOT NULL,
    `symbol`  varchar(20)  NOT NULL,
    `type`    varchar(8)   NOT NULL,
    `owner`   varchar(75)  NOT NULL,
    PRIMARY KEY (address)

);

create table `Tokens`
(
    `contractAddress` VARCHAR(100) NOT NULL,
    `tokenId`         int(11)      NOT NULL,
    `tokenUri`        varchar(100) NOT NULL,
    `creator`         varchar(100) NOT NULL,
    `royalties`       int(5)       NOT NULL,
    `minted`          boolean      NOT NULL DEFAULT 0,
    `amount`          int(11)      NOT NULL,
    `soldNum`         int(11)      NOT NULL,
    FOREIGN KEY (contractAddress) REFERENCES Contracts (address),
    PRIMARY KEY (contractAddress, tokenId)


);



create table `Collections`
(
    `id`              int(11)      NOT NULL AUTO_INCREMENT,
    `contractAddress` varchar(100) NOT NULL,
    `profile`         varchar(50)  not null,
    `minPrice`        int(5)       NOT NULL,
    `royalties`       int(5)       NOT NULL,
    `explicit`        boolean      NOT NULL DEFAULT 0,
    `extra`           boolean      NOT NULL DEFAULT 0,
    `totalNum`        int(11)      NOT NULL,
    `currentNum`      int(11)      NOT NULL,
    `soldNum`         int(11)      NOT NULL,
    `dateCreated`     datetime     NOT NULL,
    `dateModified`    datetime     NOT NULL,
    `dateDeleted`     datetime     NOT NULL,
    FOREIGN KEY (contractAddress) REFERENCES Contracts (address),
    PRIMARY KEY (id)
);


create table `Products`
(
    `id`              int(11)        NOT NULL AUTO_INCREMENT,
    `tokenId`         int(11)        NULL,
    `contractAddress` varchar(100)   NOT NULL,
    `owner`            varchar(100) NOT NULL,
    `price`           decimal(13, 2) NOT NULL,
    `collectionId`    int(11)        NOT NULL,
    `hide`            boolean        NOT NULL DEFAULT 0,
    `explicit`        boolean        NOT NULL DEFAULT 0,
    `extra`           boolean        NOT NULL DEFAULT 0,
    `listed`          boolean        NOT NULL DEFAULT 0,
    `stc`             boolean        NOT NULL DEFAULT 0,
    `dateCreated`     datetime       NOT NULL,
    `dateModified`    datetime       NOT NULL,
    `dateDeleted`     datetime       NOT NULL,
    FOREIGN KEY (contractAddress, tokenId) REFERENCES Tokens (contractAddress, tokenId),
    FOREIGN KEY (collectionId) REFERENCES Collections (id),
    PRIMARY KEY (id)

);


create table `Users`
(
    `address`      VARCHAR(100) NOT NULL,
    `profile`      varchar(100) DEFAULT '',
    `dateCreated`  DATETIME     NOT NULL,
    `dateModified` DATETIME     NOT NULL,
    `dateDeleted`  datetime     NOT NULL,
    PRIMARY KEY (address)

);

create table `CollectionOwners`
(
    `collectionId` int(11)      NOT NULL,
    `address`      varchar(100) NOT NULL,
    FOREIGN KEY (collectionId) REFERENCES Collections (id),
    PRIMARY KEY (collectionId, address)
);

create table `Comments`
(
    `id`           int(11)      NOT NULL AUTO_INCREMENT,
    `address`      varchar(100) NOT NULL,
    `productId`    int(11)      NOT NULL,
    `comment`      varchar(300) NOT NULL,
    `dateCreated`  DATETIME     NOT NULL,
    `dateModified` DATETIME     NOT NULL,
    `dateDeleted`  datetime     NOT NULL,
    PRIMARY KEY (id)

);



create table `Requests`
(
    `id`           int(11)      NOT NULL AUTO_INCREMENT,
    `address`      varchar(100) NOT NULL,
    `collectionId` int(11)      NOT NULL,
    `request`      varchar(300) NOT NULL,
    `dateCreated`  DATETIME     NOT NULL,
    `dateModified` DATETIME     NOT NULL,
    `dateDeleted`  datetime     NOT NULL,
    FOREIGN KEY (address) REFERENCES Users (address),
    PRIMARY KEY (id)

);

create table `Likes`
(
    `id`        int(11)      NOT NULL AUTO_INCREMENT,
    `address`   varchar(100) NOT NULL,
    `productId` int(11)      NOT NULL,
    PRIMARY KEY (id)

)