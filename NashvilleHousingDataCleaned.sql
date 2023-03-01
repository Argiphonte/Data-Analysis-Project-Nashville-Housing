SELECT *
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

---- Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------

---- Populate Property Adress Data

SELECT *
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing a
JOIN NashvilleHousingPortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing a
JOIN NashvilleHousingPortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------

---- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select*
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

-- Same thing for Owner Address

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select*
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------

---- Change Y to Yes and N to No in "Sold as Vacant" field

Select distinct(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   End
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   End

Select distinct(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-----------------------------------------------------------------------------------------------------------------------------------------------

---- Remove Duplicates

With RowNumCTE AS (
Select *, 
	Row_number() Over(
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing
)
Select *
FROM RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

Select*
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------

---- Delete Unused Columns

Select*
FROM NashvilleHousingPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousingPortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousingPortfolioProject.dbo.NashvilleHousing
DROP Column SaleDate


