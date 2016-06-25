module AST where

type QualifiedName = [String]

type Type = QualifiedName

data Modifiers = Modifiers
    { isStatic :: Bool
    , isFinal :: Bool
    } deriving (Eq, Show)

noModifiers = Modifiers
    { isStatic = False
    , isFinal = False
    }

data Class = Class
    { classModifiers :: Modifiers
    , className :: QualifiedName
    , classMembers :: [Member]
    } deriving (Eq, Show)

data Member = Member
    { memberModifiers :: Modifiers
    , memberType :: Type
    , memberGuts :: MemberGuts
    , memberAs :: Maybe String
    } deriving (Eq, Show)

data MemberGuts = MethodM String [Type] | FieldM String | ConstructorM [Type]
    deriving (Eq, Show)
