-- Nashville Housing Data Analysis

-- Selecting Table and Performing Data Cleaning

SELECT * FROM NashvilleProject.dbo.NashvilleHousing;

-- Standardizing Date Format

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Populating Property Address Data

SELECT * FROM NashvilleProject.dbo.NashvilleHousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL
ORDER BY a.parcelid;

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM NashvilleProject.dbo.NashvilleHousing a
JOIN NashvilleProject.dbo.NashvilleHousing b
ON a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

-- Splitting address into address and city

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) AS address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) AS city
FROM NashvilleProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1);

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress));

-- Splitting owner address into address, city and state

SELECT
 -- Replacing comma with period in owner address as parsename looks for period
PARSENAME(REPLACE(owneraddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(owneraddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(owneraddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleProject.dbo.NashvilleHousing;

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2);

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1);

-- Changing Y and N to Yes and No in "Sold as vacant" field

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant) AS Count
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY soldasvacant
ORDER BY Count;

SELECT soldasvacant,
CASE
WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM NashvilleProject.dbo.NashvilleHousing;

UPDATE NashvilleProject.dbo.NashvilleHousing
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
FROM NashvilleProject.dbo.NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num > 1;

-- Deleting unused columns

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress;

ALTER TABLE NashvilleProject.dbo.NashvilleHousing
DROP COLUMN saledate;

-- Performing Exploratory Data Analysis

SELECT * FROM NashvilleProject.dbo.NashvilleHousing;

-- Checking the record count

SELECT COUNT(*) AS NumberofRecords
FROM NashvilleProject.dbo.NashvilleHousing;

-- 56477

-- Number of properties by Land use

SELECT LandUse, COUNT(*) as PropertyCount
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY LandUse
ORDER BY PropertyCount DESC;

-- Most properties have single family and residential condos land use

-- Average sale price of properties in different land use categories

SELECT LandUse, ROUND(AVG(SalePrice),2) as AvgSalePrice
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY LandUse
ORDER BY AvgSalePrice DESC;

-- Vacant commercial land has the highest sale price and vacant zoned multifamily has the lowest sale price.
-- Low rise apartments also have a relatively high sale price

-- Total property value change over the years

SELECT YearBuilt, SUM(TotalValue) as TotalPropertyValue
FROM NashvilleProject.dbo.NashvilleHousing
WHERE YearBuilt IS NOT NULL
GROUP BY YearBuilt
ORDER BY TotalPropertyValue DESC;

-- Total property value is the highest in 2015 and lowest in 1880

-- Trends in property sales over the years

SELECT YEAR(SaleDateConverted) AS SaleYear, COUNT(*) as SalesCount, SUM(SalePrice) AS TotalSalePrice
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY YEAR(SaleDateConverted)
ORDER BY SalesCount DESC;

-- 2015 has the highest number of property sales i.e., 16829 and hence, the highest total sales price
-- 2019 has the lowest number of property sales i.e., 2

-- Seasonal patterns in property sales

SELECT MONTH(SaleDateConverted) as SaleMonth, COUNT(*) as SalesCount
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY MONTH(SaleDateConverted)
ORDER BY SalesCount DESC;

-- The months of May and June record the highest number of sales
-- The month of February recorded the lowest number of sales

-- Land use category with the highest average acreage

SELECT TOP 1 LandUse, AVG(Acreage) as AvgAcreage
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY LandUse
ORDER BY AvgAcreage DESC;

-- The Forest land use category has the highest acreage on average (20.083 acres)

-- Average number of bedrooms and bathrooms for different property types

SELECT LandUse, ROUND(AVG(Bedrooms), 2) as AvgBedrooms, ROUND(AVG(FullBath), 2) as AvgFullBath
FROM NashvilleProject.dbo.NashvilleHousing
GROUP BY LandUse
HAVING AVG(Bedrooms) IS NOT NULL AND AVG(FullBath) IS NOT NULL;

-- Correlation between year built and sale price

SELECT YearBuilt, ROUND(AVG(SalePrice),2) as AvgSalePrice
FROM NashvilleProject.dbo.NashvilleHousing
WHERE YearBuilt IS NOT NULL
GROUP BY YearBuilt
ORDER BY YearBuilt;

-- There is no specific correlation between year built and average sale price

-- Top property owners by the number of properties owned

SELECT TOP 5 OwnerName, COUNT(*) AS PropertyCount
FROM NashvilleProject.dbo.NashvilleHousing
WHERE OwnerName IS NOT NULL
GROUP BY OwnerName
ORDER BY PropertyCount DESC;

-- JRG PROPERTIES, LLC
-- HILL 33, LLC
-- SUMMEY, CLARENCE
-- FED DEVELOPMENT, LLC
-- KHAZANOV, MAX

-- Top property owners (by number of properties owned) by land use

WITH OwnerRanking AS (
    SELECT OwnerName, LandUse,
           ROW_NUMBER() OVER (PARTITION BY LandUse ORDER BY COUNT(*) DESC) AS OwnerRank
    FROM NashvilleProject.dbo.NashvilleHousing
    GROUP BY OwnerName, LandUse
)
SELECT
    OwnerName,
    LandUse
FROM OwnerRanking
WHERE OwnerRank = 1 and OwnerName IS NOT NULL;

-- EGERTON, MARCH - DAY CARE CENTER
-- CURTIS PARTNERS, LLC - FOREST
-- MANNING, DAVID W. & BETSY B. - GREENBELT
-- REEVES, TERRY C. & DIANE D. - GREENBELT/RES  GRRENBELT/RES
-- PARO SOUTH, LLC - LIGHT MANUFACTURING
-- FMBC INVESTMENTS, LLC - METRO OTHER THAN OFC, SCHOOL,HOSP, OR PARK
-- ENFIELD PROPERTIES, LLC - MOBILE HOME
-- NESTA, LAURA B. & JONATHAN F. - MORTUARY/CEMETERY
-- CAUDELL, CHARLES	- NON-PROFIT CHARITABLE SERVICE
-- CROSSROADS CAMPUS, THE - OFFICE BLDG (ONE OR TWO STORIES)
-- NASHVILLE REAL ESTATE INVESTMENTS, LLC - ONE STORY GENERAL RETAIL STORE
-- SNAPSHOT DEVELOPMENT, LLC - PARKING LOT
-- FARR, STEPHEN MARK & KARIN RUTH - STRIP SHOPPING CENTER
-- COOK, ERIC - TERMINAL/DISTRIBUTION WAREHOUSE
-- WILSON, JARED J. & KENDAL BRINKLEY - VACANT RESIENTIAL LAND
-- BUCHANAN, DONALD W. & SANDRA R. - VACANT RURAL LAND
-- HARRIS, JONATHAN - VACANT ZONED MULTI FAMILY

-- High-Value Properties (Properties with a total value above 3 Million)

SELECT * FROM NashvilleProject.dbo.NashvilleHousing
WHERE TotalValue > 3000000
ORDER BY TotalValue DESC; 

-- There are only 14 properties that have a total value above 3 Million
-- Their land use type is single family, church, and vacant residential land

-- Owners with the highest average sale price across all their properties

SELECT TOP 10 OwnerName, ROUND(AVG(PropertySalePrice),2) AS AvgSalePrice
FROM (
    SELECT OwnerName, UniqueID, SalePrice AS PropertySalePrice
    FROM NashvilleProject.dbo.NashvilleHousing
) AS temp
GROUP BY OwnerName
ORDER BY AvgSalePrice DESC;

-- Top 3 most expensive properties in each land use category

WITH RankedProperties AS (
    SELECT UniqueID, LandUse, SalePrice,
           ROW_NUMBER() OVER (PARTITION BY LandUse ORDER BY SalePrice DESC) AS Rank
    FROM NashvilleProject.dbo.NashvilleHousing
)
SELECT UniqueID, LandUse, SalePrice, Rank
FROM RankedProperties
WHERE Rank <= 3;

-- Categorizing properties into high, medium, and low-value based on total value

SELECT UniqueID, TotalValue,
CASE 
	WHEN TotalValue >= 3000000 THEN 'High Value'
    WHEN TotalValue >= 1000000 THEN 'Medium Value'
    ELSE 'Low Value'
END AS ValueCategory
FROM NashvilleProject.dbo.NashvilleHousing
WHERE TotalValue IS NOT NULL;


















