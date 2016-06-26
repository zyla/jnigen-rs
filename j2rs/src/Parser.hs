{-# LANGUAGE RecordWildCards #-}
module Parser where

import Text.Parsec
import qualified Text.Parsec.Language as L
import qualified Text.Parsec.Token as T

import AST

T.TokenParser {..} = T.makeTokenParser L.javaStyle

semicolon = reservedOp ";"

modifiers = foldr ($) noModifiers <$> many modifier
  where
    modifier = choice
        [ reserved "static" *> pure (\m -> m {isStatic=True})
        , reserved "final" *> pure (\m -> m {isFinal=True})
        , reserved "public" *> pure id
        , reserved "protected" *> pure id
        , reserved "native" *> pure id
        ]

qualifiedName = identifier `sepBy1` reservedOp "."

class_ = Class
    <$> modifiers
    <*> (reserved "class" *> qualifiedName)
    <*> braces (many member)

type_ = qualifiedName <* optional (angles (genericType `sepBy` comma))
  where genericType = reserved "?" <|> (() <$ type_)

member = Member
    <$> modifiers
    <*> type_
    <*> guts
    <*> as
    <*  semicolon
  where
    as = (reserved "as" *> (Just <$> identifier)) <|> pure Nothing

    guts = (ConstructorM <$> parameters) <|> do
        name <- identifier
        (MethodM name <$> parameters) <|> pure (FieldM name)

    parameters = parens (type_ `sepBy` comma)


file = whiteSpace *> many class_ <* eof
