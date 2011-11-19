{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Data.Histogram.Bin.BinEnum (
    BinEnum(..)
  , binEnum
  , binEnumFull
  ) where

import Control.Monad (liftM)
import Data.Typeable (Typeable)
import Data.Data     (Data)
import Text.Read     (Read(..))

import Data.Histogram.Bin.Classes
import Data.Histogram.Bin.BinI
import Data.Histogram.Parse

-- | Bin for types which are instnaces of Enum type class
newtype BinEnum a = BinEnum BinI
                    deriving (Eq,Data,Typeable,GrowBin)

-- | Create enum based bin
binEnum :: Enum a => a -> a -> BinEnum a
binEnum a b = BinEnum $ binI (fromEnum a) (fromEnum b)

-- | Use full range of data
binEnumFull :: (Enum a, Bounded a) => BinEnum a
binEnumFull = binEnum minBound maxBound

instance Enum a => Bin (BinEnum a) where
  type BinValue (BinEnum a) = a
  toIndex   (BinEnum b) = toIndex b . fromEnum
  fromIndex (BinEnum b) = toEnum . fromIndex b
  inRange   (BinEnum b) = inRange b . fromEnum
  nBins     (BinEnum b) = nBins b

instance Enum a => IntervalBin (BinEnum a) where
  binInterval b x = (n,n) where n = fromIndex b x

instance Enum a => Bin1D (BinEnum a) where
  lowerLimit (BinEnum b) = toEnum $ lowerLimit b
  upperLimit (BinEnum b) = toEnum $ upperLimit b
  unsafeSliceBin i j (BinEnum b) = BinEnum $ unsafeSliceBin i j b

instance Show (BinEnum a) where
  show (BinEnum b) = "# BinEnum\n" ++ show b
instance Read (BinEnum a) where
  readPrec = keyword "BinEnum" >> liftM BinEnum readPrec