{-# LANGUAGE RecordWildCards #-}
module RustGen where

import Data.List
import AST
import Control.Monad.Writer

genRust :: [Class] -> String
genRust classes = execWriter $ do
    tell $ "extern crate jni_sys; use jni_sys::*;\n"

    forM_ classes $ \Class{..} -> do
        let structName = qnameRs className

        tell $ "static mut class_" ++ structName ++ ": jclass = 0 as jclass;\n"

        forM_ classMembers $ \Member{..} ->
            case memberGuts of
                MethodM javaName params | not (isStatic memberModifiers) ->
                    let name = case memberAs of
                                Just as -> as
                                Nothing -> javaName
                    in tell $ "static mut method_" ++ structName ++ "_" ++ name ++
                        " : jmethodID = 0 as jmethodID;\n"
                _ -> pure ()

        tell $ "pub struct " ++ structName ++ "(*mut JNIEnv, jobject);\n"
        tell $ "impl " ++ structName ++ " {\n"
        
        tell $ "\tpub unsafe fn wrap(env: *mut JNIEnv, obj: jobject) -> " ++ structName ++ " {\n"
        tell $ "\t\t" ++ structName ++ "(env, obj)\n"
        tell $ "\t}\n"

        forM_ classMembers $ \Member{..} ->
            case memberGuts of
                MethodM javaName params | not (isStatic memberModifiers) -> do
                    let name = case memberAs of
                                Just as -> as
                                Nothing -> javaName

                    tell $ "\tpub fn " ++ name ++ "(&self" ++ concatMap paramRs (zip [0..] params) ++ ") -> " ++ retTypeRs memberType ++ " {\n"

                    let paramVals = concatMap
                         (\(index, type_) -> ", " ++ unwrap type_ ("p" ++ show index))
                         (zip [0..] params)
                    let callExpr = "((**self.0)." ++ envCallFuncName memberType ++ ")(self.0, self.1, method_" ++
                            structName ++ "_" ++ name ++ paramVals ++ ")"

                    tell $ "\t\tunsafe { " ++ wrap memberType callExpr ++ " }\n"

                    tell $ "\t}\n"
                _ -> pure ()

        tell "}\n"

    
    tell $ "pub unsafe fn native_init(env: *mut JNIEnv) {\n"
    forM_ classes $ \Class{..} -> do
        let structName = qnameRs className

        tell $ "\tclass_" ++ structName ++ " = ((**env).FindClass)(env, " ++
            "\"" ++ javaClassSig className ++ "\\0\".as_ptr() as *const i8);\n"

        forM_ classMembers $ \Member{..} ->
            case memberGuts of
                MethodM javaName params | not (isStatic memberModifiers) ->
                    let name = case memberAs of
                                Just as -> as
                                Nothing -> javaName
                        varName = "method_" ++ structName ++ "_" ++ name
                        javaSig = javaMethodSig params memberType
                    in tell $ "\t" ++ varName ++ " = ((**env).GetMethodID)(env, " ++
                        "class_" ++ structName ++ ", \"" ++ javaName ++ "\\0\".as_ptr() as *const i8, \"" ++
                        javaSig ++ "\\0\".as_ptr() as *const i8);\n"
                _ -> pure ()
    tell $ "}\n"

javaMethodSig params ret = "(" ++ concatMap javaTypeSig params ++ ")" ++ javaTypeSig ret

javaTypeSig ["int"] = "I"
javaTypeSig ["long"] = "L"
javaTypeSig ["void"] = "V"
javaTypeSig ["boolean"] = "Z"
javaTypeSig t = "L" ++ javaClassSig t ++ ";"

javaClassSig t = intercalate "/" t

envCallFuncName ["int"] = "CallIntMethod"
envCallFuncName ["long"] = "CallLongMethod"
envCallFuncName ["void"] = "CallVoidMethod"
envCallFuncName ["boolean"] = "CallBooleanMethod"
envCallFuncName t = "CallObjectMethod"

unwrap type_ expr
    | isPrimitive type_ = expr
    | otherwise = -- object wrapper
        expr ++ ".1"

wrap type_ expr
    | isPrimitive type_ = expr
    | otherwise = -- object wrapper
        qnameRs type_ ++ "(self.0, " ++ expr ++ ")"

isPrimitive ["int"] = True
isPrimitive ["long"] = True
isPrimitive ["boolean"] = True
isPrimitive ["void"] = True
isPrimitive t = False

qnameRs :: QualifiedName -> String
qnameRs = intercalate "_"

retTypeRs ["void"] = "()"
retTypeRs t
    | isPrimitive t = typeRs t
    | otherwise = qnameRs t

typeRs ["long"] = "jlong"
typeRs ["int"] = "jint"
typeRs t = "&" ++ qnameRs t

paramRs (index, type_) = ", p" ++ show index ++ ": " ++ typeRs type_
