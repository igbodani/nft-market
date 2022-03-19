let mysql = require('mariadb')

let pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'smile',
    database: 'rhobix'
});

let connection;

let contracts = [];

/*
  Contract methods
 */


async function createContract(contractAddress, contractName, symbol, type, owner, dateCreated, dateModified, dateDeleted ) {

    try {
        connection = await pool.getConnection();
        const row = await connection.query("call CreateContract(?,?,?,?,?,?,?,?)", [contractAddress,contractName,symbol,type, owner, dateCreated, dateModified, dateDeleted]);

        console.log(row)
    }catch (err) {

    }finally {

    }
}



async function updateContract(contractAddress, contractName, symbol, type, owner, dateCreated, dateModified, dateDeleted ) {

    try {
        connection = await pool.getConnection();
        const row = await connection.query("call UpdateContract(?,?,?,?,?,?,?,?)", [contractAddress,contractName,symbol,type, owner, dateCreated, dateModified, dateDeleted]);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();


    }
}


async function getAllContracts(){
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetAllContracts");
        contracts = row[0];
        console.log(contracts);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}

async function getContract(contractAddress){
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetContract(?)", [contractAddress]);
        contracts = row[0];
        console.log(contracts);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}



async function getCreatorContracts(creator){
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetOwnerContracts(?)", [creator]);
        contracts = row[0];
        console.log(contracts);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}

// Contract methods end

/*
    Token methods
 */

async function createToken(contractAddress,tokenUri, creator, royalties, minted, amount, soldNum, dateCreated,
                           dateModified, dateDeleted ) {


    try {
        connection = await pool.getConnection();
        const row = await connection.execute("call CreateToken(?,?,?,?,?,?,?,?,?,?)", [contractAddress, null, tokenUri, creator, royalties, minted, amount, soldNum, dateCreated,
            dateModified, dateDeleted]);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();

    }
}



async function getToken(contractAddress, tokenId){
    let token
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetToken(?,?)", [contractAddress, tokenId]);
        token = row[0];
        console.log(token);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}



async function getCreatorTokens(creator){
    let token
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetTokensForCreator(?)", [creator]);
        token = row[0];
        console.log(token);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}



async function updateToken(contractAddress, tokenId, tokenUri,  royalties, minted, amount, soldNum, dateCreated,
                           dateModified, dateDeleted ) {


    try {
        connection = await pool.getConnection();
        const row = await connection.query("call UpdateToken(?,?,?,?,?,?,?,?,?,?)", [contractAddress, tokenId, tokenUri, royalties, minted, amount, soldNum, dateCreated,
            dateModified, dateDeleted]);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();

    }
}

// End Token method



/*
  Collection methods
 */



async function createCollection(contractAddress, profile, minPrice, royalties, explicit, extra, totalNum, currentNum,
                                soldNum, dateCreated, dateModified, dateDeleted ) {


    try {
        connection = await pool.getConnection();
        const row = await connection.execute("call CreateCollections(?,?,?,?,?,?,?,?,?,?,?,?,?)", [null, contractAddress, profile, minPrice, royalties, explicit, extra, totalNum, currentNum,
            soldNum, dateCreated, dateModified, dateDeleted]);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();

    }
}



async function updateCollection(collectionId,  profile, minPrice, royalties, explicit, extra, totalNum, currentNum,
                                soldNum, dateCreated, dateModified, dateDeleted ) {


    try {
        connection = await pool.getConnection();
        const row = await connection.execute("call CreateCollections(?,?,?,?,?,?,?,?,?,?,?,?,?)", [collectionId,  profile, minPrice, royalties, explicit, extra, totalNum, currentNum,
            soldNum, dateCreated, dateModified, dateDeleted]);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();

    }
}



async function getCollection(collectionId){
    let collection
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetCollectionForId(?)", [collectionId]);
        collection = row[0];
        console.log(collection);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}



async function getContractCollections(collectionAddress){
    let collection;
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetCollectionsForContract(?)", [collectionAddress]);
        collection = row[0];
        console.log(collection);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}



async function getOwnerCollections(ownerAddress){
    let collection;
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetCollectionForOwner(?)", [ownerAddress]);
        collection = row[0];
        console.log(collection);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}

// End Collection methods



/*

 */



async function createProduct(tokenId, contractAddress,owner, price, collectionId, hide, explicit, extra, listed, stc, dateCreated,
                             dateModified, dateDeleted) {

    let product;


    try {
        connection = await pool.getConnection();
        const row = await connection.execute("call CreateProducts(?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [null,tokenId, contractAddress,owner, price, collectionId, hide, explicit, extra, listed, stc, dateCreated,
            dateModified, dateDeleted]);

        product = row[0];
        console.log(product);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();

    }
}





async function updateProduct(productID, tokenId, contractAddress,owner, price, collectionId, hide, explicit, extra, listed, stc, dateCreated,
                             dateModified, dateDeleted) {

    let product;


    try {
        connection = await pool.getConnection();
        const row = await connection.execute("call CreateProducts(?,?,?,?,?,?,?,?,?,?,?,?,?)", [productID,tokenId, contractAddress,owner, price, collectionId, hide, explicit, extra, listed, stc, dateCreated,
            dateModified, dateDeleted]);

        product = row[0];
        console.log(product);

        console.log(row)
    }catch (err) {

    }finally {
        if (connection)
            await connection.end();

    }
}



async function getProduct(productID){
    let product
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetCollectionForId(?)", [productID]);
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}


async function getListedProducts(){
    let product
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetListedProducts");
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}



async function getProductsForContract(collectionAddress){
    let product;
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetProductsForContract(?)", [collectionAddress]);
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}




async function getProductsForToken(tokenId, contractAddress){
    let product;
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetProductForToken(?, ?)", [tokenId, contractAddress]);
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}




async function getProductsForCreator(creatorAddress){
    let product;
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetProductForOwner(?)", [creatorAddress]);
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}




async function getProductsForOwner(ownerAddress){
    let product;
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call GetProductForOwner(?)", [ownerAddress]);
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}

/// End Product



async function createUser(address, profile, dateCreated, dateModified, dateDeleted){
    let user
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call CreateUsers(?,?,?,?,?) ", [address, profile, dateCreated, dateModified, dateDeleted]);
        user = row[0];
        console.log(user);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}






async function addCollectionOwner(collectionId, address){
    let product
    try{
        connection = await pool.getConnection();
        const row = await connection.query("call CreateCollectionOwners(?,?) ", [collectionId, address]);
        product = row[0];
        console.log(product);

    }catch (err) {
        throw err;
    }finally {
        if (connection)
            await connection.end();
    }

}


getAllContracts();


