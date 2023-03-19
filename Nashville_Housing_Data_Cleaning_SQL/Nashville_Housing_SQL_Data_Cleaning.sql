-- Nashville Housing Data Cleaning Project 

-- Selecting Table for Data Cleaning

SELECT * FROM SQLProject.dbo.NashvilleHousing;

-- Standardizing Date Format

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE SQLProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Populating Property Address Data

SELECT * FROM SQLProject.dbo.NashvilleHousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM SQLProject.dbo.NashvilleHousing a
JOIN SQLProject.dbo.NashvilleHousing b
ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
ORDER BY a.parcelid;

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM SQLProject.dbo.NashvilleHousing a
JOIN SQLProject.dbo.NashvilleHousing b
ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

-- Splitting address into address and city

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) AS address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) AS city
FROM SQLProject.dbo.NashvilleHousing;

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE SQLProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1);

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE SQLProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress));

-- Splitting owner address into address, city and state

SELECT
 -- Replacing comma with period in owner address as parsename looks for period
PARSENAME(REPLACE(owneraddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(owneraddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(owneraddress, ',', '.'), 1) AS OwnerSplitState
FROM SQLProject.dbo.NashvilleHousing;

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE SQLProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE SQLProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2);

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE SQLProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1);

-- Changing Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant) AS Count
FROM SQLProject.dbo.NashvilleHousing
GROUP BY soldasvacant
ORDER BY Count;

SELECT soldasvacant,
CASE
WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM SQLProject.dbo.NashvilleHousing;

UPDATE SQLProject.dbo.NashvilleHousing
SET soldasvacant = CASE
	WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END;

-- Removing duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
ORDER BY uniqueid) row_num
FROM SQLProject.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1;

-- Deleting unused columns

ALTER TABLE SQLProject.dbo.NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress;

ALTER TABLE SQLProject.dbo.NashvilleHousing
DROP COLUMN saledate;