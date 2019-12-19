module Main where

import Safe
import Soumu.Main (readToNormalize)
import System.Environment (getArgs)
import TextShow (printT)

main :: IO ()
main = do
  maybeXls <- headMay <$> getArgs
  case maybeXls of
    Nothing -> putStrLn "expected an argument as a .xls, because no arguments was taken."
    Just xls -> do
      contentOrErr <- readToNormalize xls
      case contentOrErr of
        Left e -> print e
        Right content -> printT content
