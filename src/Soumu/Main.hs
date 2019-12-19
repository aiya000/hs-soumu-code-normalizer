module Soumu.Main where

import Codec.Xlsx
import qualified Codec.Xlsx as Xlsx
import Control.Lens
import Control.Monad.Except (ExceptT (..), runExceptT)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson (ToJSON)
import qualified Data.ByteString.Lazy as ByteString
import Data.Monoid ((<>))
import Data.Text (Text)
import GHC.Generics

type Result = [Row]


data Row = Row
  { code :: Text
  , prefeacture :: Text
  , city :: Text
  , prefeactureKana :: Text
  , cityKana :: Text
  }
  deriving (Show, Eq, Generic)
  deriving anyclass (ToJSON)

readToNormalize :: FilePath -> IO (Either Error Result)
readToNormalize xlsFile = runExceptT do
  xlsContent <- liftIO $ ByteString.readFile xlsFile
  xls <- ExceptT . pure . meaningless $ toXlsxEither xlsContent
  liftIO . print $ xls ^? ixSheet "R1.5.1現在の団体"
  pure undefined


type Error = String

meaningless :: Either Xlsx.ParseError a -> Either Error a
meaningless (Right x) = Right x
meaningless (Left x) = Left $ "error! " <> show x
