Select * from portfolioproject.data;
-- Standarize Date Format----------------------------------------------------------------------------------
Select SaleDate, CONVERT(SaleDate, date)
from PortfolioProject.data;

ALTER TABLE PortfolioProject.data Add SaleDateConverted Date;

Update PortfolioProject.data SET SaleDateConverted = CONVERT(SaleDate, date);

Select SaleDate, SaleDateConverted, CONVERT(SaleDate, date) from portfolioproject.data;

-- Populate property Address
Select PropertyAddress
from PortfolioProject.data
where PropertyAddress = 'none';


Update PortfolioProject.data SET PropertyAddress = null 
where PropertyAddress = 'none';

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
from portfolioproject.data a
join portfolioproject.data b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress = null;

-- Breaking out Address into individual columns (Address, City, State)----------------------

Select PropertyAddress
from PortfolioProject.data;

SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress)) as City
from PortfolioProject.data;

ALTER TABLE PortfolioProject.data Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.data SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE PortfolioProject.data Add PropertySplitCity nvarchar(255);

Update PortfolioProject.data SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress));

Select * from PortfolioProject.data; 

Select OwnerAddress from PortfolioProject.data; 

CREATE FUNCTION SPLIT_STR(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
)
RETURNS VARCHAR(255) DETERMINISTIC
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '');
       
SELECT SPLIT_STR(OwnerAddress, ',',1),
SPLIT_STR(OwnerAddress, ',',2),
SPLIT_STR(OwnerAddress, ',',3)
from PortfolioProject.data; 


ALTER TABLE PortfolioProject.data Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.data SET OwnerSplitAddress = SPLIT_STR(OwnerAddress, ',',1);

ALTER TABLE PortfolioProject.data Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.data SET OwnerSplitCity = SPLIT_STR(OwnerAddress, ',',2);

ALTER TABLE PortfolioProject.data Add OwnerSplitState nvarchar(255);

Update PortfolioProject.data SET OwnerSplitState = SPLIT_STR(OwnerAddress, ',',3);


Select * from PortfolioProject.data; 

-- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

Select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.data
group by SoldAsVacant
order by 2; 

Select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
end
from PortfolioProject.data;

update PortfolioProject.data
set SoldAsVacant=case when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
end;

-- Remove duplicates-----------------------------------------------------------------------

with RowNumCTE AS(
Select *,
	row_number() over(
    partition by ParcelID,
                SalePrice,
                SaleDate,
                LegalReference
                order by UniqueID
                ) row_num
from PortfolioProject.data
)
select * 
from RowNumCTE
where row_num > 1;

-- Delete Unused Columns-----------------------------------------------------
ALTER TABLE PortfolioProject.data 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE PortfolioProject.data 
DROP COLUMN SaleDate;