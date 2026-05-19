CREATE   PROCEDURE [dbo].[Insert_ERPTax_FromJson]  
    @JsonData NVARCHAR(MAX)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
  insert into POJsonfromERP  
  values('tax',@JsonData,getdate())  
  
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
     
   
  
    PRINT 'Insert/Update completed';  
END  