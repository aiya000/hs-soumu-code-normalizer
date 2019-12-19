module Main where

import Safe
import Soumu.Main (readToNormalize)
import System.Environment (getArgs)

main :: IO ()
main = do
  maybeXls <- headMay <$> getArgs
  case maybeXls of
    Nothing -> putStrLn "expected an argument as a .xls, because no arguments was taken."
    Just xls -> readToNormalize xls >>= print
