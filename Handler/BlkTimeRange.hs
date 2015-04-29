module Handler.BlkTimeRange where

import Import

import Handler.Common

import Data.Aeson
import Blockchain.Data.DataDefs 
import Data.ByteString.Lazy as BS
import Database.Persist
import Database.Persist.TH
import Database.Persist.Postgresql

import qualified Database.Esqueleto as E
       
import Data.List
import System.Locale
import Data.Time
import Data.Time.Format

import qualified Prelude as P

import Debug.Trace

import Control.Monad.IO.Class (liftIO)

getBlkTimeRangeR :: UTCTime -> UTCTime -> Handler Value
getBlkTimeRangeR g1 g2 = do addHeader "Access-Control-Allow-Origin" "*"
                            blks <- runDB $ E.select $
                               E.from $ \(a, t) -> do
                               E.where_ ( (a E.^. BlockDataRefTimestamp E.>=. E.val g1 ) E.&&. (a E.^. BlockDataRefTimestamp E.<=. E.val g2)  E.&&. ( a E.^. BlockDataRefBlockId E.==. t E.^. BlockId))
                               
                               E.orderBy [E.desc (a E.^. BlockDataRefNumber)]
                               E.limit $ fetchLimit
                               return t
                            returnJson $ nub $ (P.map entityVal blks) -- consider removing nub - it takes time n^{2}
