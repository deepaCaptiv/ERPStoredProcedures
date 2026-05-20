USE [Vertiv]
GO

/****** Object:  StoredProcedure [dbo].[UpsertPaymentReceipt_FromJson]    Script Date: 20-05-2026 16:03:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER      procedure [dbo].[UpsertPaymentReceipt_FromJson]    
    @jsondata nvarchar(max)    
as    
begin    
    set nocount on;    
  
    begin try    
    
        if @jsondata is null or isjson(@jsondata) = 0    
        begin    
            raiserror('invalid or null json passed', 16, 1);    
            return;    
        end;    
     
        insert into pojsonfromerp    
        values ('asn before insert', @jsondata, getdate());    
  
          
        declare @tempheader table    
        (      
		        payment_id VARCHAR(36),    
                check_id BIGINT,    
                payment_number VARCHAR(50),    
                payment_date DATETIME,    
                payment_method VARCHAR(30),    
                payment_type VARCHAR(25),    
                payment_status VARCHAR(25),    
                payment_amount DECIMAL(18, 2),    
                payment_currency_code VARCHAR(15),    
                exchange_rate DECIMAL(18, 6),    
                base_currency_code VARCHAR(15),    
                base_amount DECIMAL(18, 2),    
                vendor_id BIGINT,    
                vendor_name VARCHAR(200),    
                vendor_site_code VARCHAR(50),    
                bank_account_name VARCHAR(80),    
                bank_account_num VARCHAR(30),    
                bank_name VARCHAR(100),    
                bank_branch_name VARCHAR(100),    
                cleared_date DATETIME,    
                void_date DATETIME,    
                transaction_reference VARCHAR(100),    
                payment_document_num VARCHAR(50),    
                payment_process_request_name VARCHAR(100),    
                legal_entity_id BIGINT,    
                org_id BIGINT,    
                description NVARCHAR(500),    
                source_system VARCHAR(50),    
                created_by VARCHAR(100),    
                updated_by VARCHAR(100),    
                deleted_by VARCHAR(100),    
                created_at DATETIME,    
                updated_at DATETIME,    
                deleted_at DATETIME  
             
        );    
  
           
         insert into @tempheader    
  (             payment_id,    
                check_id,    
                payment_number,    
                payment_date,    
                payment_method,    
                payment_type,    
                payment_status,    
                payment_amount,    
                payment_currency_code,    
                exchange_rate,    
                base_currency_code,    
                base_amount,    
                vendor_id,    
                vendor_name,    
                vendor_site_code,    
                bank_account_name,    
                bank_account_num,    
                bank_name,    
                bank_branch_name,    
                cleared_date,    
                void_date,    
                transaction_reference,    
                payment_document_num,    
                payment_process_request_name,    
                legal_entity_id,    
                org_id,    
                description,    
                source_system,    
                created_by,    
                updated_by,    
                created_at    )
    select     
               payment_id,    
                check_id,    
                payment_number,    
                payment_date,    
                payment_method,    
                payment_type,    
                payment_status,    
                payment_amount,    
                payment_currency_code,    
                exchange_rate,    
                base_currency_code,    
                base_amount,    
                vendor_id,    
                vendor_name,    
                vendor_site_code,    
                bank_account_name,    
                bank_account_num,    
                bank_name,    
                bank_branch_name,    
                cleared_date,    
                void_date,    
                transaction_reference,    
                payment_document_num,    
                payment_process_request_name,    
                legal_entity_id,    
                org_id,    
                description,    
                source_system,    
                created_by,    
                updated_by,    
                created_at    
				
            from openjson(@jsondata)    
            with (    
               payment_id VARCHAR(36),    
                check_id BIGINT,    
                payment_number VARCHAR(50),    
                payment_date DATETIME,    
                payment_method VARCHAR(30),    
                payment_type VARCHAR(25),    
                payment_status VARCHAR(25),    
                payment_amount DECIMAL(18, 2),    
                payment_currency_code VARCHAR(15),    
                exchange_rate DECIMAL(18, 6),    
                base_currency_code VARCHAR(15),    
                base_amount DECIMAL(18, 2),    
                vendor_id BIGINT,    
                vendor_name VARCHAR(200),    
                vendor_site_code VARCHAR(50),    
                bank_account_name VARCHAR(80),    
                bank_account_num VARCHAR(30),    
                bank_name VARCHAR(100),    
                bank_branch_name VARCHAR(100),    
                cleared_date DATETIME,    
                void_date DATETIME,    
                transaction_reference VARCHAR(100),    
                payment_document_num VARCHAR(50),    
                payment_process_request_name VARCHAR(100),    
                legal_entity_id BIGINT,    
                org_id BIGINT,    
                description NVARCHAR(500),    
                source_system VARCHAR(50),    
                created_by VARCHAR(100),    
                updated_by VARCHAR(100),    
                deleted_by VARCHAR(100),    
                created_at DATETIME,    
                updated_at DATETIME,    
                deleted_at DATETIME  
    )    
         
          
        -- update existing  
          
        update tar    
        set      
		        tar.payment_id                        = src.payment_id,    
                tar.check_id                          = src.check_id,    
                tar.payment_date                      = src.payment_date,    
                tar.payment_method                    = src.payment_method,    
                tar.payment_type                      = src.payment_type,    
                tar.payment_status                    = src.payment_status,    
                tar.payment_amount                    = src.payment_amount,    
                tar.payment_currency_code             = src.payment_currency_code,    
                tar.exchange_rate                     = src.exchange_rate,    
                tar.base_currency_code                = src.base_currency_code,    
                tar.base_amount                       = src.base_amount,    
                tar.vendor_id                         = src.vendor_id,    
                tar.vendor_name                       = src.vendor_name,    
                tar.vendor_site_code                  = src.vendor_site_code,    
                tar.bank_account_name                 = src.bank_account_name,    
                tar.bank_account_num                  = src.bank_account_num,    
                tar.bank_name                         = src.bank_name,    
                tar.bank_branch_name                  = src.bank_branch_name,    
                tar.cleared_date                      = src.cleared_date,    
                tar.void_date                         = src.void_date,    
                tar.transaction_reference             = src.transaction_reference,    
                tar.payment_document_num              = src.payment_document_num,    
                tar.payment_process_request_name      = src.payment_process_request_name,    
                tar.legal_entity_id                   = src.legal_entity_id,    
                tar.org_id                            = src.org_id,    
                tar.description                       = src.description,    
                tar.source_system                     = src.source_system,    
                tar.updated_by                        = src.updated_by,    
                tar.updated_at                        = ISNULL(src.updated_at, GETDATE()),    
                tar.deleted_by                        = src.deleted_by,    
                tar.deleted_at                        = src.deleted_at  
    
        from vertiv..PaymentReceipt tar    
        join @tempheader src    
            on tar.payment_id = src.payment_id;    
  
         -- insert new records  
           
        insert into vertiv..PaymentReceipt    
        (    
               payment_id,    
                check_id,    
                payment_number,    
                payment_date,    
                payment_method,    
                payment_type,    
                payment_status,    
                payment_amount,    
                payment_currency_code,    
                exchange_rate,    
                base_currency_code,    
                base_amount,    
                vendor_id,    
                vendor_name,    
                vendor_site_code,    
                bank_account_name,    
                bank_account_num,    
                bank_name,    
                bank_branch_name,    
                cleared_date,    
                void_date,    
                transaction_reference,    
                payment_document_num,    
                payment_process_request_name,    
                legal_entity_id,    
                org_id,    
                description,    
                source_system,    
                created_by,    
                updated_by,    
                created_at         
        )    
        select    
                tpo.payment_id,    
                tpo.check_id,    
                tpo.payment_number,    
                tpo.payment_date,    
                tpo.payment_method,    
                tpo.payment_type,    
                tpo.payment_status,    
                tpo.payment_amount,    
                tpo.payment_currency_code,    
                tpo.exchange_rate,    
                tpo.base_currency_code,    
                tpo.base_amount,    
                tpo.vendor_id,    
                tpo.vendor_name,    
                tpo.vendor_site_code,    
                tpo.bank_account_name,    
                tpo.bank_account_num,    
                tpo.bank_name,    
                tpo.bank_branch_name,    
                tpo.cleared_date,    
                tpo.void_date,    
                tpo.transaction_reference,    
                tpo.payment_document_num,    
                tpo.payment_process_request_name,    
                tpo.legal_entity_id,    
                tpo.org_id,    
                tpo.description,    
                tpo.source_system,    
                tpo.created_by,    
                tpo.updated_by,    
                GETDATE() -- Created at current time    

        from @tempheader tpo    
        left join vertiv..PaymentReceipt po    
            on tpo.payment_id = po.payment_id    
        where po.payment_id is null;    
  
           
    
        select  payment_number  as PaymentNumber 
  from @tempheader;    
    
   insert into pojsonfromerp (ponumber, jsondata, createdat)    

   
  
        select payment_number, @jsondata, getdate()    
        from @tempheader;    
      
      
    end try    
    begin catch    
        select    
            'error' as status,    
            error_message() as errormessage,    
            error_line() as errorline;    
    end catch    
end;  
GO


