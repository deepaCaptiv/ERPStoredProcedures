  
   
CREATE   PROCEDURE [dbo].[Insert_ERPTax_FromJson]  
    @JsonData NVARCHAR(MAX)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
   
  --insert into POJsonfromERP  
  --values('tax',@JsonData,getdate())  
  
 DECLARE @TempTax TABLE  
 (  
   ERPTaxTransactionId VARCHAR(36),  
            ERPTaxType VARCHAR(100),  
            ERPTaxRate DECIMAL(18,2),  
            ERPTaxableAmount DECIMAL(18,2),  
            ERPTaxAmount DECIMAL(18,2),  
            ERPTaxUpdatdBy BIGINT,  
            ERPTaxUpdatedOn DATETIME,  
            POERPHeaderId VARCHAR(36),  
   POERPLineItemId VARCHAR(36)  
 )  
 INSERT INTO @TempTax  
 (  
   ERPTaxTransactionId,  
            ERPTaxType,  
            ERPTaxRate,  
            ERPTaxableAmount,  
            ERPTaxAmount,  
            ERPTaxUpdatdBy,  
            ERPTaxUpdatedOn,  
            POERPHeaderId,  
   POERPLineItemId  
 )  
  SELECT ERPTaxTransactionId,  
            ERPTaxType,  
            ERPTaxRate,  
            ERPTaxableAmount,  
            ERPTaxAmount,  
            ERPTaxUpdatdBy,  
            ERPTaxUpdatedOn,  
            POERPHeaderId,  
   POERPLineItemId  
        FROM OPENJSON(@JsonData)  
        WITH (  
            ERPTaxTransactionId VARCHAR(36),  
            ERPTaxType VARCHAR(100),  
            ERPTaxRate DECIMAL(18,2),  
            ERPTaxableAmount DECIMAL(18,2),  
            ERPTaxAmount DECIMAL(18,2),  
            ERPTaxUpdatdBy BIGINT,  
            ERPTaxUpdatedOn DATETIME,  
            POERPHeaderId VARCHAR(36),  
   POERPLineItemId VARCHAR(36)  
        )  
  
  DECLARE @POERPHeaderId VARCHAR(36)  
  
  SELECT TOP 1 @POERPHeaderId=POERPHeaderId   
  FROM @TempTax  
  
  IF EXISTS ( SELECT 1 FROM Vertiv..ERPTax WITH(NOLOCK) WHERE POERPHeaderId=@POERPHeaderId)  
  
  BEGIN  
  
   INSERT INTO Vertiv..ERPTaxHistory  
   SELECT NEWID(),GETDATE(),TAR.*  
   FROM  Vertiv..ERPTax TAR WITH(NOLOCK)  
   WHERE TAR.POERPHeaderId=@POERPHeaderId  
  
   --Update Existing tax details  
   UPDATE TAR  
   SET   TAR.ERPTaxRate = SRC.ERPTaxRate,  
            TAR.ERPTaxableAmount = SRC.ERPTaxableAmount,  
            TAR.ERPTaxAmount = SRC.ERPTaxAmount,  
            TAR.ERPTaxUpdatdBy = SRC.ERPTaxUpdatdBy,  
            TAR.ERPTaxUpdatedOn = SRC.ERPTaxUpdatedOn  
   FROM  Vertiv..ERPTax TAR  
   JOIN  @TempTax SRC  
   ON  TAR.ERPTaxTransactionId=SRC.ERPTaxTransactionId  
  
   END  
     
   INSERT INTO Vertiv..ERPTax  
   (  
  ERPTaxTransactionId,  
            ERPTaxType,  
            ERPTaxRate,  
            ERPTaxableAmount,  
            ERPTaxAmount,  
            ERPTaxUpdatdBy,  
            ERPTaxUpdatedOn,  
            POERPHeaderId,  
   POERPLineItemId  
 )  
 SELECT TT.ERPTaxTransactionId,  
            TT.ERPTaxType,  
            TT.ERPTaxRate,  
            TT.ERPTaxableAmount,  
            TT.ERPTaxAmount,  
            TT.ERPTaxUpdatdBy,  
            TT.ERPTaxUpdatedOn,  
            TT.POERPHeaderId,  
   TT.POERPLineItemId  
 FROM @TempTax TT  
 LEFT JOIN Vertiv..ERPTax T  
 ON  TT.ERPTaxTransactionId=T.ERPTaxTransactionId  
 WHERE T.ERPTaxTransactionId IS NULL  
  
 --INSERT INTO @ERPTaxHistory  
 --   SELECT NEWID(),GETDATE(),T.* FROM Vertiv..ERPTax T WITH(NOLOCK)  
 --LEFT JOIN @TempTax TT  
 --ON  TT.ERPTaxTransactionId=T.ERPTaxTransactionId  
 --WHERE T.POERPHeaderId =@POERPHeaderId  
 --AND  TT.ERPTaxTransactionId IS NULL  
   
 Delete T FROM  Vertiv..ERPTax T   
 Where T.POERPHeaderId =@POERPHeaderId   
 AND T.ERPTaxTransactionId NOT IN ( SELECT ERPTaxTransactionId FROM @TempTax)  
  
  
    PRINT 'Insert/Update/Delete completed';  
  
END  