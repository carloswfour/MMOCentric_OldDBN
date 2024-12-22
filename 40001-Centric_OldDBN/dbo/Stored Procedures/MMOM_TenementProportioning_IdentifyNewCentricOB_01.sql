CREATE procedure [dbo].[MMOM_TenementProportioning_IdentifyNewCentricOB_01] as
begin

-- compare closing balances from old centric vs ob/locks for new centric
select
ob.quantity -x.stockpiled_dt_total,
ob.*,
ob.quantity as MidCentricQty,
x.stockpiled_dt_total OldCentricQtyDT,
x.stockpiled_wt_total OldCentricQtyWT,
x.*
from
MMOM_TenementProportioning_v2_Materialised_230429_01 x
left outer join
(
select
buj.record_date,
buj.BUSINESS_UNIT_JOURNAL_ENTRY_TYPE_ID bujetid,
bu.business_unit,
buj.quantity
from
centric.dbo.business_unit_journal buj
join
centric.dbo.business_unit bu
on
buj.BUSINESS_UNIT_ID = bu.BUSINESS_UNIT_ID
where
buj.business_unit_journal_entry_type_id not in (2)
and record_date = '2013-12-31 15:59:59.000'
) ob
on
x.stockpile = ob.business_unit
where
x.sp_build_end_next is null
and x.stockpile like '2301red'
--x.stockpile like '%ROM%' or
--x.stockpile like '%BLUE%' or
--x.stockpile like '%ora%' or
--x.stockpile like '%red%'

-- create list of proportions for new centric
select
sp_build_start_next,
x.stockpile,
x.stockpiled_dt,
x.stockpiled_wt,
x.tenement
from
MMOM_TenementProportioning_v2_Materialised_230428_03 x
where
x.sp_build_end_next is null

-- apply proportions to Dispatch records (i.e. AGRB*proportion)



end