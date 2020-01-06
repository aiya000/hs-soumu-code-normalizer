{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TypeApplications #-}

import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as ByteString hiding (putStrLn)
import qualified Data.ByteString.Lazy.Char8 as ByteString
import Data.Maybe (fromJust)
import Data.Text (Text)
import GHC.Generics

data Source = Source
  { code :: String
  , prefecture :: Text
  , prefectureKana :: Text
  , city :: Maybe Text
  , cityKana :: Maybe Text
  }
  deriving (Show, Generic)
  deriving anyclass (FromJSON, ToJSON)

data Normalized = Normalized
  { prefecture_ :: Text
  , cities :: [Text]
  }
  deriving (Show, Generic)
  deriving anyclass (ToJSON)


main :: IO ()
main = do
  file <- ByteString.readFile "soumu-organizations-codes.json"
  case eitherDecode @[Source] file of
    Left e -> error e
    Right xs -> do
      ByteString.putStrLn . encode $ format xs


format :: [Source] -> [Normalized]
format [] = []
format (x:xs) =
  let (grouped, rest) = span (\z -> prefecture z == prefecture x) xs
  in normalize (prefecture x) grouped : format rest


normalize :: Text -> [Source] -> Normalized
normalize prefectureName children =
  Normalized prefectureName $ map (fromJust . city) children
