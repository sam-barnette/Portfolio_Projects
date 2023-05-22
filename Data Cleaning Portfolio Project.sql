-- adding a unique ID to every row

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD ID INT IDENTITY(1,1)

-- populating null fields with matching existing fields


SELECT * --PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


-- finding the matching data


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


-- updating the table with the existing data


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID


-- breaking up the property addresses into invidiual columns (address and city)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, 
CASE
WHEN
CHARINDEX(',', PropertyAddress ) = 0 THEN LEN(PropertyAddress)
ELSE CHARINDEX(',', PropertyAddress) - 1 end) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


-- adding the split address into the table with new columns


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, 
CASE
WHEN
CHARINDEX(',', PropertyAddress ) = 0 THEN LEN(PropertyAddress)
ELSE CHARINDEX(',', PropertyAddress) - 1 end)
, PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- breaking up the owner addresses into invidiual columns (address, city, state)


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing


-- adding the split data into the table


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255), 
OwnerSplitCity NVARCHAR(255), 
OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- to make all of the rows standardized since it has a mix of 'y' , 'n', 'yes', 'no'


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing


-- to remove duplicate entries


WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) Row_Num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1


-- deleting unused columns


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress