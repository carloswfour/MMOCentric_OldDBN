ALTER ROLE [db_ddladmin] ADD MEMBER [ANYACCESS\KDaws];


GO
ALTER ROLE [db_ddladmin] ADD MEMBER [MINARA\kdaws-p];


GO
ALTER ROLE [db_ddladmin] ADD MEMBER [MINARA\kdaws];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [ANYACCESS\KDaws];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [MINARA\kdaws-p];


GO
ALTER ROLE [db_datawriter] ADD MEMBER [MINARA\kdaws];


GO
ALTER ROLE [db_datareader] ADD MEMBER [ANYACCESS\KDaws];


GO
ALTER ROLE [db_datareader] ADD MEMBER [PythonRW];


GO
ALTER ROLE [db_datareader] ADD MEMBER [MINARA\kdaws-p];


GO
ALTER ROLE [db_datareader] ADD MEMBER [MiningReportViewer];


GO
ALTER ROLE [db_datareader] ADD MEMBER [MINARA\kdaws];

