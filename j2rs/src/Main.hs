module Main where

import AST
import RustGen
import qualified Parser
import Text.Parsec (parse)

main = do
    input <- getContents
    run input

run input =
    case parse Parser.file "<stdin>" input of
        Right cls -> putStr $ genRust cls
        Left err -> print err
