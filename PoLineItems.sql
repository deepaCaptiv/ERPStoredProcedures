CREATE   PROCEDURE [dbo].[Insert_POERPLineItems_FromJson]    
    @JsonData NVARCHAR(MAX)    
AS    
BEGIN    
    SET NOCOUNT ON;    
    
    
  --insert into POJsonfromERP    
  --values('Before insert lineitem',@JsonData,getdate())   
        
  
   DECLARE @TempLineItems TABLE  
   (  
   POERPLineItemId VARCHAR(36),    
            LINE_NUM INT,    
            ITEM_CODE VARCHAR(100),    
            ITEM_DESC NVARCHAR(MAX),    
            HSN_SAC VARCHAR(10),    
            QTY DECIMAL(18,2),    
            UOM VARCHAR(10),    
            UNIT_PRICE DECIMAL(18,2),    
            LINE_AMOUNT DECIMAL(18,2),    
            DELIVERY_DATE DATETIME,    
            POLNUpdtedBy BIGINT,    
            POLnUpdatedOn DATETIME,    
            POERPHeaderId VARCHAR(36),    
            DESTINATION_TYPE_CODE VARCHAR(25),    
            GST_REVERSE_CHARGE_FLAG VARCHAR(10),    
            CATEGORY_SEGMENT1 VARCHAR(40),    
            DROP_SHIP_FLAG VARCHAR(10),    
            SHIP_TO_ORGANIZATION_ID INT,    
            REGIME_CODE VARCHAR(40),    
            RELATED_PARTY_FLAG BIT,    
            SEZ_FLAG BIT,    
            SHIP_TO_COUNTRY VARCHAR(100),    
            STOCK_TRANSFER_FLAG BIT,    
            HIGH_SEA_SALES_FLAG BIT    
  )  
  INSERT INTO @TempLineItems  
  (  
   POERPLineItemId,    
            LINE_NUM,    
            ITEM_CODE,    
            ITEM_DESC,    
            HSN_SAC,    
            QTY,    
            UOM,    
            UNIT_PRICE,    
            LINE_AMOUNT,    
            DELIVERY_DATE,    
            POLNUpdtedBy,    
            POLnUpdatedOn,    
            POERPHeaderId,    
            DESTINATION_TYPE_CODE,    
            GST_REVERSE_CHARGE_FLAG,    
            CATEGORY_SEGMENT1,    
            DROP_SHIP_FLAG,    
            SHIP_TO_ORGANIZATION_ID,    
            REGIME_CODE,    
            RELATED_PARTY_FLAG,    
            SEZ_FLAG,    
            SHIP_TO_COUNTRY,    
            STOCK_TRANSFER_FLAG,    
            HIGH_SEA_SALES_FLAG    
  )  
     
        SELECT  POERPLineItemId,    
            LINE_NUM,    
            ITEM_CODE,    
            ITEM_DESC,    
            HSN_SAC,    
            QTY,    
            UOM,    
            UNIT_PRICE,    
            LINE_AMOUNT,    
            DELIVERY_DATE,    
            POLNUpdtedBy,    
            POLnUpdatedOn,    
            POERPHeaderId,    
            DESTINATION_TYPE_CODE,    
            GST_REVERSE_CHARGE_FLAG,    
            CATEGORY_SEGMENT1,    
            DROP_SHIP_FLAG,    
            SHIP_TO_ORGANIZATION_ID,    
            REGIME_CODE,    
            RELATED_PARTY_FLAG,    
            SEZ_FLAG,    
            SHIP_TO_COUNTRY,    
            STOCK_TRANSFER_FLAG,    
            HIGH_SEA_SALES_FLAG    
        FROM OPENJSON(@JsonData)    
        WITH (    
            POERPLineItemId VARCHAR(36),    
            LINE_NUM INT,    
            ITEM_CODE VARCHAR(100),    
            ITEM_DESC NVARCHAR(MAX),    
            HSN_SAC VARCHAR(10),    
            QTY DECIMAL(18,2),    
            UOM VARCHAR(10),    
            UNIT_PRICE DECIMAL(18,2),    
            LINE_AMOUNT DECIMAL(18,2),    
            DELIVERY_DATE DATETIME,    
            POLNUpdtedBy BIGINT,    
            POLnUpdatedOn DATETIME,    
            POERPHeaderId VARCHAR(36),    
            DESTINATION_TYPE_CODE VARCHAR(25),    
            GST_REVERSE_CHARGE_FLAG VARCHAR(10),    
            CATEGORY_SEGMENT1 VARCHAR(40),    
            DROP_SHIP_FLAG VARCHAR(10),    
            SHIP_TO_ORGANIZATION_ID INT,    
            REGIME_CODE VARCHAR(40),    
            RELATED_PARTY_FLAG BIT,    
            SEZ_FLAG BIT,    
            SHIP_TO_COUNTRY VARCHAR(100),    
            STOCK_TRANSFER_FLAG BIT,    
            HIGH_SEA_SALES_FLAG BIT    
        );  
  
  DECLARE @HeaderId VARCHAR(50)   SELECT top 1 @HeaderId=POERPHeaderId   FROM @TempLineItems       IF EXISTS(SELECT  1 FROM Vertiv..POERPLineItems  WITH(NOLOCK)    WHERE POERPHEADERiD=@HeaderId )   BEGIN  
  
  INSERT INTO POERPLineItemsHistory   SELECT NEWID(),GETDATE(),*   FROM Vertiv..POERPLineItems  WITH(NOLOCK)   WHERE POERPHEADERiD=@HeaderId  
  
  --Update Existing LIne Items  
   UPDATE TAR  
   SET    
            LINE_NUM = SRC.LINE_NUM,    
            ITEM_CODE = SRC.ITEM_CODE,    
            ITEM_DESC = SRC.ITEM_DESC,    
            HSN_SAC = SRC.HSN_SAC,    
            QTY = SRC.QTY,    
            UOM = SRC.UOM,    
            UNIT_PRICE = SRC.UNIT_PRICE,    
            LINE_AMOUNT = SRC.LINE_AMOUNT,    
            DELIVERY_DATE = SRC.DELIVERY_DATE,    
            POLNUpdtedBy = SRC.POLNUpdtedBy,    
            POLnUpdatedOn = SRC.POLnUpdatedOn,    
            POERPHeaderId = SRC.POERPHeaderId,    
            DESTINATION_TYPE_CODE = SRC.DESTINATION_TYPE_CODE,    
            GST_REVERSE_CHARGE_FLAG = SRC.GST_REVERSE_CHARGE_FLAG,    
            CATEGORY_SEGMENT1 = SRC.CATEGORY_SEGMENT1,    
            DROP_SHIP_FLAG = SRC.DROP_SHIP_FLAG,    
            SHIP_TO_ORGANIZATION_ID = SRC.SHIP_TO_ORGANIZATION_ID,    
            REGIME_CODE = SRC.REGIME_CODE,    
            RELATED_PARTY_FLAG = SRC.RELATED_PARTY_FLAG,    
            SEZ_FLAG = SRC.SEZ_FLAG,    
            SHIP_TO_COUNTRY = SRC.SHIP_TO_COUNTRY,    
            STOCK_TRANSFER_FLAG = SRC.STOCK_TRANSFER_FLAG,    
            HIGH_SEA_SALES_FLAG = SRC.HIGH_SEA_SALES_FLAG    
 FROM @TempLineItems SRC  
 JOIN Vertiv..POERPLineItems TAR   
 ON  SRC.POERPLineItemId=TAR.POERPLineItemId  
  
 END  
 --Insert new Line Items  
  
        INSERT  INTO Vertiv..POERPLineItems  
  (    
            POERPLineItemId,    
            LINE_NUM,    
            ITEM_CODE,    
            ITEM_DESC,    
            HSN_SAC,    
            QTY,    
            UOM,    
            UNIT_PRICE,    
            LINE_AMOUNT,    
            DELIVERY_DATE,    
            POLNUpdtedBy,    
            POLnUpdatedOn,    
            POERPHeaderId,    
            DESTINATION_TYPE_CODE,    
            GST_REVERSE_CHARGE_FLAG,    
            CATEGORY_SEGMENT1,    
            DROP_SHIP_FLAG,    
            SHIP_TO_ORGANIZATION_ID,    
            REGIME_CODE,    
            RELATED_PARTY_FLAG,    
            SEZ_FLAG,    
            SHIP_TO_COUNTRY,    
            STOCK_TRANSFER_FLAG,    
            HIGH_SEA_SALES_FLAG    
        )   
  SELECT  SRC.POERPLineItemId,    
            SRC.LINE_NUM,    
            SRC.ITEM_CODE,    
            SRC.ITEM_DESC,    
            SRC.HSN_SAC,    
            SRC.QTY,    
            SRC.UOM,    
            SRC.UNIT_PRICE,    
            SRC.LINE_AMOUNT,    
            SRC.DELIVERY_DATE,    
            SRC.POLNUpdtedBy,    
            SRC.POLnUpdatedOn,    
            SRC.POERPHeaderId,    
            SRC.DESTINATION_TYPE_CODE,    
            SRC.GST_REVERSE_CHARGE_FLAG,    
   SRC.CATEGORY_SEGMENT1,    
            SRC.DROP_SHIP_FLAG,    
            SRC.SHIP_TO_ORGANIZATION_ID,    
            SRC.REGIME_CODE,    
            SRC.RELATED_PARTY_FLAG,    
            SRC.SEZ_FLAG,    
            SRC.SHIP_TO_COUNTRY,    
            SRC.STOCK_TRANSFER_FLAG,    
            SRC.HIGH_SEA_SALES_FLAG   
  FROM @TempLineItems SRC  
  LEFT JOIN Vertiv..POERPLineItems PLI WITH(NOLOCK)  
  ON  SRC.POERPLineItemId=pli.POERPLineItemId  
  WHERE PLI.POERPLineItemId IS NULL  
  
  --INSERT INTO @POERPLineItemsHistory     
  --SELECT NEWID(),GETDATE(),PLI.* FROM Vertiv..POERPLineItems PLI WITH(NOLOCK)  
  --LEFT JOIN @TempLineItems SRC  
  --ON  SRC.POERPLineItemId=PLI.POERPLineItemId  
  --WHERE PLI.POERPHeaderId IN ( SELECT DISTINCT POERPHeaderId FROM @TempLineItems)  
  --  AND SRC.POERPLineItemId IS NULL  
  
  ----Unmatched LineItem Moved to history  
  --INSERT INTO dbo.POERPLineItemsHistory   
  --SELECT * FROM @POERPLineItemsHistory  
  
  DELETE PLI FROM Vertiv..POERPLineItems PLI    
  WHERE POERPHEADERiD=@HeaderId AND  
  PLI.POERPLineItemId NOT IN (Select POERPLineItemId FROM @TempLineItems )  
   
  
      --Include delete to remove POerplineitems  
   --INSERT INTO POJsonfromERP    
   --VALUES('lineitem',@JsonData,getdate())    
  
END 