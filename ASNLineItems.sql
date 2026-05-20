  CREATE PROCEDURE [dbo].[saveasnlineitemsjson_new]  
    @jsondata NVARCHAR(MAX)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    BEGIN TRY  
  
        IF @jsondata IS NULL OR ISJSON(@jsondata) = 0  
        BEGIN  
            THROW 50001, 'Invalid or null JSON passed to saveasnlineitemsjson_new', 1;  
        END;  
  
        INSERT INTO vertiv..pojsonfromerp  
        VALUES ('before asn line insert', @jsondata, GETDATE());  
  
          
        -- TEMP TABLE  
          
        DECLARE @templineitems TABLE  
        (  
            asnlineitemid VARCHAR(36),  
            asnid VARCHAR(36),  
            [lineno] INT,  
            itemcode VARCHAR(50),  
            itemdesc NVARCHAR(4000),  
            uom VARCHAR(50),  
            poqty DECIMAL(18,2),  
            openqty DECIMAL(18,2),  
            shippedqty DECIMAL(18,2),  
            noofpackage INT,  
            batchno VARCHAR(100)  
        );  
  
          
        -- JSON TO TEMP TABLE  
          
        INSERT INTO @templineitems  
        SELECT  
            asn_line_item_id,  
            asn_id,  
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
  
          
        -- UPDATE EXISTING RECORDS  
          
        UPDATE tar  
        SET  
            tar.asnid = src.asnid,  
            tar.[lineno] = src.[lineno],  
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
            batchno  
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
            src.batchno  
        FROM @templineitems src  
        LEFT JOIN vertiv..asnlineitems tar  
            ON src.asnlineitemid = tar.asnlineitemid  
        WHERE tar.asnlineitemid IS NULL;  
  
           
        INSERT INTO vertiv..pojsonfromerp  
        VALUES ('after asn line insert', @jsondata, GETDATE());  
  
    END TRY  
    BEGIN CATCH  
  
        SELECT  
            'error' AS status,  
            ERROR_MESSAGE() AS errormessage,  
            ERROR_LINE() AS errorline;  
  
    END CATCH  
END;