CREATE    PROCEDURE [dbo].[SaveGRNHeaderJson]      
    @JsonData NVARCHAR(MAX)      
AS      
BEGIN      
    SET NOCOUNT ON;      
    
    BEGIN TRY      
      
        IF @JsonData IS NULL OR ISJSON(@JsonData) = 0      
        BEGIN      
            RAISERROR('Invalid or NULL JSON passed', 16, 1);      
            RETURN;      
        END;      
       
        --INSERT INTO POJsonfromERP      
        --VALUES ('GRN Before insert', @JsonData, GETDATE());      
    
            
        DECLARE @TempGRNHeader TABLE      
        (      
            grn_id VARCHAR(36),      
            grn_number VARCHAR(30),      
            invoice_no VARCHAR(50),      
            receipt_date DATETIME,      
            po_number VARCHAR(20),      
            vendor_name VARCHAR(200),      
            vendor_gstin VARCHAR(15),      
            ship_to_location VARCHAR(150),      
            receipt_source VARCHAR(20),      
            bill_of_lading VARCHAR(50),      
            packing_slip VARCHAR(50),      
            waybill_number VARCHAR(50),      
            freight_carrier VARCHAR(100),      
            num_of_containers INT      
        );      
    
             
         INSERT INTO @TempGRNHeader      
  (      
   grn_id,      
                grn_number,      
                invoice_no,      
                receipt_date,      
                po_number,      
                vendor_name,      
                vendor_gstin,      
                ship_to_location,      
                receipt_source,      
                bill_of_lading,      
                packing_slip,      
                waybill_number,      
                freight_carrier,      
                num_of_containers      
  )      
    SELECT       
                grn_id,      
                grn_number,      
                invoice_no,      
                receipt_date,      
                po_number,      
                vendor_name,      
                vendor_gstin,      
                ship_to_location,      
                receipt_source,      
                bill_of_lading,      
                packing_slip,      
                waybill_number,      
                freight_carrier,      
                num_of_containers      
            FROM OPENJSON(@JsonData)      
            WITH (      
                grn_id   VARCHAR(36),      
            grn_number VARCHAR(30),      
            invoice_no VARCHAR(50),      
            receipt_date DATETIME,      
            po_number VARCHAR(20),      
            vendor_name VARCHAR(200),      
            vendor_gstin VARCHAR(15),      
            ship_to_location VARCHAR(150),      
            receipt_source VARCHAR(20),      
            bill_of_lading VARCHAR(50),      
            packing_slip VARCHAR(50),      
            waybill_number VARCHAR(50),      
            freight_carrier VARCHAR(100),      
            num_of_containers INT      
    )      
      
 DECLARE @GrnID VARCHAR(36)  
  
 SELECT TOP 1 @GrnID=grn_id   
 FROM @TempGRNHeader  
            
    -- Update Existing    
 IF EXISTS (SELECT 1 FROM Vertiv..GRNHeader WITH(NOLOCK) WHERE grn_id=@GrnID)  
    BEGIN       
         
    INSERT INTO GRNHeaderHistory  
    (  
   GRNHeaderHistoryId,RecordedOn,grn_id,Invoice_no,grn_number,receipt_date,po_number,vendor_name,  
   vendor_gstin,ship_to_location,receipt_source,bill_of_lading,packing_slip,waybill_number,freight_carrier,  
   num_of_containers,created_at,updated_at,deleted_at,DocId,RecieptNo,InstanceId,InvoiceId,GrnStatus  
    )  
  
    SELECT NEWID(),GETDATE(),grn_id,Invoice_no,grn_number,receipt_date,po_number,vendor_name,vendor_gstin,  
    ship_to_location,receipt_source,bill_of_lading,packing_slip,waybill_number,freight_carrier,  
    num_of_containers,created_at,updated_at,deleted_at,DocId,RecieptNo,InstanceId,InvoiceId,GrnStatus  
    FROM  Vertiv..GRNHeader  WITH(NOLOCK)   
    WHERE grn_id=@GrnID  
  
    UPDATE TAR      
        SET      
            grn_number        = SRC.grn_number,      
            invoice_no        = SRC.invoice_no,      
            receipt_date      = SRC.receipt_date,      
            po_number         = SRC.po_number,      
            vendor_name       = SRC.vendor_name,      
            vendor_gstin      = SRC.vendor_gstin,      
            ship_to_location  = SRC.ship_to_location,      
            receipt_source    = SRC.receipt_source,      
            bill_of_lading    = SRC.bill_of_lading,      
            packing_slip      = SRC.packing_slip,      
            waybill_number    = SRC.waybill_number,      
            freight_carrier   = SRC.freight_carrier,      
            num_of_containers = SRC.num_of_containers      
        FROM  Vertiv..GRNHeader TAR      
        JOIN @TempGRNHeader SRC      
            ON TAR.grn_id = SRC.grn_id;     
     
 END  
         -- Insert New Records    
             
        INSERT INTO Vertiv..GRNHeader      
        (      
            grn_id, grn_number, invoice_no, receipt_date, po_number,      
            vendor_name, vendor_gstin, ship_to_location, receipt_source,      
            bill_of_lading, packing_slip, waybill_number, freight_carrier, num_of_containers      
        )      
        SELECT      
        TPO.grn_id,      
                TPO.grn_number,      
                TPO.invoice_no,      
                TPO.receipt_date,      
                TPO.po_number,      
                TPO.vendor_name,      
                TPO.vendor_gstin,      
                TPO.ship_to_location,      
                TPO.receipt_source,      
                TPO.bill_of_lading,      
                TPO.packing_slip,      
                TPO.waybill_number,      
                TPO.freight_carrier,      
                TPO.num_of_containers      
        FROM @TempGRNHeader TPO      
        LEFT JOIN Vertiv..GRNHeader PO      
            ON TPO.grn_id = PO.grn_id      
        WHERE PO.grn_id IS NULL;      
    
         DECLARE @InsertedGRNs TABLE      
        (      
            grn_number VARCHAR(30),      
            GRNCreatedOn DATETIME      
        );      
  INSERT INTO @InsertedGRNs  
  (grn_number,GRNCreatedOn)  
        SELECT  grn_number  AS GRN_NUMBER ,GETDATE()   
  FROM @TempGRNHeader;      
      
   --INSERT INTO POJsonfromERP (PONUMBER, JsonData, createdat)      
   --OUTPUT INSERTED.PONUMBER, INSERTED.createdat INTO @InsertedGRNs      
     
    
        SELECT grn_number, @JsonData, GETDATE()      
        FROM @TempGRNHeader;      
    
         SELECT * FROM @InsertedGRNs;      
       
             
        -- Loop & Call Procedure     
        DECLARE @tempgrnnumber VARCHAR(30);      
    
        WHILE EXISTS (SELECT 1 FROM @InsertedGRNs)      
        BEGIN      
            SELECT TOP 1 @tempgrnnumber = grn_number      
            FROM @InsertedGRNs;      
    
            IF (@tempgrnnumber IS NOT NULL)      
            BEGIN      
                EXEC vertiv..GenerateDossierGRN @tempgrnnumber;      
            END      
    
            DELETE FROM @InsertedGRNs      
            WHERE grn_number = @tempgrnnumber;      
        END;      
    
    END TRY      
    BEGIN CATCH      
        SELECT      
            'ERROR' AS Status,      
            ERROR_MESSAGE() AS ErrorMessage,      
            ERROR_LINE() AS ErrorLine;      
    END CATCH      
END; 