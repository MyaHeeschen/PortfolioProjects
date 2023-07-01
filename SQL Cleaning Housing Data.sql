/*

	Cleaning Data in SQL

*/

select*
from NashHousing

-------------------------------------------------------------------------------------------

--Standardize Format

-----SaleDate (fet rid of time because it's all 00:00)

select SaleDateConverted
from NashHousing

select SaleDate, convert(date,SaleDate)
from NashHousing

alter table NashHousing
add SaleDateConverted date;

update NashHousing
set SaleDateConverted = convert(date,SaleDate)



-------------------------------------------------------------------------------------------

--Populate PropertyAddress data

-----Use ParcelID as reference

select *
from NashHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashHousing a
join NashHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashHousing a
join NashHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-------------------------------------------------------------------------------------------

--Seperating address into adress, city, state

-----Porperty address

select PropertyAddress
from NashHousing

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from NashHousing

alter table NashHousing
add PropertySplitAddress nvarchar(300);
update NashHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashHousing
add PropertySplitCity nvarchar(300);
update NashHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))



-----Owner address

select OwnerAddress
from NashHousing

select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashHousing

alter table NashHousing
add OwnerSplitAddress nvarchar(300);
update NashHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashHousing
add OwnerSplitCity nvarchar(300);
update NashHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashHousing
add OwnerSplitState nvarchar(300);
update NashHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)



-------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldAsVacant

Select distinct(SoldAsVacant), count(SoldAsVacant)
from NashHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from NashHousing

update NashHousing
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end



-------------------------------------------------------------------------------------------

--Remove duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
					) row_num
from NashHousing
--order by ParcelID
)
--delete
select *
from RowNumCTE
where row_num > 1



-------------------------------------------------------------------------------------------

-- Delete unused columns

select *
from NashHousing

alter table NashHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

