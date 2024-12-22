create view MMOM_OldDMIRSSubmission_01 as
-- 230512
-- To service request by Jeanne Lippiatt
select
*
from
DispatchBrowseNew x
where
x.SHIFT_DATE between '2010-1-1' and '2012-6-30'