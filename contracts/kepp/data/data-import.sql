use rhobix;


call CreateToken('0x000000000000000000000000000000000000', @id1,'no uri',
                 '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9',1000,false, 10,-1 ,CURDATE(),
                 CURDATE(),CURDATE());

call GetAllTokens();
call GetAllProducts();





call CreateContract('0x001d3f1ef827552ae1114027bd3ecf1f086ba0f9',
    'Test',1, 'TT', 'ERC721', '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9',CURDATE(),CURDATE(),CURDATE());


call CreateContract('0x000000000000000000000000000000000000',
                    'Test', 2,'TT', 'ERC1155', '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9'
                        ,CURDATE(),CURDATE(),CURDATE());




call CreateToken('0x001d3f1ef827552ae1114027bd3ecf1f086ba0f9', @s,'https://www.mytokenlocation.com',
    '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9',1000,false, 1,-1 ,CURDATE(),
    CURDATE(),CURDATE());



call CreateToken('0x001d3f1ef827552ae1114027bd3ecf1f086ba0f9', @id,'https://www.mytokenlocation.com',
                 '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9',1000,false, 1,-1 ,CURDATE(),
                 CURDATE(),CURDATE());


call CreateToken('0x000000000000000000000000000000000000', @id1,'no uri',
                 '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9',1000,false, 10,-1 ,CURDATE(),
                 CURDATE(),CURDATE());

call GetAllTokens();


call CreateCollections(@i,  '0x001d3f1ef827552ae1114027bd3ecf1f086ba0f9', 'prof',100,1,false
    ,false,false,100,false,CURDATE(),
                       CURDATE(),CURDATE());

call CreateProducts(@i, 1, '0x001d3f1ef827552ae1114027bd3ecf1f086ba0f9', '0X001D3F1EF827552AE1114027BD3ECF1F086BA0F9',100,1,false
    ,false,false,false,false,CURDATE(),
                    CURDATE(),CURDATE());