 CREATE PROCEDURE [dbo].[saveasnlineitemsjson_new]    
    @jsondata NVARCHAR(MAX)    
AS    
BEGIN    
    SET NOCOUNT ON;    
    
      
    
  --INSERT INTO vertiv..pojsonfromerp    
  --      VALUES ('before asn line insert', @jsondata, GETDATE());    
    
        
   IF @jsondata IS NULL OR ISJSON(@jsondata) = 0    
        BEGIN    
            THROW 50001, 'Invalid or null JSON passed to saveasnlineitemsjson_new', 1;    
        END;    
    
  BEGIN TRY         
            
        -- TEMP TABLE    
  
            
  DECLARE @templineitems TABLE (  asnlineitemid VARCHAR(36),    
          asnid VARCHAR(36),    
          supp_Invoice_no VARCHAR(50),  
          erp_Invoice_no VARCHAR(50),  
          PoNumber VARCHAR(50),  
          [lineno] INT,    
          itemcode VARCHAR(50),    
          itemdesc NVARCHAR(4000),    
          uom VARCHAR(50),    
          poqty DECIMAL(18,2),    
          openqty DECIMAL(18,2),    
          shippedqty DECIMAL(18,2),    
          noofpackage INT,    
          batchno VARCHAR(100)  );    
    
              
        -- JSON TO TEMP TABLE    
       
        INSERT INTO @templineitems    
        SELECT    
            asn_line_item_id,    
            asn_id,    
   supp_Invoice_no,  
   erp_Invoice_no,  
   PoNumber,  
            line_no,    
            item_code,    
            item_desc,    
            uom,    
            po_qty,    
            open_qty,    
            shipped_qty,    
            no_of_packages,    
            batch_no    
        FROM OPENJSON(@jsondata)    
        WITH    
        (    
            asn_line_item_id VARCHAR(36) '$.asn_line_item_id',    
            asn_id VARCHAR(36) '$.asn_id',    
   supp_Invoice_no VARCHAR(50) '$.supp_Invoice_no',    
   erp_Invoice_no VARCHAR(50) '$.erp_Invoice_no',    
   PoNumber VARCHAR(50) '$.po_number',    
            line_no INT '$.line_no',    
            item_code VARCHAR(50) '$.item_code',    
            item_desc NVARCHAR(4000) '$.item_desc',    
            uom VARCHAR(50) '$.uom',    
            po_qty DECIMAL(18,2) '$.po_qty',    
            open_qty DECIMAL(18,2) '$.open_qty',    
            shipped_qty DECIMAL(18,2) '$.shipped_qty',    
            no_of_packages INT '$.no_of_packages',    
            batch_no VARCHAR(100) '$.batch_no'    
        );    
    
     DECLARE @AsnId VARCHAR(36)  
  
 SELECT TOP 1 @AsnId=asnid   
 FROM @templineitems  
  
  IF EXISTS ( SELECT  1 FROM vertiv..asnlineitems WITH(NOLOCK) WHERE asnid=@AsnId)  
  BEGIN    
    
  INSERT INTO ASNLineItemsHistory  
  (  
   ASNLineItemsHistoryId,RecordedOn,ASNLineItemId,ASNId,[LineNo],ItemCode,ItemDesc,UOM,  
   POQty,OpenQty,ShippedQty,NoOfPackage,BatchNo,supp_invoice_no,erp_invoice_no,ponumber  
  )  
  SELECT NEWID(),GETDATE(),ASNLineItemId,ASNId,[LineNo],ItemCode,ItemDesc,UOM,  
   POQty,OpenQty,ShippedQty,NoOfPackage,BatchNo,supp_invoice_no,erp_invoice_no,ponumber  
  FROM vertiv..asnlineitems WITH(NOLOCK)   
  WHERE asnid=@AsnId  
  
        -- UPDATE EXISTING RECORDS    
            
        UPDATE tar    
        SET    
            tar.asnid = src.asnid,    
            tar.[lineno] = src.[lineno],    
   tar.supp_invoice_no=src.supp_Invoice_no,  
   tar.erp_invoice_no=src.erp_Invoice_no,  
   tar.ponumber=src.PoNumber,  
            tar.itemcode = src.itemcode,    
            tar.itemdesc = src.itemdesc,    
            tar.uom = src.uom,    
            tar.poqty = src.poqty,    
            tar.openqty = src.openqty,    
            tar.shippedqty = src.shippedqty,    
            tar.noofpackage = src.noofpackage,    
            tar.batchno = src.batchno    
        FROM vertiv..asnlineitems tar    
        INNER JOIN @templineitems src    
            ON tar.asnlineitemid = src.asnlineitemid;    
    
  END  
            
        -- INSERT NEW RECORDS    
            
        INSERT INTO vertiv..asnlineitems    
        (    
            asnlineitemid,    
            asnid,    
            [lineno],    
            itemcode,    
            itemdesc,    
            uom,    
            poqty,    
            openqty,    
           shippedqty,    
            noofpackage,    
            batchno ,  
            supp_invoice_no,  
   erp_invoice_no,  
   ponumber    
     
        )    
        SELECT    
            src.asnlineitemid,    
            src.asnid,    
            src.[lineno],    
            src.itemcode,    
            src.itemdesc,    
            src.uom,    
            src.poqty,    
            src.openqty,    
            src.shippedqty,    
            src.noofpackage,    
            src.batchno  ,  
   src.supp_Invoice_no,  
   src.erp_Invoice_no,  
   src.PoNumber  
        FROM @templineitems src    
        LEFT JOIN vertiv..asnlineitems tar  WITH(NOLOCK)  
            ON src.asnlineitemid = tar.asnlineitemid    
        WHERE tar.asnlineitemid IS NULL;    
  
  
  DELETE  TAR   
  FROM vertiv..asnlineitems TAR   
  WHERE asnid=@AsnId AND   
  TAR.ASNLineItemId NOT IN (   
         SELECT asnlineitemid   
         FROM @templineitems  
         )  
  
  
  --INSERT INTO vertiv..pojsonfromerp    
  --      VALUES ('After asn line insert', @jsondata, GETDATE());    
  
    END TRY    
    BEGIN CATCH    
    
        SELECT    
            'error' AS status,    
            ERROR_MESSAGE() AS errormessage,    
            ERROR_LINE() AS errorline;    
    
    END CATCH    
  
END;    
  