/* 
Data cleaning in SQL queries
*/

SELECT *
FROM PortfolioProject..NashvilleHousing
---------------------------------------------

-- Standardize the date format
SELECT SaleDate2, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDate2 Date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(Date, SaleDate)
---------------------------------------------

-- Populate property address data

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing 
WHERE PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL
-------------------------------------

--Seperate 'Address' into columns (Address, City,, State)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD Address NVARCHAR(255);

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD City NVARCHAR(255);

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--OwnerAddress

ALTER TABLE NashvilleHousing
ADD OwnerAddress2 NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerAddress2 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2
------------------------------

--CHANGE 'Y' to 'Yes' and 'N' to 'No'
UPDATE NashvilleHousing
SET SoldAsVacant=
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
---------------------------------

--Remove duplicates

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
	PARTITION BY 
	ParcelID, 
	PropertyAddress, 
	SalePrice, 
	SaleDate, 
	LegalReference
	ORDER BY UniqueID
	) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

DELETE
FROM RowNumCTE
WHERE row_num > 1
-----------------------------------

--Delete unused columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
