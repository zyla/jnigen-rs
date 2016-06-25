module Main where

import AST
import qualified Parser
import Text.Parsec (parse)

main = do
    input <- getContents
    case parse Parser.file "<stdin>" input of
        Right ast -> mapM_ print $ classMembers ast
        Left err -> print err
