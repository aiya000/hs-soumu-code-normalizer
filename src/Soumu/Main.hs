module Soumu.Main where

import Codec.Xlsx
import qualified Codec.Xlsx as Xlsx
import Control.Lens
import Control.Monad.Except (ExceptT (..), runExceptT, throwError)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (ToJSON)
import qualified Data.ByteString.Lazy as ByteString
import Data.Maybe (catMaybes)
import Data.Monoid ((<>))
import Data.Text (Text)
import qualified Data.Text as Text
import GHC.Generics hiding (to)
import qualified TextShow as TextShow
import TextShow (TextShow (..))

type Result = [Row]


data Row = Row
  { code :: Text
  , prefeacture :: Text
  , prefeactureKana :: Text
  , city :: Maybe Text
  , cityKana :: Maybe Text
  }
  deriving (Show, Eq, Generic)
  deriving anyclass (ToJSON)

instance TextShow Row where
  showb Row{..} =
    "{\"code\":\"" <> TextShow.fromText code <>
    "\",\"prefeacture\":\"" <> TextShow.fromText prefeacture <>
    "\",\"prefeactureKana\":\"" <> TextShow.fromText prefeactureKana <>
    "\",\"city\":" <> fromTextOrNothing city <>
    ",\"cityKana\":" <> fromTextOrNothing cityKana <>
    "}"
    where
      fromTextOrNothing :: Maybe Text -> TextShow.Builder
      fromTextOrNothing Nothing = "null"
      fromTextOrNothing (Just x) = "\"" <> TextShow.fromText x <> "\""

mainSheetName :: Text
mainSheetName = "R1.5.1現在の団体"

columnOfCode :: Int
columnOfCode = 1

columnOfPrefecture :: Int
columnOfPrefecture = 2

columnOfCity :: Int
columnOfCity = 3

columnOfPrefectureKana :: Int
columnOfPrefectureKana = 4

columnOfCityKana :: Int
columnOfCityKana = 5

validTableRowRange :: [Int]
validTableRowRange = [2 .. 5000]

readToNormalize :: FilePath -> IO (Either Error Result)
readToNormalize xlsFile = runExceptT do
  xlsContent <- liftIO $ ByteString.readFile xlsFile
  xls <- ExceptT . pure . meaningless $ toXlsxEither xlsContent
  sheet <- rejectNothing $ xls ^? ixSheet mainSheetName
  let valuesMaybeRow = map (rowToRow sheet) validTableRowRange
  pure $ catMaybes valuesMaybeRow
  where
    rejectNothing :: Maybe a -> ExceptT Error IO a
    rejectNothing Nothing  = throwError $ "No sheet '" <> mainSheetName <> "' found."
    rejectNothing (Just x) = pure x

-- | Converts A plain row to Result's row
rowToRow :: Worksheet -> Int -> Maybe Row
rowToRow sheet rowNum =
  let maybeToRow = Row <$>
        sheet ^. cellValueAt (rowNum, columnOfCode)           . _Just . to textCell <*>
        sheet ^. cellValueAt (rowNum, columnOfPrefecture)     . _Just . to textCell <*>
        sheet ^. cellValueAt (rowNum, columnOfPrefectureKana) . _Just . to textCell
  in case maybeToRow of
    Nothing -> Nothing
    Just toRow -> Just $ toRow
      (sheet ^. cellValueAt (rowNum, columnOfCity) . _Just . to textCell)
      (sheet ^. cellValueAt (rowNum, columnOfCityKana) . _Just . to textCell)
  where
    textCell :: CellValue -> Maybe Text
    textCell (CellText x) = Just x
    textCell _ = Nothing

type Error = Text

meaningless :: Either Xlsx.ParseError a -> Either Error a
meaningless (Right x) = Right x
meaningless (Left x) = Left . Text.pack $ "error! " <> show x
