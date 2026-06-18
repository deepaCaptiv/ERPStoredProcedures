  
CREATE   PROCEDURE [dbo].[Insert_POERPHeader_FromJson]  
    @JsonData NVARCHAR(MAX)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
   
   
    BEGIN TRY  
  
    -- Validate JSON  
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0  
        BEGIN  
            RAISERROR('Invalid or NULL JSON passed', 16, 1);  
            RETURN;  
        END;  
  
  --Capture Raw json data  
  --INSERT INTO POJsonfromERP  
  --VALUES('Before insert' ,@JsonData,getdate())  
  
 DECLARE @TempPOHeaderDetails TABLE  
 (  
  POERPHeaderId VARCHAR(36),         
        PO_NUMBER VARCHAR(50),  
        PO_DATE DATETIME,  
        PO_Type VARCHAR(50),  
        PO_SubType VARCHAR(100),  
        REVISION INT,  
        VENDOR_NAME VARCHAR(200),  
        VENDOR_ADDRESS NVARCHAR(MAX),  
        VENDOR_GSTIN VARCHAR(50),  
        VENDOR_CONTACT VARCHAR(200),  
        VENDOR_PHONE VARCHAR(20),  
        VENDOR_EMAIL VARCHAR(200),  
        BUYER_ORG VARCHAR(100),  
        BUYER_ADDRESS NVARCHAR(MAX),  
        BUYER_GSTIN VARCHAR(50),  
        BUYER_NAME VARCHAR(200),  
        SHIP_TO_LOCATION VARCHAR(150),  
        SHIP_TO_ADDRESS NVARCHAR(MAX),  
        BILL_TO_LOCATION VARCHAR(150),  
        PAYMENT_TERMS VARCHAR(50),  
        CURRENCY VARCHAR(10),  
        SUBTOTAL DECIMAL(18,2),  
        TOTAL_TAX DECIMAL(18,2),  
        GRAND_TOTAL DECIMAL(18,2),  
        INSTRUCTIONS NVARCHAR(MAX),  
        POUpdatedBy BIGINT,  
        POUpdatedOn DATETIME,  
        DocTypeId VARCHAR(36),  
        PO_STATUS VARCHAR(50)  
  );  
  
  INSERT INTO @TempPOHeaderDetails  
  (  
   POERPHeaderId ,            
   PO_NUMBER ,  
   PO_DATE ,  
   PO_Type ,  
   PO_SubType ,  
   REVISION ,  
   VENDOR_NAME ,  
   VENDOR_ADDRESS ,  
   VENDOR_GSTIN ,  
   VENDOR_CONTACT ,  
   VENDOR_PHONE ,  
   VENDOR_EMAIL ,  
   BUYER_ORG ,  
   BUYER_ADDRESS ,  
   BUYER_GSTIN ,  
   BUYER_NAME ,  
   SHIP_TO_LOCATION ,  
   SHIP_TO_ADDRESS ,  
   BILL_TO_LOCATION ,  
   PAYMENT_TERMS ,  
   CURRENCY ,  
   SUBTOTAL ,  
   TOTAL_TAX ,  
   GRAND_TOTAL ,  
   INSTRUCTIONS,  
   POUpdatedBy ,  
   POUpdatedOn ,  
   DocTypeId ,  
   PO_STATUS   
  )  
    SELECT   
   POERPHeaderId ,              
   PO_NUMBER ,  
   PO_DATE ,  
   PO_Type ,  
   PO_SubType ,  
   REVISION ,  
   VENDOR_NAME ,  
   VENDOR_ADDRESS ,  
   VENDOR_GSTIN ,  
   VENDOR_CONTACT ,  
   VENDOR_PHONE ,  
   VENDOR_EMAIL ,  
   BUYER_ORG ,  
   BUYER_ADDRESS ,  
   BUYER_GSTIN ,  
   BUYER_NAME ,  
   SHIP_TO_LOCATION ,  
   SHIP_TO_ADDRESS ,  
   BILL_TO_LOCATION ,  
   PAYMENT_TERMS ,  
   CURRENCY ,  
   SUBTOTAL ,  
   TOTAL_TAX ,  
   GRAND_TOTAL ,  
   INSTRUCTIONS,  
   POUpdatedBy ,  
   POUpdatedOn ,  
   DocTypeId ,  
   PO_STATUS   
            FROM OPENJSON(@JsonData)  
            WITH (  
                POERPHeaderId VARCHAR(36),               
                PO_NUMBER VARCHAR(50),  
                PO_DATE DATETIME,  
                PO_Type VARCHAR(50),  
                PO_SubType VARCHAR(100),  
                REVISION INT,  
                VENDOR_NAME VARCHAR(200),  
                VENDOR_ADDRESS NVARCHAR(MAX),  
                VENDOR_GSTIN VARCHAR(50),  
                VENDOR_CONTACT VARCHAR(200),  
                VENDOR_PHONE VARCHAR(20),  
                VENDOR_EMAIL VARCHAR(200),  
                BUYER_ORG VARCHAR(100),  
                BUYER_ADDRESS NVARCHAR(MAX),  
                BUYER_GSTIN VARCHAR(50),  
                BUYER_NAME VARCHAR(200),  
                SHIP_TO_LOCATION VARCHAR(150),  
                SHIP_TO_ADDRESS NVARCHAR(MAX),  
                BILL_TO_LOCATION VARCHAR(150),  
                PAYMENT_TERMS VARCHAR(50),  
                CURRENCY VARCHAR(10),  
                SUBTOTAL DECIMAL(18,2),  
                TOTAL_TAX DECIMAL(18,2),  
                GRAND_TOTAL DECIMAL(18,2),  
                INSTRUCTIONS NVARCHAR(MAX),  
                POUpdatedBy BIGINT,  
                POUpdatedOn DATETIME,  
                DocTypeId VARCHAR(36),  
                PO_STATUS VARCHAR(50)  
    );  
  
     DECLARE @POERPHeaderId VARCHAR(36)  
  
  SELECT TOP 1 @POERPHeaderId=POERPHeaderId   
  FROM @TempPOHeaderDetails  
  
 IF EXISTS (SELECT 1 FROM Vertiv..POERPHeader TAR WITH(NOLOCK) WHERE POERPHeaderId=@POERPHeaderId)  
 BEGIN  
     
   INSERT INTO POERPHeaderHistory  
   (  
   POERPHeaderHistoryId,RecordedOn,POERPHeaderId,DocId,PO_NUMBER,PO_DATE,PO_Type,PO_SubType,REVISION,  
   VENDOR_NAME,VENDOR_ADDRESS,VENDOR_GSTIN,VENDOR_CONTACT,VENDOR_PHONE,VENDOR_EMAIL,BUYER_ORG,BUYER_ADDRESS,  
   BUYER_GSTIN,BUYER_NAME,SHIP_TO_LOCATION,SHIP_TO_ADDRESS,BILL_TO_LOCATION,PAYMENT_TERMS,CURRENCY,SUBTOTAL,  
   TOTAL_TAX,GRAND_TOTAL,INSTRUCTIONS,POUpdatedBy,POUpdatedOn,DocTypeId,PO_STATUS  
   )  
   SELECT NEWID(),GETDATE(),POERPHeaderId,DocId,PO_NUMBER,PO_DATE,PO_Type,PO_SubType,REVISION,  
    VENDOR_NAME,VENDOR_ADDRESS,VENDOR_GSTIN,VENDOR_CONTACT,VENDOR_PHONE,VENDOR_EMAIL,BUYER_ORG,BUYER_ADDRESS,  
    BUYER_GSTIN,BUYER_NAME,SHIP_TO_LOCATION,SHIP_TO_ADDRESS,BILL_TO_LOCATION,PAYMENT_TERMS,CURRENCY,SUBTOTAL,  
    TOTAL_TAX,GRAND_TOTAL,INSTRUCTIONS,POUpdatedBy,POUpdatedOn,DocTypeId,PO_STATUS   
   FROM Vertiv..POERPHeader TAR WITH(NOLOCK)   
   WHERE POERPHeaderId=@POERPHeaderId  
  
   --Update Existing data  
   UPDATE TAR  
   SET                
                PO_NUMBER = SRC.PO_NUMBER,  
                PO_DATE = SRC.PO_DATE,  
                PO_Type = SRC.PO_Type,  
                PO_SubType = SRC.PO_SubType,  
                REVISION = SRC.REVISION,  
                VENDOR_NAME = SRC.VENDOR_NAME,  
                VENDOR_ADDRESS = SRC.VENDOR_ADDRESS,  
                VENDOR_GSTIN = SRC.VENDOR_GSTIN,  
                VENDOR_CONTACT = SRC.VENDOR_CONTACT,  
                VENDOR_PHONE = SRC.VENDOR_PHONE,  
                VENDOR_EMAIL = SRC.VENDOR_EMAIL,  
                BUYER_ORG = SRC.BUYER_ORG,  
                BUYER_ADDRESS = SRC.BUYER_ADDRESS,  
                BUYER_GSTIN = SRC.BUYER_GSTIN,  
                BUYER_NAME = SRC.BUYER_NAME,  
                SHIP_TO_LOCATION = SRC.SHIP_TO_LOCATION,  
                SHIP_TO_ADDRESS = SRC.SHIP_TO_ADDRESS,  
                BILL_TO_LOCATION = SRC.BILL_TO_LOCATION,  
                PAYMENT_TERMS = SRC.PAYMENT_TERMS,  
                CURRENCY = SRC.CURRENCY,  
                SUBTOTAL = SRC.SUBTOTAL,  
                TOTAL_TAX = SRC.TOTAL_TAX,  
                GRAND_TOTAL = SRC.GRAND_TOTAL,  
                INSTRUCTIONS = SRC.INSTRUCTIONS,  
                POUpdatedBy = SRC.POUpdatedBy,  
                POUpdatedOn = ISNULL(SRC.POUpdatedOn, GETDATE()),  
                DocTypeId = SRC.DocTypeId,  
                PO_STATUS = SRC.PO_STATUS  
  FROM Vertiv..POERPHeader TAR  
  JOIN @TempPOHeaderDetails SRC  
  ON  TAR.POERPHeaderId=SRC.POERPHeaderId  
  
 END  
  --Insert new PO  
  INSERT INTO Vertiv..POERPHeader  
  (  
   POERPHeaderId ,              
   PO_NUMBER ,  
   PO_DATE ,  
   PO_Type ,  
   PO_SubType ,  
   REVISION ,  
   VENDOR_NAME ,  
   VENDOR_ADDRESS ,  
   VENDOR_GSTIN ,  
   VENDOR_CONTACT ,  
   VENDOR_PHONE ,  
   VENDOR_EMAIL ,  
   BUYER_ORG ,  
   BUYER_ADDRESS ,  
   BUYER_GSTIN ,  
   BUYER_NAME ,  
   SHIP_TO_LOCATION ,  
   SHIP_TO_ADDRESS ,  
   BILL_TO_LOCATION ,  
   PAYMENT_TERMS ,  
   CURRENCY ,  
   SUBTOTAL ,  
   TOTAL_TAX ,  
   GRAND_TOTAL ,  
   INSTRUCTIONS,  
   POUpdatedBy ,  
   POUpdatedOn ,  
   DocTypeId ,  
   PO_STATUS   
  )  
  SELECT TPO.POERPHeaderId ,              
    TPO.PO_NUMBER ,  
    TPO.PO_DATE ,  
    TPO.PO_Type ,  
    TPO.PO_SubType ,  
    TPO.REVISION ,  
    TPO.VENDOR_NAME ,  
    TPO.VENDOR_ADDRESS ,  
    TPO.VENDOR_GSTIN ,  
    TPO.VENDOR_CONTACT ,  
    TPO.VENDOR_PHONE ,  
    TPO.VENDOR_EMAIL ,  
    TPO.BUYER_ORG ,  
    TPO.BUYER_ADDRESS ,  
    TPO.BUYER_GSTIN ,  
    TPO.BUYER_NAME ,  
    TPO.SHIP_TO_LOCATION ,  
    TPO.SHIP_TO_ADDRESS ,  
    TPO.BILL_TO_LOCATION ,  
    TPO.PAYMENT_TERMS ,  
    TPO.CURRENCY ,  
    TPO.SUBTOTAL ,  
    TPO.TOTAL_TAX ,  
    TPO.GRAND_TOTAL ,  
    TPO.INSTRUCTIONS,  
    TPO.POUpdatedBy ,  
    TPO.POUpdatedOn ,  
    TPO.DocTypeId ,  
    TPO.PO_STATUS   
  FROM @TempPOHeaderDetails TPO  
  LEFT JOIN Vertiv..POERPHeader PO WITH(NOLOCK)  
  ON  TPO.POERPHeaderId=PO.POERPHeaderId  
  WHERE PO.POERPHeaderId IS NULL  
  
        -- Return result  
    
        SELECT  POERPHeaderId ,  
    PO_NUMBER ,  
    POUpdatedOn   
  FROM @TempPOHeaderDetails;  
  
    
  --INSERT INTO POJsonfromERP  
  --SELECT PO_NUMBER  ,@JsonData,getdate()  
  --FROM @TempPOHeaderDetails  
  
    END TRY  
    BEGIN CATCH  
        SELECT    
  
     
            'ERROR' AS Status,  
            ERROR_MESSAGE() AS ErrorMessage,  
            ERROR_LINE() AS ErrorLine;  
    END CATCH  
END;  