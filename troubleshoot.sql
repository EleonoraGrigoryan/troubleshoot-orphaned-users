-- Troubleshoot Orphaned Users

-- Variables
declare @saSID sysname 
declare @count int
declare @countOfUsers int = 0
declare @dynamic nvarchar(120)
declare @userholder nvarchar(50)

-- Cursor for Orphaned User Names
declare cr_users cursor
for
select dp.name as user_name
from sys.database_principals as dp   
left join sys.server_principals as sp  
    on dp.SID = sp.SID  
where sp.SID is null and dp.name != 'dbo'
    and (authentication_type_desc = 'INSTANCE' or  authentication_type_desc = 'WINDOWS'); 

	open cr_users
		fetch next from cr_users into @userholder

		-- Find the Count of Users
		-- select @count = count(dp.SID)   -- Optional
		-- from sys.database_principals as dp   
		-- left join sys.server_principals as sp  
		--	on dp.SID = sp.SID  
		-- where sp.SID is null and dp.name != 'dbo'
		--	and (authentication_type_desc = 'INSTANCE' or  authentication_type_desc = 'WINDOWS'); 


		while @@fetch_status = 0
		begin
		 --   while @countOfUsers <> @count  -- Optional
		 --	  begin
				  set @countOfUsers = @countOfUsers + 1
				  set @dynamic = 'create login forOrphaned' + cast(@countOfUsers as nvarchar(40)) + ' with password = ''1234AbCd'''
				  exec(@dynamic)
				  --print @dynamic
				  set @dynamic = 'alter user '+ @userholder+ ' with login = forOrphaned'+cast(@countOfUsers as nvarchar(40)) ; 
				  exec( @dynamic)
				  --print @dynamic

				  fetch next from cr_users into @userholder
		 --	end
		end

	close cr_users
	deallocate cr_users




